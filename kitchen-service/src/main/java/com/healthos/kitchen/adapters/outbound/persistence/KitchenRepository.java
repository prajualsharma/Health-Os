package com.healthos.kitchen.adapters.outbound.persistence;

import com.healthos.kitchen.domain.Kitchen;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface KitchenRepository extends JpaRepository<Kitchen, UUID> {
  List<Kitchen> findByOrgIdOrderByCreatedAtDesc(UUID orgId);
}
