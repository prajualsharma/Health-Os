package com.healthos.usermgmt.adapters.outbound.persistence;

import com.healthos.usermgmt.domain.User;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, UUID> {
  Optional<User> findByEmail(String email);
  Optional<User> findByPhone(String phone);
  boolean existsByEmail(String email);
}

