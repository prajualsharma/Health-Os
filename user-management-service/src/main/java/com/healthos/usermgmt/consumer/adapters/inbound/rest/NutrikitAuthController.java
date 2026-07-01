package com.healthos.usermgmt.consumer.adapters.inbound.rest;

import com.healthos.usermgmt.adapters.inbound.rest.dto.AuthDtos;
import com.healthos.usermgmt.application.AuthContracts;
import com.healthos.usermgmt.application.AuthContracts.AuthTokens;
import com.healthos.usermgmt.application.AuthContracts.PhoneInitiateResult;
import com.healthos.usermgmt.application.AuthContracts.PhoneVerifyResult;
import com.healthos.usermgmt.application.AuthContracts.RegistrationCommand;
import com.healthos.usermgmt.application.AuthContracts.RegistrationResult;
import com.healthos.usermgmt.consumer.application.ConsumerAuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth/nutrikit")
@RequiredArgsConstructor
public class NutrikitAuthController {
  private final ConsumerAuthService consumerAuthService;

  @PostMapping("/phone/initiate")
  public AuthDtos.PhoneInitiateResponse initiatePhone(
      @Valid @RequestBody AuthDtos.PhoneInitiateRequest req) {
    var result = consumerAuthService.initiatePhone(req.getPhone());
    return toInitiateResponse(result);
  }

  @PostMapping("/phone/verify")
  public AuthDtos.PhoneVerifyResponse verifyPhone(@Valid @RequestBody AuthDtos.OtpVerifyRequest req) {
    var result = consumerAuthService.verifyPhone(req.getPhone(), req.getOtp());
    return toVerifyResponse(result);
  }

  @PostMapping("/register-phone")
  public AuthDtos.RegisterPhoneResponse registerPhone(
      @Valid @RequestBody AuthDtos.RegisterPhoneRequest req) {
    var result =
        consumerAuthService.registerFromPhone(
            new RegistrationCommand(
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
    return toRegisterResponse(result);
  }

  @PostMapping("/refresh")
  public AuthDtos.TokenResponse refresh(@Valid @RequestBody AuthDtos.RefreshRequest req) {
    return toTokenResponse(consumerAuthService.refresh(req.getRefreshToken()));
  }

  private static AuthDtos.PhoneInitiateResponse toInitiateResponse(PhoneInitiateResult result) {
    var res = new AuthDtos.PhoneInitiateResponse();
    res.setExists(result.exists());
    res.setOtpSent(result.otpSent());
    res.setDevMode(result.devMode());
    res.setOtpDelivered(result.otpDelivered());
    res.setDeliveryEmail(result.deliveryEmail());
    return res;
  }

  private static AuthDtos.PhoneVerifyResponse toVerifyResponse(PhoneVerifyResult result) {
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

  private static AuthDtos.RegisterPhoneResponse toRegisterResponse(RegistrationResult result) {
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

  private static AuthDtos.TokenResponse toTokenResponse(AuthTokens tokens) {
    var res = new AuthDtos.TokenResponse();
    res.setAccessToken(tokens.accessToken());
    res.setRefreshToken(tokens.refreshToken());
    res.setAccessTokenExpiresAt(tokens.accessTokenExpiresAt());
    res.setRefreshTokenExpiresAt(tokens.refreshTokenExpiresAt());
    return res;
  }
}
