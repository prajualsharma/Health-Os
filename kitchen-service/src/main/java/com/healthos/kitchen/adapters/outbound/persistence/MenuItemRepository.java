package com.healthos.kitchen.adapters.outbound.persistence;

import com.healthos.kitchen.domain.MenuItem;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MenuItemRepository extends JpaRepository<MenuItem, UUID> {
  List<MenuItem> findByKitchenIdOrderByCategoryAscNameAsc(UUID kitchenId);
}
