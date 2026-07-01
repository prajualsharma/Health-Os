package com.healthos.usermgmt.consumer.adapters.outbound.persistence;

import com.healthos.usermgmt.consumer.domain.ConsumerAccount;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ConsumerAccountRepository extends JpaRepository<ConsumerAccount, UUID> {
  Optional<ConsumerAccount> findByPhone(String phone);

  Optional<ConsumerAccount> findByEmail(String email);

  boolean existsByEmail(String email);
}
