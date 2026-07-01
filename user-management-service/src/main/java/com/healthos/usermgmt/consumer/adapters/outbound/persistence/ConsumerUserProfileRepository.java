package com.healthos.usermgmt.consumer.adapters.outbound.persistence;

import com.healthos.usermgmt.consumer.domain.ConsumerUserProfile;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ConsumerUserProfileRepository extends JpaRepository<ConsumerUserProfile, UUID> {}
