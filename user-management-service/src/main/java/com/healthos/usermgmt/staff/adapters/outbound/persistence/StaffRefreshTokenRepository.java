package com.healthos.usermgmt.staff.adapters.outbound.persistence;

import com.healthos.usermgmt.staff.domain.StaffRefreshToken;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StaffRefreshTokenRepository extends JpaRepository<StaffRefreshToken, UUID> {
  Optional<StaffRefreshToken> findByTokenHash(String tokenHash);
}
