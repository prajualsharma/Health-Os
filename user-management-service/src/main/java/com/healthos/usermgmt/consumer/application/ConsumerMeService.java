package com.healthos.usermgmt.consumer.application;

import com.healthos.usermgmt.adapters.inbound.rest.dto.MeDtos;
import com.healthos.usermgmt.consumer.adapters.outbound.persistence.ConsumerAccountRepository;
import com.healthos.usermgmt.consumer.adapters.outbound.persistence.ConsumerUserProfileRepository;
import com.healthos.usermgmt.consumer.domain.ConsumerAccount;
import com.healthos.usermgmt.consumer.domain.ConsumerUserProfile;
import com.healthos.usermgmt.shared.exception.StaleSessionException;
import jakarta.transaction.Transactional;
import java.time.Instant;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ConsumerMeService {
  private final ConsumerAccountRepository accountRepository;
  private final ConsumerUserProfileRepository profileRepository;

  public ProfileView getProfileView(UUID accountId) {
    var account =
        accountRepository
            .findById(accountId)
            .orElseThrow(() -> new StaleSessionException("User not found"));
    var profile =
        profileRepository.findById(accountId).orElseGet(() -> createEmptyProfile(account));
    return new ProfileView(account, profile);
  }

  public record ProfileView(ConsumerAccount account, ConsumerUserProfile profile) {}

  @Transactional
  public ProfileView upsertProfile(
      UUID accountId, Integer height, Integer weight, String gender, LocalDate dateOfBirth, String goal) {
    var view = getProfileView(accountId);
    var profile = view.profile();
    profile.setHeight(height);
    profile.setWeight(weight);
    profile.setGender(gender);
    profile.setDateOfBirth(dateOfBirth);
    profile.setGoal(goal);
    profile.setUpdatedAt(Instant.now());
    profileRepository.save(profile);
    return new ProfileView(view.account(), profile);
  }

  public MeDtos.ProfileResponse toResponse(ProfileView view) {
    return toResponse(view.account(), view.profile());
  }

  public MeDtos.ProfileResponse toResponse(ConsumerAccount account, ConsumerUserProfile profile) {
    var res = new MeDtos.ProfileResponse();
    res.setName(formatName(account));
    res.setEmail(account.getEmail());
    res.setHeight(profile.getHeight());
    res.setWeight(profile.getWeight());
    res.setTargetWeight(profile.getTargetWeight());
    res.setGender(profile.getGender());
    res.setDateOfBirth(profile.getDateOfBirth());
    res.setGoal(profile.getGoal());
    res.setGoals(parseCsv(profile.getGoals()));
    res.setActivityLevel(profile.getActivityLevel());
    res.setDietType(profile.getDietType());
    res.setAllergies(parseCsv(profile.getAllergies()));
    res.setMedicalConditions(parseCsv(profile.getMedicalConditions()));
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

  private ConsumerUserProfile createEmptyProfile(ConsumerAccount account) {
    var profile = new ConsumerUserProfile();
    profile.setAccount(account);
    profile.setUpdatedAt(Instant.now());
    return profile;
  }

  private static String formatName(ConsumerAccount account) {
    var first = account.getFirstName() != null ? account.getFirstName().trim() : "";
    var last = account.getLastName() != null ? account.getLastName().trim() : "";
    if (first.isEmpty() && last.isEmpty()) {
      return "User";
    }
    if (last.isEmpty()) {
      return first;
    }
    return first + " " + last;
  }

  private static List<String> parseCsv(String raw) {
    if (raw == null || raw.isBlank()) {
      return Collections.emptyList();
    }
    return Arrays.stream(raw.split(",")).map(String::trim).filter(s -> !s.isEmpty()).toList();
  }
}
