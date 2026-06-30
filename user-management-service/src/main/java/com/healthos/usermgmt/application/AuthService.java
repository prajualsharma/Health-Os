package com.healthos.usermgmt.application;

import com.healthos.usermgmt.adapters.outbound.notification.NotificationClient;
import com.healthos.usermgmt.adapters.outbound.persistence.AuthMethodRepository;
import com.healthos.usermgmt.adapters.outbound.persistence.PasswordResetTokenRepository;
import com.healthos.usermgmt.adapters.outbound.persistence.RefreshTokenRepository;
import com.healthos.usermgmt.adapters.outbound.persistence.RoleRepository;
import com.healthos.usermgmt.adapters.outbound.persistence.UserProfileRepository;
import com.healthos.usermgmt.adapters.outbound.persistence.UserRepository;
import com.healthos.usermgmt.adapters.outbound.security.JwtService;
import com.healthos.usermgmt.adapters.outbound.security.TokenHasher;
import com.healthos.usermgmt.config.HealthOsProperties;
import com.healthos.usermgmt.domain.AuthMethod;
import com.healthos.usermgmt.domain.AuthMethodType;
import com.healthos.usermgmt.domain.PasswordResetToken;
import com.healthos.usermgmt.domain.RefreshToken;
import com.healthos.usermgmt.domain.Role;
import com.healthos.usermgmt.domain.User;
import com.healthos.usermgmt.domain.UserProfile;
import com.healthos.usermgmt.domain.UserStatus;
import jakarta.transaction.Transactional;
import java.time.Instant;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {
  private final UserRepository userRepository;
  private final RoleRepository roleRepository;
  private final RefreshTokenRepository refreshTokenRepository;
  private final PasswordResetTokenRepository passwordResetTokenRepository;
  private final AuthMethodRepository authMethodRepository;
  private final UserProfileRepository userProfileRepository;
  private final JwtService jwtService;
  private final ScopedMembershipService membershipService;
  private final ActiveScopeService activeScopeService;
  private final TokenHasher tokenHasher;
  private final PasswordEncoder passwordEncoder;
  private final OtpService otpService;
  private final NotificationClient notificationClient;
  private final HealthOsProperties props;

  // ---------------------------------------------------------------------------
  // Phone-first auth (WhatsApp OTP)
  // ---------------------------------------------------------------------------

  /** Step 1: validate phone, generate + deliver an OTP, and report whether the user exists. */
  public PhoneInitiateResult initiatePhone(String rawPhone) {
    var phone = normalizePhone(rawPhone);
    boolean exists =
        userRepository.findByPhone(phone).isPresent()
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

  /** Step 2: verify OTP. Returning users get tokens; new users get a registration token. */
  @Transactional
  public PhoneVerifyResult verifyPhone(String rawPhone, String otp) {
    var phone = normalizePhone(rawPhone);
    otpService.verify(phone, otp);

    var userOpt = resolveUserByPhone(phone);
    if (userOpt.isPresent()) {
      var user = userOpt.get();
      var profile = userProfileRepository.findById(user.getId()).orElse(null);
      if (isProfileComplete(profile)) {
        ensurePhoneAuthMethod(user, phone);
        return PhoneVerifyResult.returningUser(issueTokens(user, Instant.now()));
      }
    }
    return PhoneVerifyResult.pendingRegistration(otpService.issueRegistrationToken(phone));
  }

  /** Step 3 (new users): create the account from a verified registration token + profile. */
  @Transactional
  public RegistrationResult registerFromPhone(RegistrationCommand cmd) {
    var phone = normalizePhone(cmd.phone());
    var boundPhone = otpService.peekRegistrationToken(cmd.registrationToken());
    if (!boundPhone.equals(phone)) {
      throw new IllegalArgumentException("Registration token does not match phone");
    }

    var now = Instant.now();
    var existingUser = resolveUserByPhone(phone);
    User user;
    if (existingUser.isPresent()) {
      user = existingUser.get();
      var profile = userProfileRepository.findById(user.getId()).orElse(null);
      if (isProfileComplete(profile)) {
        throw new IllegalStateException("Phone already registered");
      }
      applyNameToUser(user, cmd.name());
      applyEmailToUser(user, cmd.email());
      user.setPhone(phone);
      user.setUpdatedAt(now);
      user = userRepository.saveAndFlush(user);
      ensurePhoneAuthMethod(user, phone);
    } else {
      user = createUserFromRegistration(cmd, phone, now);
      user = userRepository.saveAndFlush(user);
      saveAuthMethod(user, AuthMethodType.PHONE, phone, true);
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

    final var savedUser = user;
    var profile =
        userProfileRepository
            .findById(savedUser.getId())
            .orElseGet(
                () -> {
                  var created = new UserProfile();
                  created.setUser(savedUser);
                  return created;
                });
    applyRegistrationToProfile(profile, cmd, targets, now);
    userProfileRepository.save(profile);

    otpService.consumeRegistrationToken(cmd.registrationToken());
    return new RegistrationResult(issueTokens(savedUser, now), savedUser.getId(), targets);
  }

  // ---------------------------------------------------------------------------
  // OAuth (login/link only — never auto-creates an account)
  // ---------------------------------------------------------------------------

  @Transactional
  public OAuthResolveResult resolveOAuth(AuthMethodType method, String subject, String email) {
    var existing = authMethodRepository.findByMethodAndIdentifier(method, subject);
    if (existing.isPresent()) {
      return OAuthResolveResult.found(existing.get().getUser());
    }
    if (email != null && !email.isBlank()) {
      var userOpt = userRepository.findByEmail(email.toLowerCase());
      if (userOpt.isPresent()) {
        var user = userOpt.get();
        saveAuthMethod(user, method, subject, true);
        return OAuthResolveResult.linked(user);
      }
    }
    return OAuthResolveResult.noAccount();
  }

  private Optional<User> resolveUserByPhone(String phone) {
    var byPhone = userRepository.findByPhone(phone);
    if (byPhone.isPresent()) {
      return byPhone;
    }
    return authMethodRepository
        .findByMethodAndIdentifier(AuthMethodType.PHONE, phone)
        .map(AuthMethod::getUser);
  }

  private static boolean isProfileComplete(UserProfile profile) {
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

  private User createUserFromRegistration(RegistrationCommand cmd, String phone, Instant now) {
    var user = new User();
    user.setId(UUID.randomUUID());
    applyNameToUser(user, cmd.name());
    user.setPhone(phone);
    applyEmailToUser(user, cmd.email());
    user.setPassword(passwordEncoder.encode(UUID.randomUUID().toString()));
    user.setStatus(UserStatus.ACTIVE);
    user.setCreatedAt(now);
    user.setUpdatedAt(now);
    var memberRole =
        roleRepository
            .findByName("MEMBER")
            .orElseThrow(() -> new IllegalStateException("Seed role MEMBER not found"));
    var roles = new HashSet<Role>();
    roles.add(memberRole);
    user.setRoles(roles);
    return user;
  }

  private void applyNameToUser(User user, String name) {
    var names = splitName(name);
    user.setFirstName(names[0]);
    user.setLastName(names[1]);
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

  private void applyEmailToUser(User user, String rawEmail) {
    if (rawEmail == null || rawEmail.isBlank()) {
      return;
    }
    var email = rawEmail.toLowerCase();
    if (user.getEmail() != null && user.getEmail().equalsIgnoreCase(email)) {
      return;
    }
    if (userRepository.existsByEmail(email)) {
      throw new IllegalStateException("Email already registered");
    }
    user.setEmail(email);
  }

  private static void applyRegistrationToProfile(
      UserProfile profile,
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

  private void ensurePhoneAuthMethod(User user, String phone) {
    if (!authMethodRepository.existsByMethodAndIdentifier(AuthMethodType.PHONE, phone)) {
      saveAuthMethod(user, AuthMethodType.PHONE, phone, true);
    }
  }

  private void saveAuthMethod(User user, AuthMethodType method, String identifier, boolean verified) {
    var am = new AuthMethod();
    am.setId(UUID.randomUUID());
    am.setUser(user);
    am.setMethod(method);
    am.setIdentifier(identifier);
    am.setVerified(verified);
    am.setCreatedAt(Instant.now());
    authMethodRepository.save(am);
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
    var priority =
        List.of(
            "lose_weight",
            "build_muscle",
            "maintain",
            "eat_healthier",
            "diet_plan",
            "calorie_tracker",
            "workouts");
    for (var p : priority) {
      for (var g : cmd.goals()) {
        if (p.equalsIgnoreCase(g)) {
          return g;
        }
      }
    }
    return cmd.goals().get(0);
  }

  @Transactional
  public AuthTokens register(String firstName, String lastName, String email, String phone, String rawPassword) {
    if (userRepository.existsByEmail(email)) {
      throw new IllegalArgumentException("Email already registered");
    }

    var now = Instant.now();
    var user = new User();
    user.setId(UUID.randomUUID());
    user.setFirstName(toTitleCase(firstName));
    user.setLastName(lastName != null && !lastName.isBlank() ? toTitleCase(lastName) : null);
    user.setEmail(email.toLowerCase());
    user.setPhone(phone);
    user.setPassword(passwordEncoder.encode(rawPassword));
    user.setStatus(UserStatus.ACTIVE);
    user.setCreatedAt(now);
    user.setUpdatedAt(now);

    var memberRole =
        roleRepository
            .findByName("MEMBER")
            .orElseThrow(() -> new IllegalStateException("Seed role MEMBER not found"));
    var roles = new HashSet<Role>();
    roles.add(memberRole);
    user.setRoles(roles);

    userRepository.save(user);
    return issueTokens(user, now);
  }

  @Transactional
  public AuthTokens loginWithEmail(String email, String rawPassword) {
    var user =
        userRepository
            .findByEmail(email.toLowerCase())
            .orElseThrow(() -> new IllegalArgumentException("Invalid credentials"));
    if (!passwordEncoder.matches(rawPassword, user.getPassword())) {
      throw new IllegalArgumentException("Invalid credentials");
    }
    if (user.getStatus() != UserStatus.ACTIVE) {
      throw new IllegalStateException("User is not active");
    }
    return issueTokens(user, Instant.now());
  }

  @Transactional
  public OtpChallenge requestOtp(String phone) {
    var now = Instant.now();
    var code = props.getOtp().getDevCode();
    var expiresAt = now.plusSeconds(props.getOtp().getTtlSeconds());
    return new OtpChallenge(phone, expiresAt, true);
  }

  @Transactional
  public AuthTokens verifyOtp(String phone, String otpCode) {
    if (!props.getOtp().getDevCode().equals(otpCode)) {
      throw new IllegalArgumentException("Invalid OTP");
    }

    var user =
        userRepository
            .findByPhone(phone)
            .orElseThrow(() -> new IllegalArgumentException("No user for phone. Register via email first."));
    return issueTokens(user, Instant.now());
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

    // rotate
    token.setRevokedAt(now);
    refreshTokenRepository.save(token);

    var user = token.getUser();
    return issueTokens(user, now);
  }

  @Transactional
  public void logoutByRefreshToken(String refreshTokenRaw) {
    var now = Instant.now();
    var hash = tokenHasher.sha256Hex(refreshTokenRaw);
    refreshTokenRepository
        .findByTokenHash(hash)
        .ifPresent(
            token -> {
              token.setRevokedAt(now);
              refreshTokenRepository.save(token);
            });
  }

  @Transactional
  public PasswordResetIssue forgotPassword(String email) {
    var user =
        userRepository
            .findByEmail(email.toLowerCase())
            .orElseThrow(() -> new IllegalArgumentException("No user found"));

    var now = Instant.now();
    var rawToken = UUID.randomUUID() + "." + UUID.randomUUID();
    var token = new PasswordResetToken();
    token.setId(UUID.randomUUID());
    token.setUser(user);
    token.setTokenHash(tokenHasher.sha256Hex(rawToken));
    token.setCreatedAt(now);
    token.setExpiresAt(now.plusSeconds(900));
    passwordResetTokenRepository.save(token);

    // In production, this would be emailed/SMSed. Returning token supports dev/testing.
    return new PasswordResetIssue(rawToken, token.getExpiresAt());
  }

  @Transactional
  public void resetPassword(String resetTokenRaw, String newPassword) {
    var now = Instant.now();
    var token =
        passwordResetTokenRepository
            .findByTokenHash(tokenHasher.sha256Hex(resetTokenRaw))
            .orElseThrow(() -> new IllegalArgumentException("Invalid reset token"));
    if (!token.isUsable(now)) {
      throw new IllegalArgumentException("Reset token expired or used");
    }
    token.setUsedAt(now);
    passwordResetTokenRepository.save(token);

    var user = token.getUser();
    user.setPassword(passwordEncoder.encode(newPassword));
    user.setUpdatedAt(now);
    userRepository.save(user);

    refreshTokenRepository.revokeAllActiveForUser(user.getId(), now);
  }

  private AuthTokens issueTokens(User user, Instant now) {
    var memberships = membershipService.listClaimsForUser(user.getId());
    var activeScope =
        activeScopeService
            .get(user.getId())
            .or(() -> activeScopeService.resolveDefault(memberships))
            .orElse(null);
    var accessToken = jwtService.issueAccessToken(user, now, memberships, activeScope);
    var refreshRaw = UUID.randomUUID() + "." + UUID.randomUUID();

    var refresh = storeRefreshToken(user, refreshRaw, now);

    return new AuthTokens(accessToken, refreshRaw, now.plusSeconds(props.getSecurity().getJwt().getAccessTokenTtlSeconds()), refresh.getExpiresAt());
  }

  @Transactional
  public RefreshToken storeRefreshToken(User user, String refreshTokenRaw, Instant now) {
    var refresh = new RefreshToken();
    refresh.setId(UUID.randomUUID());
    refresh.setUser(user);
    refresh.setTokenHash(tokenHasher.sha256Hex(refreshTokenRaw));
    refresh.setCreatedAt(now);
    refresh.setExpiresAt(now.plusSeconds(props.getSecurity().getJwt().getRefreshTokenTtlSeconds()));
    return refreshTokenRepository.save(refresh);
  }

  public record AuthTokens(String accessToken, String refreshToken, Instant accessTokenExpiresAt, Instant refreshTokenExpiresAt) {}

  public record OtpChallenge(String phone, Instant expiresAt, boolean devMode) {}

  public record PasswordResetIssue(String resetToken, Instant expiresAt) {}

  public record PhoneInitiateResult(
      String phone,
      boolean exists,
      boolean otpSent,
      boolean devMode,
      boolean otpDelivered,
      String deliveryEmail) {}

  public record PhoneVerifyResult(boolean newUser, AuthTokens tokens, String registrationToken) {
    static PhoneVerifyResult returningUser(AuthTokens tokens) {
      return new PhoneVerifyResult(false, tokens, null);
    }

    static PhoneVerifyResult pendingRegistration(String registrationToken) {
      return new PhoneVerifyResult(true, null, registrationToken);
    }
  }

  public record RegistrationCommand(
      String phone,
      String registrationToken,
      String name,
      String goal,
      List<String> goals,
      String gender,
      Integer age,
      Integer height,
      Integer weight,
      Integer targetWeight,
      String activity,
      String diet,
      List<String> allergies,
      List<String> medicalConditions,
      String city,
      String goalPace,
      String heightUnit,
      String weightUnit,
      String email) {}

  public record NutritionTargets(int calories, int protein, int carbs, int fat, int timelineWeeks) {}

  public record RegistrationResult(AuthTokens tokens, UUID userId, NutritionTargets targets) {}

  public enum OAuthStatus {
    FOUND,
    LINKED,
    NO_ACCOUNT
  }

  public record OAuthResolveResult(
      OAuthStatus status, UUID userId, String email, List<String> roles) {
    static OAuthResolveResult found(User user) {
      return of(OAuthStatus.FOUND, user);
    }

    static OAuthResolveResult linked(User user) {
      return of(OAuthStatus.LINKED, user);
    }

    static OAuthResolveResult noAccount() {
      return new OAuthResolveResult(OAuthStatus.NO_ACCOUNT, null, null, null);
    }

    private static OAuthResolveResult of(OAuthStatus status, User user) {
      return new OAuthResolveResult(
          status,
          user.getId(),
          user.getEmail(),
          user.getRoles().stream().map(Role::getName).toList());
    }
  }
}

