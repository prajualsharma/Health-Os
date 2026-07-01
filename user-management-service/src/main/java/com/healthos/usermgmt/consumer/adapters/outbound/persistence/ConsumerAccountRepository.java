package com.healthos.usermgmt.consumer.adapters.outbound.persistence;

import com.healthos.usermgmt.consumer.domain.ConsumerAccount;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ConsumerAccountRepository extends JpaRepository<ConsumerAccount, UUID> {
  Optional<ConsumerAccount> findByPhone(String phone);

  boolean existsByEmail(String email);
}
