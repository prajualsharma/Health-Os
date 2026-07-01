package com.healthos.usermgmt.consumer.application;

import com.healthos.usermgmt.adapters.outbound.security.TokenHasher;
import com.healthos.usermgmt.application.OtpService;
import com.healthos.usermgmt.consumer.adapters.outbound.persistence.OnboardingSessionRepository;
import com.healthos.usermgmt.consumer.domain.ConsumerOnboardingSession;
import com.healthos.usermgmt.consumer.domain.OnboardingStep;
import jakarta.transaction.Transactional;
import java.time.Instant;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class OnboardingProgressService {
  private final OnboardingSessionRepository sessionRepository;
  private final OtpService otpService;
  private final TokenHasher tokenHasher;

  @Transactional
  public ConsumerOnboardingSession startSession(String phone, String registrationToken) {
    otpService.peekRegistrationToken(registrationToken);
    var now = Instant.now();
    var hash = tokenHasher.sha256Hex(registrationToken);
    var existing = sessionRepository.findByPhoneAndCompletedAtIsNull(phone);
    if (existing.isPresent()) {
      var session = existing.get();
      session.setRegistrationTokenHash(hash);
      session.setCurrentStep(OnboardingStep.NAME.key());
      session.setLastActivityAt(now);
      return sessionRepository.save(session);
    }
    var session = new ConsumerOnboardingSession();
    session.setId(UUID.randomUUID());
    session.setPhone(phone);
    session.setRegistrationTokenHash(hash);
    session.setCurrentStep(OnboardingStep.NAME.key());
    session.setLastActivityAt(now);
    session.setCreatedAt(now);
    return sessionRepository.save(session);
  }

  @Transactional
  public ConsumerOnboardingSession updateProgress(
      String registrationToken, String step, String firstName, String email) {
    var phone = otpService.peekRegistrationToken(registrationToken);
    var onboardingStep = OnboardingStep.fromKey(step);
    var hash = tokenHasher.sha256Hex(registrationToken);
    var now = Instant.now();

    var session =
        sessionRepository
            .findByRegistrationTokenHashAndCompletedAtIsNull(hash)
            .orElseGet(
                () -> {
                  var created = new ConsumerOnboardingSession();
                  created.setId(UUID.randomUUID());
                  created.setPhone(phone);
                  created.setRegistrationTokenHash(hash);
                  created.setCreatedAt(now);
                  return created;
                });

    session.setPhone(phone);
    session.setRegistrationTokenHash(hash);
    session.setCurrentStep(onboardingStep.key());
    session.setLastActivityAt(now);
    if (firstName != null && !firstName.isBlank()) {
      session.setFirstName(firstName.trim());
    }
    if (email != null && !email.isBlank()) {
      session.setEmail(email.trim().toLowerCase());
    }
    return sessionRepository.save(session);
  }

  public OnboardingProgressView getProgress(String registrationToken) {
    var hash = tokenHasher.sha256Hex(registrationToken);
    otpService.peekRegistrationToken(registrationToken);
    var session =
        sessionRepository
            .findByRegistrationTokenHashAndCompletedAtIsNull(hash)
            .orElseThrow(() -> new IllegalArgumentException("Onboarding session not found"));
    var step = OnboardingStep.fromKey(session.getCurrentStep());
    return new OnboardingProgressView(step.key(), step.routePath(), step.label());
  }

  @Transactional
  public void completeByPhone(String phone) {
    sessionRepository
        .findByPhoneAndCompletedAtIsNull(phone)
        .ifPresent(
            session -> {
              session.setCompletedAt(Instant.now());
              sessionRepository.save(session);
            });
  }

  public record OnboardingProgressView(String currentStep, String routePath, String stepLabel) {}
}
