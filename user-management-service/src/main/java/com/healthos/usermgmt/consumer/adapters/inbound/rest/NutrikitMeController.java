package com.healthos.usermgmt.consumer.adapters.inbound.rest;

import com.healthos.usermgmt.adapters.inbound.rest.dto.MeDtos;
import com.healthos.usermgmt.adapters.inbound.rest.security.AuthPrincipal;
import com.healthos.usermgmt.consumer.application.ConsumerMeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/me/nutrikit")
@RequiredArgsConstructor
public class NutrikitMeController {
  private final ConsumerMeService consumerMeService;

  @GetMapping("/profile")
  public MeDtos.ProfileResponse getProfile(Authentication authentication) {
    var principal = (AuthPrincipal) authentication.getPrincipal();
    if (!principal.isConsumer()) {
      throw new IllegalStateException("NutriKit profile requires a consumer account");
    }
    return consumerMeService.toResponse(consumerMeService.getProfileView(principal.userId()));
  }

  @PutMapping("/profile")
  public MeDtos.ProfileResponse updateProfile(
      Authentication authentication, @Valid @RequestBody MeDtos.UpdateProfileRequest req) {
    var principal = (AuthPrincipal) authentication.getPrincipal();
    if (!principal.isConsumer()) {
      throw new IllegalStateException("NutriKit profile requires a consumer account");
    }
    var view =
        consumerMeService.upsertProfile(
            principal.userId(),
            req.getHeight(),
            req.getWeight(),
            req.getGender(),
            req.getDateOfBirth(),
            req.getGoal());
    return consumerMeService.toResponse(view);
  }
}
