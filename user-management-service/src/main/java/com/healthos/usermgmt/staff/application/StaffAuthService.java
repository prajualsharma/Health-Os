package com.healthos.usermgmt.staff.application;

import com.healthos.usermgmt.adapters.outbound.notification.NotificationClient;
import com.healthos.usermgmt.adapters.outbound.security.JwtService;
import com.healthos.usermgmt.adapters.outbound.security.TokenHasher;
import com.healthos.usermgmt.application.ActiveScopeService;
import com.healthos.usermgmt.application.AuthContracts;
import com.healthos.usermgmt.application.AuthContracts.AuthTokens;
import com.healthos.usermgmt.application.AuthContracts.PhoneInitiateResult;
import com.healthos.usermgmt.application.AuthContracts.PhoneVerifyResult;
import com.healthos.usermgmt.application.OtpService;
import com.healthos.usermgmt.application.ScopedMembershipService;
import com.healthos.usermgmt.config.HealthOsProperties;
import com.healthos.usermgmt.domain.AuthMethodType;
import com.healthos.usermgmt.domain.PortalType;
import com.healthos.usermgmt.domain.UserStatus;
import com.healthos.usermgmt.shared.domain.ClientId;
import com.healthos.usermgmt.staff.adapters.outbound.persistence.StaffAccountRepository;
import com.healthos.usermgmt.staff.adapters.outbound.persistence.StaffAuthMethodRepository;
import com.healthos.usermgmt.staff.adapters.outbound.persistence.StaffRefreshTokenRepository;
import com.healthos.usermgmt.staff.domain.StaffAccount;
import com.healthos.usermgmt.staff.domain.StaffAuthMethod;
import com.healthos.usermgmt.staff.domain.StaffRefreshToken;
import jakarta.transaction.Transactional;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class StaffAuthService {
  private final StaffAccountRepository accountRepository;
  private final StaffAuthMethodRepository authMethodRepository;
  private final StaffRefreshTokenRepository refreshTokenRepository;
  private final JwtService jwtService;
  private final ScopedMembershipService membershipService;
  private final ActiveScopeService activeScopeService;
  private final TokenHasher tokenHasher;
  private final PasswordEncoder passwordEncoder;
  private final OtpService otpService;
  private final NotificationClient notificationClient;
  private final HealthOsProperties props;

  public PhoneInitiateResult initiatePhone(String rawPhone) {
    var phone = normalizePhone(rawPhone);
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
  public PhoneVerifyResult verifyPhone(String rawPhone, String otp, ClientId clientId) {
    var phone = normalizePhone(rawPhone);
    otpService.verify(phone, otp);

    var accountOpt = resolveByPhone(phone);
    if (accountOpt.isPresent()) {
      var account = accountOpt.get();
      ensurePhoneAuthMethod(account, phone);
      var portal = portalFor(clientId);
      var memberships = membershipService.listClaimsForUser(account.getId());
      var portalMemberships = memberships.stream().filter(m -> m.portal() == portal).toList();
      if (!portalMemberships.isEmpty()) {
        return PhoneVerifyResult.returningUser(issueTokens(account, Instant.now()));
      }
      if (!memberships.isEmpty()) {
        throw new IllegalStateException("No " + portal + " membership for this account");
      }
    }
    return PhoneVerifyResult.pendingRegistration(otpService.issueRegistrationToken(phone));
  }

  @Transactional
  public AuthTokens registerStaff(String phoneRaw, String registrationToken, String name) {
    var phone = normalizePhone(phoneRaw);
    var boundPhone = otpService.peekRegistrationToken(registrationToken);
    if (!boundPhone.equals(phone)) {
      throw new IllegalArgumentException("Registration token does not match phone");
    }

    var now = Instant.now();
    StaffAccount account;
    var existing = resolveByPhone(phone);
    if (existing.isPresent()) {
      account = existing.get();
    } else {
      account = new StaffAccount();
      account.setId(UUID.randomUUID());
      applyName(account, name);
      account.setPhone(phone);
      account.setPassword(passwordEncoder.encode(UUID.randomUUID().toString()));
      account.setStatus(UserStatus.ACTIVE);
      account.setCreatedAt(now);
      account.setUpdatedAt(now);
      account = accountRepository.saveAndFlush(account);
      saveAuthMethod(account, phone);
    }

    otpService.consumeRegistrationToken(registrationToken);
    return issueTokens(account, now);
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

  private AuthTokens issueTokens(StaffAccount account, Instant now) {
    var memberships = membershipService.listClaimsForUser(account.getId());
    var activeScope =
        activeScopeService
            .get(account.getId())
            .or(() -> activeScopeService.resolveDefault(memberships))
            .orElse(null);
    var accessToken = jwtService.issueStaffToken(account, now, memberships, activeScope);
    var refreshRaw = UUID.randomUUID() + "." + UUID.randomUUID();
    var refresh = new StaffRefreshToken();
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

  private static PortalType portalFor(ClientId clientId) {
    return switch (clientId) {
      case KITCHEN -> PortalType.KITCHEN;
      case GYM -> PortalType.GYM;
      case NUTRIKIT -> throw new IllegalArgumentException("Use consumer auth for nutrikit");
    };
  }

  private Optional<StaffAccount> resolveByPhone(String phone) {
    var byPhone = accountRepository.findByPhone(phone);
    if (byPhone.isPresent()) {
      return byPhone;
    }
    return authMethodRepository
        .findByMethodAndIdentifier(AuthMethodType.PHONE, phone)
        .map(StaffAuthMethod::getAccount);
  }

  private void ensurePhoneAuthMethod(StaffAccount account, String phone) {
    if (!authMethodRepository.existsByMethodAndIdentifier(AuthMethodType.PHONE, phone)) {
      saveAuthMethod(account, phone);
    }
  }

  private void saveAuthMethod(StaffAccount account, String phone) {
    var am = new StaffAuthMethod();
    am.setId(UUID.randomUUID());
    am.setAccount(account);
    am.setMethod(AuthMethodType.PHONE);
    am.setIdentifier(phone);
    am.setVerified(true);
    am.setCreatedAt(Instant.now());
    authMethodRepository.save(am);
  }

  private void applyName(StaffAccount account, String name) {
    var names = splitName(name);
    account.setFirstName(names[0]);
    account.setLastName(names[1]);
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
      return new String[] {"Staff", null};
    }
    var trimmed = name.trim();
    int idx = trimmed.indexOf(' ');
    if (idx < 0) {
      return new String[] {trimmed, null};
    }
    return new String[] {trimmed.substring(0, idx), trimmed.substring(idx + 1).trim()};
  }
}
