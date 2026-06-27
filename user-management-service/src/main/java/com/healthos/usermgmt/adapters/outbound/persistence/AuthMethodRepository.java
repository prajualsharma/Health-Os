package com.healthos.usermgmt.adapters.outbound.persistence;

import com.healthos.usermgmt.domain.AuthMethod;
import com.healthos.usermgmt.domain.AuthMethodType;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AuthMethodRepository extends JpaRepository<AuthMethod, UUID> {
  Optional<AuthMethod> findByMethodAndIdentifier(AuthMethodType method, String identifier);

  boolean existsByMethodAndIdentifier(AuthMethodType method, String identifier);
}
