package com.healthos.kitchen.application;

import com.healthos.kitchen.adapters.inbound.rest.dto.OrderDtos;
import com.healthos.kitchen.adapters.outbound.persistence.FoodOrderRepository;
import com.healthos.kitchen.domain.FoodOrder;
import com.healthos.kitchen.domain.OrderLine;
import com.healthos.kitchen.domain.OrderStatus;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class OrderService {
  private final FoodOrderRepository orderRepository;

  public List<FoodOrder> listForKitchen(UUID kitchenId, boolean activeOnly) {
    if (activeOnly) {
      return orderRepository.findByKitchenIdAndStatusInOrderByCreatedAtAsc(
          kitchenId,
          List.of(OrderStatus.NEW, OrderStatus.ACCEPTED, OrderStatus.PREPARING, OrderStatus.READY));
    }
    return orderRepository.findByKitchenIdOrderByCreatedAtDesc(kitchenId);
  }

  @Transactional
  public FoodOrder create(UUID kitchenId, OrderDtos.CreateOrderRequest req) {
    var order = new FoodOrder();
    order.setId(UUID.randomUUID());
    order.setKitchenId(kitchenId);
    order.setOrderCode(generateCode());
    order.setCustomerName(req.customerName());
    order.setCustomerPhone(req.customerPhone());
    order.setStatus(OrderStatus.NEW);
    order.setCreatedAt(Instant.now());
    order.setUpdatedAt(Instant.now());

    int total = 0;
    for (var line : req.items()) {
      var ol = new OrderLine();
      ol.setId(UUID.randomUUID());
      ol.setMenuItemId(line.menuItemId());
      ol.setName(line.name());
      ol.setQuantity(line.quantity());
      ol.setPriceCents(line.priceCents());
      ol.setCreatedAt(Instant.now());
      order.addItem(ol);
      total += line.priceCents() * line.quantity();
    }
    order.setTotalCents(total);
    return orderRepository.save(order);
  }

  @Transactional
  public FoodOrder updateStatus(UUID orderId, OrderStatus next) {
    var order =
        orderRepository
            .findById(orderId)
            .orElseThrow(() -> new NotFoundException("Order not found: " + orderId));
    if (order.getStatus() == next) {
      return order;
    }
    if (!order.getStatus().canTransitionTo(next)) {
      throw new IllegalStateException(
          "Cannot transition order from " + order.getStatus() + " to " + next);
    }
    order.setStatus(next);
    order.setUpdatedAt(Instant.now());
    return orderRepository.save(order);
  }

  private static String generateCode() {
    return "ORD-" + String.format("%05d", ThreadLocalRandom.current().nextInt(100000));
  }
}
