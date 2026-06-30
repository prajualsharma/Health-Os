package com.healthos.usermgmt.adapters.inbound.rest;

import com.healthos.usermgmt.adapters.inbound.rest.dto.MeDtos;
import com.healthos.usermgmt.adapters.inbound.rest.security.AuthPrincipal;
import com.healthos.usermgmt.application.MeService;
import com.healthos.usermgmt.domain.User;
import com.healthos.usermgmt.domain.UserProfile;
import jakarta.validation.Valid;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
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
    var view = meService.getProfileView(principal.userId());
    return toResponse(view.user(), view.profile());
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
    var user = meService.getUser(principal.userId());
    return toResponse(user, profile);
  }

  private static MeDtos.ProfileResponse toResponse(User user, UserProfile profile) {
    var res = new MeDtos.ProfileResponse();
    res.setName(formatName(user));
    res.setEmail(user.getEmail());
    res.setHeight(profile.getHeight());
    res.setWeight(profile.getWeight());
    res.setTargetWeight(profile.getTargetWeight());
    res.setGender(profile.getGender());
    res.setDateOfBirth(profile.getDateOfBirth());
    res.setGoal(profile.getGoal());
    res.setGoals(parseCsv(profile.getGoals()));
    res.setActivityLevel(profile.getActivityLevel());
    res.setDietType(profile.getDietType());
    res.setAllergies(parseAllergies(profile.getAllergies()));
    res.setMedicalConditions(parseAllergies(profile.getMedicalConditions()));
    res.setCity(profile.getCity());
    res.setGoalPace(profile.getGoalPace());
    res.setHeightUnit(profile.getPreferredHeightUnit());
    res.setWeightUnit(profile.getPreferredWeightUnit());
    res.setCalorieTarget(profile.getCalorieTarget());
    res.setProteinTarget(profile.getProteinTarget());
    res.setCarbTarget(profile.getCarbTarget());
    res.setFatTarget(profile.getFatTarget());
    return res;
  }

  private static String formatName(User user) {
    var first = user.getFirstName() != null ? user.getFirstName().trim() : "";
    var last = user.getLastName() != null ? user.getLastName().trim() : "";
    if (first.isEmpty() && last.isEmpty()) {
      return "User";
    }
    if (last.isEmpty()) {
      return first;
    }
    return first + " " + last;
  }

  private static List<String> parseAllergies(String raw) {
    return parseCsv(raw);
  }

  private static List<String> parseCsv(String raw) {
    if (raw == null || raw.isBlank()) {
      return Collections.emptyList();
    }
    return Arrays.stream(raw.split(",")).map(String::trim).filter(s -> !s.isEmpty()).toList();
  }
}
