package com.healthos.usermgmt.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

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
import com.healthos.usermgmt.domain.RefreshToken;
import com.healthos.usermgmt.domain.Role;
import com.healthos.usermgmt.domain.User;
import com.healthos.usermgmt.domain.UserStatus;
import java.time.Instant;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

class AuthServiceTest {
  private UserRepository userRepository;
  private RoleRepository roleRepository;
  private RefreshTokenRepository refreshTokenRepository;
  private PasswordResetTokenRepository passwordResetTokenRepository;
  private AuthMethodRepository authMethodRepository;
  private UserProfileRepository userProfileRepository;
  private JwtService jwtService;
  private ScopedMembershipService membershipService;
  private ActiveScopeService activeScopeService;
  private TokenHasher tokenHasher;
  private OtpService otpService;
  private NotificationClient notificationClient;
  private HealthOsProperties props;

  private AuthService authService;

  @BeforeEach
  void setUp() {
    userRepository = Mockito.mock(UserRepository.class);
    roleRepository = Mockito.mock(RoleRepository.class);
    refreshTokenRepository = Mockito.mock(RefreshTokenRepository.class);
    passwordResetTokenRepository = Mockito.mock(PasswordResetTokenRepository.class);
    authMethodRepository = Mockito.mock(AuthMethodRepository.class);
    userProfileRepository = Mockito.mock(UserProfileRepository.class);
    otpService = Mockito.mock(OtpService.class);
    notificationClient = Mockito.mock(NotificationClient.class);

    props = new HealthOsProperties();
    props.getSecurity().getJwt().setIssuer("healthos");
    props.getSecurity().getJwt().setSecret("dev-only-change-me-dev-only-change-me");
    props.getSecurity().getJwt().setAccessTokenTtlSeconds(900);
    props.getSecurity().getJwt().setRefreshTokenTtlSeconds(3600);
    props.getOtp().setDevCode("123456");
    props.getOtp().setTtlSeconds(300);

    jwtService = new JwtService(props);
    membershipService = Mockito.mock(ScopedMembershipService.class);
    activeScopeService = Mockito.mock(ActiveScopeService.class);
    tokenHasher = new TokenHasher();

    when(membershipService.listClaimsForUser(any())).thenReturn(java.util.List.of());
    when(activeScopeService.get(any())).thenReturn(java.util.Optional.empty());
    when(activeScopeService.resolveDefault(any())).thenReturn(java.util.Optional.empty());

    authService =
        new AuthService(
            userRepository,
            roleRepository,
            refreshTokenRepository,
            passwordResetTokenRepository,
            authMethodRepository,
            userProfileRepository,
            jwtService,
            membershipService,
            activeScopeService,
            tokenHasher,
            new BCryptPasswordEncoder(),
            otpService,
            notificationClient,
            props);
  }

  @Test
  void refresh_rotatesToken_andIssuesNewTokens() {
    var user = baseUser();
    var rawRefresh = "r1.r2";
    var hash = tokenHasher.sha256Hex(rawRefresh);

    var stored = new RefreshToken();
    stored.setId(UUID.randomUUID());
    stored.setUser(user);
    stored.setTokenHash(hash);
    stored.setCreatedAt(Instant.now().minusSeconds(10));
    stored.setExpiresAt(Instant.now().plusSeconds(300));

    when(refreshTokenRepository.findByTokenHash(hash)).thenReturn(Optional.of(stored));
    when(refreshTokenRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

    var tokens = authService.refresh(rawRefresh);

    assertThat(tokens.accessToken()).isNotBlank();
    assertThat(tokens.refreshToken()).isNotBlank();
    assertThat(tokens.refreshToken()).isNotEqualTo(rawRefresh);

    var captor = ArgumentCaptor.forClass(RefreshToken.class);
    verify(refreshTokenRepository, atLeastOnce()).save(captor.capture());
    assertThat(captor.getAllValues().stream().anyMatch(t -> t.getRevokedAt() != null)).isTrue();
  }

  @Test
  void verifyOtp_rejectsWrongCode() {
    assertThatThrownBy(() -> authService.verifyOtp("+911234567890", "000000"))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("Invalid OTP");
  }

  private static User baseUser() {
    var role = new Role();
    role.setId(UUID.randomUUID());
    role.setName("MEMBER");
    var user = new User();
    user.setId(UUID.randomUUID());
    user.setFirstName("A");
    user.setLastName("B");
    user.setEmail("a@b.com");
    user.setPassword("$2a$10$test");
    user.setStatus(UserStatus.ACTIVE);
    user.setCreatedAt(Instant.now());
    user.setUpdatedAt(Instant.now());
    user.setRoles(Set.of(role));
    return user;
  }
}

