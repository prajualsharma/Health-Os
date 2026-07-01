package com.healthos.usermgmt.application;

import com.healthos.usermgmt.consumer.domain.ConsumerAccount;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** Shared auth request/response types for consumer and staff flows. */
public final class AuthContracts {
  private AuthContracts() {}

  public record AuthTokens(
      String accessToken,
      String refreshToken,
      Instant accessTokenExpiresAt,
      Instant refreshTokenExpiresAt) {}

  public record PhoneInitiateResult(
      String phone,
      boolean exists,
      boolean otpSent,
      boolean devMode,
      boolean otpDelivered,
      String deliveryEmail) {}

  public record PhoneVerifyResult(boolean newUser, AuthTokens tokens, String registrationToken) {
    public static PhoneVerifyResult returningUser(AuthTokens tokens) {
      return new PhoneVerifyResult(false, tokens, null);
    }

    public static PhoneVerifyResult pendingRegistration(String registrationToken) {
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
    public static OAuthResolveResult found(ConsumerAccount account) {
      return of(OAuthStatus.FOUND, account);
    }

    public static OAuthResolveResult linked(ConsumerAccount account) {
      return of(OAuthStatus.LINKED, account);
    }

    public static OAuthResolveResult noAccount() {
      return new OAuthResolveResult(OAuthStatus.NO_ACCOUNT, null, null, null);
    }

    private static OAuthResolveResult of(OAuthStatus status, ConsumerAccount account) {
      return new OAuthResolveResult(status, account.getId(), account.getEmail(), List.of());
    }
  }
}
