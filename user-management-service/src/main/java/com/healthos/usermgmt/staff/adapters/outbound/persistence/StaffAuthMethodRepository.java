package com.healthos.usermgmt.staff.adapters.outbound.persistence;

import com.healthos.usermgmt.domain.AuthMethodType;
import com.healthos.usermgmt.staff.domain.StaffAuthMethod;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StaffAuthMethodRepository extends JpaRepository<StaffAuthMethod, UUID> {
  Optional<StaffAuthMethod> findByMethodAndIdentifier(AuthMethodType method, String identifier);

  boolean existsByMethodAndIdentifier(AuthMethodType method, String identifier);
}
