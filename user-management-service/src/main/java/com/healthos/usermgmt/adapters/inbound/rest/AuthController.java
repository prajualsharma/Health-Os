package com.healthos.usermgmt.adapters.inbound.rest;

import com.healthos.usermgmt.adapters.inbound.rest.dto.AuthDtos;
import com.healthos.usermgmt.application.AuthService;
import com.healthos.usermgmt.consumer.application.ConsumerAuthService;
import com.healthos.usermgmt.shared.domain.ClientId;
import com.healthos.usermgmt.staff.application.StaffAuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {
  private final AuthService authService;
  private final ConsumerAuthService consumerAuthService;
  private final StaffAuthService staffAuthService;

  @PostMapping("/register")
  public AuthDtos.TokenResponse register(@Valid @RequestBody AuthDtos.RegisterRequest req) {
    var tokens = authService.register(req.getFirstName(), req.getLastName(), req.getEmail(), req.getPhone(), req.getPassword());
    return toTokenResponse(tokens);
  }

  @PostMapping("/login")
  public AuthDtos.TokenResponse login(@Valid @RequestBody AuthDtos.LoginRequest req) {
    var tokens = authService.loginWithEmail(req.getEmail(), req.getPassword());
    return toTokenResponse(tokens);
  }

  @PostMapping("/refresh")
  public AuthDtos.TokenResponse refresh(@Valid @RequestBody AuthDtos.RefreshRequest req) {
    var tokens = authService.refresh(req.getRefreshToken());
    return toTokenResponse(tokens);
  }

  @PostMapping("/logout")
  public void logout(@Valid @RequestBody AuthDtos.LogoutRequest body) {
    authService.logoutByRefreshToken(body.getRefreshToken());
  }

  @PostMapping("/otp/request")
  public AuthDtos.OtpChallengeResponse requestOtp(@Valid @RequestBody AuthDtos.OtpRequest req) {
    var challenge = authService.requestOtp(req.getPhone());
    var res = new AuthDtos.OtpChallengeResponse();
    res.setPhone(challenge.phone());
    res.setExpiresAt(challenge.expiresAt());
    res.setDevMode(challenge.devMode());
    return res;
  }

  @PostMapping("/otp/verify")
  public AuthDtos.TokenResponse verifyOtp(@Valid @RequestBody AuthDtos.OtpVerifyRequest req) {
    var tokens = authService.verifyOtp(req.getPhone(), req.getOtp());
    return toTokenResponse(tokens);
  }

  @PostMapping("/phone/initiate")
  public AuthDtos.PhoneInitiateResponse initiatePhone(
      @Valid @RequestBody AuthDtos.PhoneInitiateRequest req) {
    var clientId = resolveClientId(req.getClientId());
    var result =
        clientId == ClientId.NUTRIKIT
            ? consumerAuthService.initiatePhone(req.getPhone())
            : staffAuthService.initiatePhone(req.getPhone());
    var res = new AuthDtos.PhoneInitiateResponse();
    res.setExists(result.exists());
    res.setOtpSent(result.otpSent());
    res.setDevMode(result.devMode());
    res.setOtpDelivered(result.otpDelivered());
    res.setDeliveryEmail(result.deliveryEmail());
    return res;
  }

  @PostMapping("/phone/verify")
  public AuthDtos.PhoneVerifyResponse verifyPhone(
      @Valid @RequestBody AuthDtos.OtpVerifyRequest req) {
    var clientId = resolveClientId(req.getClientId());
    var result =
        clientId == ClientId.NUTRIKIT
            ? consumerAuthService.verifyPhone(req.getPhone(), req.getOtp())
            : staffAuthService.verifyPhone(req.getPhone(), req.getOtp(), clientId);
    var res = new AuthDtos.PhoneVerifyResponse();
    res.setNewUser(result.newUser());
    if (result.newUser()) {
      res.setRegistrationToken(result.registrationToken());
    } else {
      var tokens = result.tokens();
      res.setAccessToken(tokens.accessToken());
      res.setRefreshToken(tokens.refreshToken());
      res.setAccessTokenExpiresAt(tokens.accessTokenExpiresAt());
      res.setRefreshTokenExpiresAt(tokens.refreshTokenExpiresAt());
    }
    return res;
  }

  @PostMapping("/register-phone")
  public AuthDtos.RegisterPhoneResponse registerPhone(
      @Valid @RequestBody AuthDtos.RegisterPhoneRequest req) {
    var result =
        consumerAuthService.registerFromPhone(
            new AuthService.RegistrationCommand(
                req.getPhone(),
                req.getRegistrationToken(),
                req.getName(),
                req.getGoal(),
                req.getGoals(),
                req.getGender(),
                req.getAge(),
                req.getHeight(),
                req.getWeight(),
                req.getTargetWeight(),
                req.getActivity(),
                req.getDiet(),
                req.getAllergies(),
                req.getMedicalConditions(),
                req.getCity(),
                req.getGoalPace(),
                req.getHeightUnit(),
                req.getWeightUnit(),
                req.getEmail()));

    var res = new AuthDtos.RegisterPhoneResponse();
    var tokens = result.tokens();
    res.setAccessToken(tokens.accessToken());
    res.setRefreshToken(tokens.refreshToken());
    res.setAccessTokenExpiresAt(tokens.accessTokenExpiresAt());
    res.setRefreshTokenExpiresAt(tokens.refreshTokenExpiresAt());
    res.setUserId(result.userId());

    var targets = new AuthDtos.NutritionTargetsResponse();
    targets.setCalories(result.targets().calories());
    targets.setProtein(result.targets().protein());
    targets.setCarbs(result.targets().carbs());
    targets.setFat(result.targets().fat());
    targets.setTimelineWeeks(result.targets().timelineWeeks());
    res.setTargets(targets);
    return res;
  }

  @PostMapping("/forgot-password")
  public AuthDtos.ForgotPasswordResponse forgotPassword(@Valid @RequestBody AuthDtos.ForgotPasswordRequest req) {
    var issue = authService.forgotPassword(req.getEmail());
    var res = new AuthDtos.ForgotPasswordResponse();
    res.setResetToken(issue.resetToken());
    res.setExpiresAt(issue.expiresAt());
    return res;
  }

  @PostMapping("/reset-password")
  public void resetPassword(@Valid @RequestBody AuthDtos.ResetPasswordRequest req) {
    authService.resetPassword(req.getResetToken(), req.getNewPassword());
  }

  private static ClientId resolveClientId(String raw) {
    if (raw == null || raw.isBlank()) {
      return ClientId.NUTRIKIT;
    }
    return ClientId.from(raw);
  }

  private static AuthDtos.TokenResponse toTokenResponse(AuthService.AuthTokens tokens) {
    var res = new AuthDtos.TokenResponse();
    res.setAccessToken(tokens.accessToken());
    res.setRefreshToken(tokens.refreshToken());
    res.setAccessTokenExpiresAt(tokens.accessTokenExpiresAt());
    res.setRefreshTokenExpiresAt(tokens.refreshTokenExpiresAt());
    return res;
  }
}

