package com.healthos.usermgmt.staff.adapters.inbound.rest;

import com.healthos.usermgmt.adapters.inbound.rest.dto.AuthDtos;
import com.healthos.usermgmt.application.AuthContracts;
import com.healthos.usermgmt.application.AuthContracts.AuthTokens;
import com.healthos.usermgmt.application.AuthContracts.PhoneInitiateResult;
import com.healthos.usermgmt.application.AuthContracts.PhoneVerifyResult;
import com.healthos.usermgmt.shared.domain.ClientId;
import com.healthos.usermgmt.staff.application.StaffAuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class StaffAuthController {
  private final StaffAuthService staffAuthService;

  @PostMapping("/auth/staff/phone/initiate")
  public AuthDtos.PhoneInitiateResponse initiatePhone(
      @Valid @RequestBody AuthDtos.PhoneInitiateRequest req,
      @RequestParam(defaultValue = "kitchen") String clientId) {
    var result = staffAuthService.initiatePhone(req.getPhone());
    return toInitiateResponse(result);
  }

  @PostMapping("/auth/staff/phone/verify")
  public AuthDtos.PhoneVerifyResponse verifyPhone(
      @Valid @RequestBody AuthDtos.OtpVerifyRequest req,
      @RequestParam(defaultValue = "kitchen") String clientId) {
    var result = staffAuthService.verifyPhone(req.getPhone(), req.getOtp(), ClientId.from(clientId));
    return toVerifyResponse(result);
  }

  @PostMapping("/auth/staff/register-phone")
  public AuthDtos.TokenResponse registerPhone(
      @Valid @RequestBody AuthDtos.StaffRegisterPhoneRequest req) {
    return toTokenResponse(
        staffAuthService.registerStaff(req.getPhone(), req.getRegistrationToken(), req.getName()));
  }

  @PostMapping("/auth/staff/refresh")
  public AuthDtos.TokenResponse refresh(@Valid @RequestBody AuthDtos.RefreshRequest req) {
    return toTokenResponse(staffAuthService.refresh(req.getRefreshToken()));
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

  private static AuthDtos.TokenResponse toTokenResponse(AuthTokens tokens) {
    var res = new AuthDtos.TokenResponse();
    res.setAccessToken(tokens.accessToken());
    res.setRefreshToken(tokens.refreshToken());
    res.setAccessTokenExpiresAt(tokens.accessTokenExpiresAt());
    res.setRefreshTokenExpiresAt(tokens.refreshTokenExpiresAt());
    return res;
  }
}
