package com.healthos.usermgmt.application;

import com.healthos.usermgmt.adapters.outbound.persistence.UserProfileRepository;
import com.healthos.usermgmt.adapters.outbound.persistence.UserRepository;
import com.healthos.usermgmt.domain.UserProfile;
import jakarta.transaction.Transactional;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MeService {
  private final UserRepository userRepository;
  private final UserProfileRepository userProfileRepository;

  public UserProfile getProfile(UUID userId) {
    return userProfileRepository.findById(userId).orElseGet(() -> createEmptyProfile(userId));
  }

  @Transactional
  public UserProfile upsertProfile(
      UUID userId, Integer height, Integer weight, String gender, LocalDate dateOfBirth, String goal) {
    var profile = userProfileRepository.findById(userId).orElseGet(() -> createEmptyProfile(userId));
    profile.setHeight(height);
    profile.setWeight(weight);
    profile.setGender(gender);
    profile.setDateOfBirth(dateOfBirth);
    profile.setGoal(goal);
    profile.setUpdatedAt(Instant.now());
    return userProfileRepository.save(profile);
  }

  private UserProfile createEmptyProfile(UUID userId) {
    var user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
    var p = new UserProfile();
    p.setUser(user);
    p.setUserId(userId);
    p.setUpdatedAt(Instant.now());
    return p;
  }
}

