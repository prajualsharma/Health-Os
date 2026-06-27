package com.healthos.usermgmt.adapters.outbound.persistence;

import com.healthos.usermgmt.domain.UserProfile;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserProfileRepository extends JpaRepository<UserProfile, UUID> {}

