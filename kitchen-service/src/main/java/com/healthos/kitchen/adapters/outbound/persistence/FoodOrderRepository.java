package com.healthos.kitchen.adapters.outbound.persistence;

import com.healthos.kitchen.domain.FoodOrder;
import com.healthos.kitchen.domain.OrderStatus;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FoodOrderRepository extends JpaRepository<FoodOrder, UUID> {
  List<FoodOrder> findByKitchenIdOrderByCreatedAtDesc(UUID kitchenId);

  List<FoodOrder> findByKitchenIdAndStatusInOrderByCreatedAtAsc(
      UUID kitchenId, List<OrderStatus> statuses);
}
