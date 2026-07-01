package com.healthos.usermgmt.consumer.application;

import com.healthos.usermgmt.adapters.outbound.notification.NotificationClient;
import com.healthos.usermgmt.adapters.outbound.security.JwtService;
import com.healthos.usermgmt.adapters.outbound.security.TokenHasher;
import com.healthos.usermgmt.application.AuthContracts;
import com.healthos.usermgmt.application.AuthContracts.AuthTokens;
import com.healthos.usermgmt.application.AuthContracts.NutritionTargets;
import com.healthos.usermgmt.application.AuthContracts.OAuthResolveResult;
import com.healthos.usermgmt.application.AuthContracts.PhoneInitiateResult;
import com.healthos.usermgmt.application.AuthContracts.PhoneVerifyResult;
import com.healthos.usermgmt.application.AuthContracts.RegistrationCommand;
import com.healthos.usermgmt.application.AuthContracts.RegistrationResult;
import com.healthos.usermgmt.application.NutritionCalculator;
import com.healthos.usermgmt.application.OtpRateLimitService;
import com.healthos.usermgmt.application.OtpService;
import com.healthos.usermgmt.config.HealthOsProperties;
import com.healthos.usermgmt.consumer.adapters.outbound.persistence.ConsumerAccountRepository;
import com.healthos.usermgmt.consumer.adapters.outbound.persistence.ConsumerAuthMethodRepository;
import com.healthos.usermgmt.consumer.adapters.outbound.persistence.ConsumerRefreshTokenRepository;
import com.healthos.usermgmt.consumer.adapters.outbound.persistence.ConsumerUserProfileRepository;
import com.healthos.usermgmt.consumer.domain.ConsumerAccount;
import com.healthos.usermgmt.consumer.domain.ConsumerAuthMethod;
import com.healthos.usermgmt.consumer.domain.ConsumerRefreshToken;
import com.healthos.usermgmt.consumer.domain.ConsumerUserProfile;
import com.healthos.usermgmt.domain.AuthMethodType;
import com.healthos.usermgmt.domain.UserStatus;
import jakarta.transaction.Transactional;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ConsumerAuthService {
  private final ConsumerAccountRepository accountRepository;
  private final ConsumerAuthMethodRepository authMethodRepository;
  private final ConsumerUserProfileRepository profileRepository;
  private final ConsumerRefreshTokenRepository refreshTokenRepository;
  private final JwtService jwtService;
  private final TokenHasher tokenHasher;
  private final PasswordEncoder passwordEncoder;
  private final OtpService otpService;
  private final OtpRateLimitService otpRateLimitService;
  private final NotificationClient notificationClient;
  private final HealthOsProperties props;
  private final OnboardingProgressService onboardingProgressService;

  public PhoneInitiateResult initiatePhone(String rawPhone) {
    var phone = normalizePhone(rawPhone);
    otpRateLimitService.checkConsumerAllowed(phone);
    boolean exists =
        accountRepository.findByPhone(phone).isPresent()
            || authMethodRepository.existsByMethodAndIdentifier(AuthMethodType.PHONE, phone);
    var code = otpService.generate(phone);
    boolean sent = notificationClient.sendOtp(phone, code);
    boolean devMode = props.getOtp().isDevBypass();
    boolean otpDelivered = sent && !devMode;
    var deliveryEmail =
        otpDelivered && props.getNotification().isEnabled()
            ? props.getNotification().getOtpEmailTo()
            : null;
    return new PhoneInitiateResult(phone, exists, true, devMode, otpDelivered, deliveryEmail);
  }

  @Transactional
  public PhoneVerifyResult verifyPhone(String rawPhone, String otp) {
    var phone = normalizePhone(rawPhone);
    otpService.verify(phone, otp);

    var accountOpt = resolveByPhone(phone);
    if (accountOpt.isPresent()) {
      var account = accountOpt.get();
      var profile = profileRepository.findById(account.getId()).orElse(null);
      if (isProfileComplete(profile)) {
        ensurePhoneAuthMethod(account, phone);
        return PhoneVerifyResult.returningUser(issueTokens(account, Instant.now()));
      }
    }
    return PhoneVerifyResult.pendingRegistration(startRegistration(phone));
  }

  private String startRegistration(String phone) {
    var token = otpService.issueRegistrationToken(phone);
    onboardingProgressService.startSession(phone, token);
    return token;
  }

  @Transactional
  public RegistrationResult registerFromPhone(RegistrationCommand cmd) {
    var phone = normalizePhone(cmd.phone());
    var boundPhone = otpService.peekRegistrationToken(cmd.registrationToken());
    if (!boundPhone.equals(phone)) {
      throw new IllegalArgumentException("Registration token does not match phone");
    }

    var now = Instant.now();
    var existing = resolveByPhone(phone);
    ConsumerAccount account;
    if (existing.isPresent()) {
      account = existing.get();
      var profile = profileRepository.findById(account.getId()).orElse(null);
      if (isProfileComplete(profile)) {
        throw new IllegalStateException("Phone already registered");
      }
      applyName(account, cmd.name());
      applyEmail(account, cmd.email());
      account.setPhone(phone);
      account.setUpdatedAt(now);
      account = accountRepository.saveAndFlush(account);
      ensurePhoneAuthMethod(account, phone);
    } else {
      account = createAccount(cmd, phone, now);
      account = accountRepository.saveAndFlush(account);
      saveAuthMethod(account, phone);
    }

    var targets =
        NutritionCalculator.compute(
            cmd.gender(),
            cmd.age(),
            cmd.height(),
            cmd.weight(),
            cmd.targetWeight(),
            cmd.activity(),
            resolvePrimaryGoal(cmd),
            cmd.goalPace());

    final var saved = account;
    var profile =
        profileRepository
            .findById(saved.getId())
            .orElseGet(
                () -> {
                  var created = new ConsumerUserProfile();
                  created.setAccount(saved);
                  return created;
                });
    applyProfile(profile, cmd, targets, now);
    profileRepository.save(profile);

    otpService.consumeRegistrationToken(cmd.registrationToken());
    onboardingProgressService.completeByPhone(phone);
    return new RegistrationResult(issueTokens(saved, now), saved.getId(), targets);
  }

  @Transactional
  public AuthTokens refresh(String refreshTokenRaw) {
    var now = Instant.now();
    var hash = tokenHasher.sha256Hex(refreshTokenRaw);
    var token =
        refreshTokenRepository
            .findByTokenHash(hash)
            .orElseThrow(() -> new IllegalArgumentException("Invalid refresh token"));
    if (!token.isActive(now)) {
      throw new IllegalArgumentException("Refresh token expired or revoked");
    }
    token.setRevokedAt(now);
    refreshTokenRepository.save(token);
    return issueTokens(token.getAccount(), now);
  }

  @Transactional
  public OAuthResolveResult resolveOAuth(AuthMethodType method, String subject, String email) {
    var existing = authMethodRepository.findByMethodAndIdentifier(method, subject);
    if (existing.isPresent()) {
      return OAuthResolveResult.found(existing.get().getAccount());
    }
    if (email != null && !email.isBlank()) {
      var accountOpt = accountRepository.findByEmail(email.toLowerCase());
      if (accountOpt.isPresent()) {
        var account = accountOpt.get();
        saveOAuthMethod(account, method, subject);
        return OAuthResolveResult.linked(account);
      }
    }
    return OAuthResolveResult.noAccount();
  }

  @Transactional
  public void storeRefreshToken(UUID accountId, String refreshTokenRaw) {
    var account =
        accountRepository
            .findById(accountId)
            .orElseThrow(() -> new IllegalArgumentException("Consumer account not found"));
    var now = Instant.now();
    var refresh = new ConsumerRefreshToken();
    refresh.setId(UUID.randomUUID());
    refresh.setAccount(account);
    refresh.setTokenHash(tokenHasher.sha256Hex(refreshTokenRaw));
    refresh.setCreatedAt(now);
    refresh.setExpiresAt(now.plusSeconds(props.getSecurity().getJwt().getRefreshTokenTtlSeconds()));
    refreshTokenRepository.save(refresh);
  }

  private AuthTokens issueTokens(ConsumerAccount account, Instant now) {
    var accessToken = jwtService.issueConsumerToken(account, now);
    var refreshRaw = UUID.randomUUID() + "." + UUID.randomUUID();
    var refresh = new ConsumerRefreshToken();
    refresh.setId(UUID.randomUUID());
    refresh.setAccount(account);
    refresh.setTokenHash(tokenHasher.sha256Hex(refreshRaw));
    refresh.setCreatedAt(now);
    refresh.setExpiresAt(now.plusSeconds(props.getSecurity().getJwt().getRefreshTokenTtlSeconds()));
    refreshTokenRepository.save(refresh);
    return new AuthTokens(
        accessToken,
        refreshRaw,
        now.plusSeconds(props.getSecurity().getJwt().getAccessTokenTtlSeconds()),
        refresh.getExpiresAt());
  }

  private Optional<ConsumerAccount> resolveByPhone(String phone) {
    var byPhone = accountRepository.findByPhone(phone);
    if (byPhone.isPresent()) {
      return byPhone;
    }
    return authMethodRepository
        .findByMethodAndIdentifier(AuthMethodType.PHONE, phone)
        .map(ConsumerAuthMethod::getAccount);
  }

  private ConsumerAccount createAccount(RegistrationCommand cmd, String phone, Instant now) {
    var account = new ConsumerAccount();
    account.setId(UUID.randomUUID());
    applyName(account, cmd.name());
    account.setPhone(phone);
    applyEmail(account, cmd.email());
    account.setPassword(passwordEncoder.encode(UUID.randomUUID().toString()));
    account.setStatus(UserStatus.ACTIVE);
    account.setCreatedAt(now);
    account.setUpdatedAt(now);
    return account;
  }

  private void ensurePhoneAuthMethod(ConsumerAccount account, String phone) {
    if (!authMethodRepository.existsByMethodAndIdentifier(AuthMethodType.PHONE, phone)) {
      saveAuthMethod(account, phone);
    }
  }

  private void saveAuthMethod(ConsumerAccount account, String phone) {
    var am = new ConsumerAuthMethod();
    am.setId(UUID.randomUUID());
    am.setAccount(account);
    am.setMethod(AuthMethodType.PHONE);
    am.setIdentifier(phone);
    am.setVerified(true);
    am.setCreatedAt(Instant.now());
    authMethodRepository.save(am);
  }

  private static boolean isProfileComplete(ConsumerUserProfile profile) {
    if (profile == null) {
      return false;
    }
    return profile.getGoal() != null
        && !profile.getGoal().isBlank()
        && profile.getHeight() != null
        && profile.getWeight() != null
        && profile.getActivityLevel() != null
        && !profile.getActivityLevel().isBlank();
  }

  private void applyName(ConsumerAccount account, String name) {
    var names = splitName(name);
    account.setFirstName(names[0]);
    account.setLastName(names[1]);
  }

  private void applyEmail(ConsumerAccount account, String rawEmail) {
    if (rawEmail == null || rawEmail.isBlank()) {
      return;
    }
    var email = rawEmail.toLowerCase();
    if (account.getEmail() != null && account.getEmail().equalsIgnoreCase(email)) {
      return;
    }
    if (accountRepository.existsByEmail(email)) {
      throw new IllegalStateException("Email already registered");
    }
    account.setEmail(email);
  }

  private void saveOAuthMethod(ConsumerAccount account, AuthMethodType method, String identifier) {
    if (authMethodRepository.existsByMethodAndIdentifier(method, identifier)) {
      return;
    }
    var am = new ConsumerAuthMethod();
    am.setId(UUID.randomUUID());
    am.setAccount(account);
    am.setMethod(method);
    am.setIdentifier(identifier);
    am.setVerified(true);
    am.setCreatedAt(Instant.now());
    authMethodRepository.save(am);
  }

  private static void applyProfile(
      ConsumerUserProfile profile,
      RegistrationCommand cmd,
      NutritionTargets targets,
      Instant now) {
    profile.setHeight(cmd.height());
    profile.setWeight(cmd.weight());
    profile.setGender(cmd.gender());
    if (cmd.age() != null) {
      profile.setDateOfBirth(LocalDate.now().minusYears(cmd.age()));
    }
    profile.setGoal(resolvePrimaryGoal(cmd));
    profile.setGoals(joinList(cmd.goals()));
    profile.setTargetWeight(cmd.targetWeight());
    profile.setActivityLevel(cmd.activity());
    profile.setDietType(cmd.diet());
    profile.setAllergies(
        cmd.allergies() == null || cmd.allergies().isEmpty() ? null : String.join(",", cmd.allergies()));
    profile.setMedicalConditions(joinList(cmd.medicalConditions()));
    profile.setCity(cmd.city());
    profile.setGoalPace(cmd.goalPace());
    profile.setPreferredHeightUnit(cmd.heightUnit() != null ? cmd.heightUnit() : "cm");
    profile.setPreferredWeightUnit(cmd.weightUnit() != null ? cmd.weightUnit() : "kg");
    profile.setCalorieTarget(targets.calories());
    profile.setProteinTarget(targets.protein());
    profile.setCarbTarget(targets.carbs());
    profile.setFatTarget(targets.fat());
    profile.setUpdatedAt(now);
  }

  private static String normalizePhone(String raw) {
    if (raw == null) {
      throw new IllegalArgumentException("Phone is required");
    }
    var phone = raw.replaceAll("[\\s-]", "");
    if (!phone.matches("\\+[1-9]\\d{7,14}")) {
      throw new IllegalArgumentException("Phone must be E.164, e.g. +919876543210");
    }
    return phone;
  }

  private static String[] splitName(String name) {
    if (name == null || name.isBlank()) {
      return new String[] {"User", null};
    }
    var trimmed = name.trim();
    int idx = trimmed.indexOf(' ');
    if (idx < 0) {
      return new String[] {toTitleCase(trimmed), null};
    }
    return new String[] {
      toTitleCase(trimmed.substring(0, idx)), toTitleCase(trimmed.substring(idx + 1).trim())
    };
  }

  private static String toTitleCase(String input) {
    if (input == null || input.isBlank()) {
      return input;
    }
    var words = input.trim().split("\\s+");
    var sb = new StringBuilder();
    for (int i = 0; i < words.length; i++) {
      if (i > 0) {
        sb.append(' ');
      }
      var w = words[i];
      if (!w.isEmpty()) {
        sb.append(Character.toUpperCase(w.charAt(0)));
        if (w.length() > 1) {
          sb.append(w.substring(1).toLowerCase());
        }
      }
    }
    return sb.toString();
  }

  private static String joinList(List<String> values) {
    if (values == null || values.isEmpty()) {
      return null;
    }
    var cleaned = values.stream().filter(v -> v != null && !v.isBlank()).toList();
    return cleaned.isEmpty() ? null : String.join(",", cleaned);
  }

  private static String resolvePrimaryGoal(RegistrationCommand cmd) {
    if (cmd.goal() != null && !cmd.goal().isBlank()) {
      return cmd.goal();
    }
    if (cmd.goals() == null || cmd.goals().isEmpty()) {
      return null;
    }
    return cmd.goals().get(0);
  }
}
