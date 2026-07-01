package com.healthos.usermgmt.staff.adapters.outbound.persistence;

import com.healthos.usermgmt.staff.domain.StaffAccount;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StaffAccountRepository extends JpaRepository<StaffAccount, UUID> {
  Optional<StaffAccount> findByPhone(String phone);

  boolean existsByEmail(String email);
}
