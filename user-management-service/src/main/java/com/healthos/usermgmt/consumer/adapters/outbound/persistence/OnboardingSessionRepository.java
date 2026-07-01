package com.healthos.usermgmt.consumer.adapters.outbound.persistence;

import com.healthos.usermgmt.consumer.domain.ConsumerOnboardingSession;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface OnboardingSessionRepository extends JpaRepository<ConsumerOnboardingSession, UUID> {
  Optional<ConsumerOnboardingSession> findByRegistrationTokenHashAndCompletedAtIsNull(
      String registrationTokenHash);

  Optional<ConsumerOnboardingSession> findByPhoneAndCompletedAtIsNull(String phone);

  @Query(
      """
      SELECT s FROM ConsumerOnboardingSession s
      WHERE s.completedAt IS NULL
        AND s.reminderSentAt IS NULL
        AND s.lastActivityAt < :cutoff
      """)
  List<ConsumerOnboardingSession> findAbandonedBefore(@Param("cutoff") Instant cutoff);
}
