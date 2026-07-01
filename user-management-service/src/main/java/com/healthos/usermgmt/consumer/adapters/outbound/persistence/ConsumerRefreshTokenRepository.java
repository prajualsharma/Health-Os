package com.healthos.usermgmt.consumer.adapters.outbound.persistence;

import com.healthos.usermgmt.consumer.domain.ConsumerRefreshToken;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ConsumerRefreshTokenRepository extends JpaRepository<ConsumerRefreshToken, UUID> {
  Optional<ConsumerRefreshToken> findByTokenHash(String tokenHash);
}
