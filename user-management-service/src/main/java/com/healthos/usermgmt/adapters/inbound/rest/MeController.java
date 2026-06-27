package com.healthos.usermgmt.adapters.inbound.rest;

import com.healthos.usermgmt.adapters.inbound.rest.dto.MeDtos;
import com.healthos.usermgmt.adapters.inbound.rest.security.AuthPrincipal;
import com.healthos.usermgmt.application.MeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/me")
@RequiredArgsConstructor
public class MeController {
  private final MeService meService;

  @GetMapping("/profile")
  public MeDtos.ProfileResponse getProfile(Authentication authentication) {
    var principal = (AuthPrincipal) authentication.getPrincipal();
    var profile = meService.getProfile(principal.userId());
    var res = new MeDtos.ProfileResponse();
    res.setHeight(profile.getHeight());
    res.setWeight(profile.getWeight());
    res.setGender(profile.getGender());
    res.setDateOfBirth(profile.getDateOfBirth());
    res.setGoal(profile.getGoal());
    return res;
  }

  @PutMapping("/profile")
  public MeDtos.ProfileResponse updateProfile(
      Authentication authentication, @Valid @RequestBody MeDtos.UpdateProfileRequest req) {
    var principal = (AuthPrincipal) authentication.getPrincipal();
    var profile =
        meService.upsertProfile(
            principal.userId(),
            req.getHeight(),
            req.getWeight(),
            req.getGender(),
            req.getDateOfBirth(),
            req.getGoal());
    var res = new MeDtos.ProfileResponse();
    res.setHeight(profile.getHeight());
    res.setWeight(profile.getWeight());
    res.setGender(profile.getGender());
    res.setDateOfBirth(profile.getDateOfBirth());
    res.setGoal(profile.getGoal());
    return res;
  }
}

