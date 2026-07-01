package com.healthos.usermgmt.consumer.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(schema = "consumer", name = "onboarding_sessions")
public class ConsumerOnboardingSession {
  @Id private UUID id;

  @Column(nullable = false, length = 32)
  private String phone;

  @Column(name = "registration_token_hash", nullable = false, length = 128)
  private String registrationTokenHash;

  @Column(name = "current_step", nullable = false, length = 32)
  private String currentStep;

  @Column(name = "first_name", length = 80)
  private String firstName;

  @Column(length = 255)
  private String email;

  @Column(name = "last_activity_at", nullable = false)
  private Instant lastActivityAt;

  @Column(name = "reminder_sent_at")
  private Instant reminderSentAt;

  @Column(name = "completed_at")
  private Instant completedAt;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt;
}
