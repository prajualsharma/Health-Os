package com.healthos.usermgmt.adapters.inbound.rest.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import lombok.Data;

public class AuthDtos {
  @Data
  public static class RegisterRequest {
    @NotBlank @Size(max = 80) private String firstName;
    @Size(max = 80) private String lastName;
    @NotBlank @Email @Size(max = 255) private String email;
    @Size(max = 32) private String phone;
    @NotBlank @Size(min = 8, max = 128) private String password;
  }

  @Data
  public static class LoginRequest {
    @NotBlank @Email private String email;
    @NotBlank private String password;
  }

  @Data
  public static class RefreshRequest {
    @NotBlank private String refreshToken;
  }

  @Data
  public static class OtpRequest {
    @NotBlank @Size(max = 32) private String phone;
  }

  @Data
  public static class OtpVerifyRequest {
    @NotBlank @Size(max = 32) private String phone;
    @NotBlank @Size(min = 4, max = 10) private String otp;
  }

  @Data
  public static class ForgotPasswordRequest {
    @NotBlank @Email private String email;
  }

  @Data
  public static class ResetPasswordRequest {
    @NotBlank private String resetToken;
    @NotBlank @Size(min = 8, max = 128) private String newPassword;
  }

  @Data
  public static class TokenResponse {
    private String accessToken;
    private String refreshToken;
    private Instant accessTokenExpiresAt;
    private Instant refreshTokenExpiresAt;
  }

  @Data
  public static class OtpChallengeResponse {
    private String phone;
    private Instant expiresAt;
    private boolean devMode;
  }

  @Data
  public static class ForgotPasswordResponse {
    private String resetToken;
    private Instant expiresAt;
  }

  @Data
  public static class LogoutRequest {
    @NotBlank private String refreshToken;
  }

  @Data
  public static class PhoneInitiateRequest {
    @NotBlank @Size(max = 32) private String phone;
  }

  @Data
  public static class PhoneInitiateResponse {
    private boolean exists;
    private boolean otpSent;
    private boolean devMode;
  }

  @Data
  public static class PhoneVerifyResponse {
    private boolean newUser;
    private String accessToken;
    private String refreshToken;
    private Instant accessTokenExpiresAt;
    private Instant refreshTokenExpiresAt;
    private String registrationToken;
  }

  @Data
  public static class RegisterPhoneRequest {
    @NotBlank @Size(max = 32) private String phone;
    @NotBlank private String registrationToken;
    @NotBlank @Size(max = 160) private String name;
    @Size(max = 128) private String goal;
    @Size(max = 16) private String gender;
    private Integer age;
    private Integer height;
    private Integer weight;
    private Integer targetWeight;
    @Size(max = 32) private String activity;
    @Size(max = 32) private String diet;
    private List<String> allergies;
    @Email @Size(max = 255) private String email;
  }

  @Data
  public static class RegisterPhoneResponse {
    private String accessToken;
    private String refreshToken;
    private Instant accessTokenExpiresAt;
    private Instant refreshTokenExpiresAt;
    private UUID userId;
    private NutritionTargetsResponse targets;
  }

  @Data
  public static class NutritionTargetsResponse {
    private int calories;
    private int protein;
    private int carbs;
    private int fat;
  }
}

