package com.healthos.usermgmt.consumer.adapters.outbound.persistence;

import com.healthos.usermgmt.consumer.domain.ConsumerAuthMethod;
import com.healthos.usermgmt.domain.AuthMethodType;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ConsumerAuthMethodRepository extends JpaRepository<ConsumerAuthMethod, UUID> {
  Optional<ConsumerAuthMethod> findByMethodAndIdentifier(AuthMethodType method, String identifier);

  boolean existsByMethodAndIdentifier(AuthMethodType method, String identifier);
}
