package com.healthos.usermgmt.consumer.application;

import com.healthos.usermgmt.adapters.outbound.notification.NotificationEventPublisher;
import com.healthos.usermgmt.config.HealthOsProperties;
import com.healthos.usermgmt.consumer.adapters.outbound.persistence.OnboardingSessionRepository;
import com.healthos.usermgmt.consumer.domain.OnboardingStep;
import java.time.Duration;
import java.time.Instant;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class OnboardingReminderService {
  private final OnboardingSessionRepository sessionRepository;
  private final NotificationEventPublisher eventPublisher;
  private final HealthOsProperties props;
  private final OnboardingReminderProperties reminderProperties;

  @Scheduled(fixedRateString = "${healthos.onboarding-reminder.poll-interval-ms:300000}")
  @Transactional
  public void sendDueReminders() {
    var cutoff = Instant.now().minus(Duration.ofMinutes(reminderProperties.getDelayMinutes()));
    var sessions = sessionRepository.findAbandonedBefore(cutoff);
    if (sessions.isEmpty()) {
      return;
    }

    for (var session : sessions) {
      var step = OnboardingStep.fromKey(session.getCurrentStep());
      var resumeUrl = reminderProperties.getResumeBaseUrl() + step.routePath();
      eventPublisher.publishAbandonedOnboarding(
          props.getNotification().getTenantId(),
          session.getPhone(),
          session.getEmail(),
          session.getFirstName(),
          step.label(),
          resumeUrl);
      session.setReminderSentAt(Instant.now());
      sessionRepository.save(session);
      log.info("Queued abandoned onboarding reminder for {} at step {}", session.getPhone(), step.key());
    }
  }
}
