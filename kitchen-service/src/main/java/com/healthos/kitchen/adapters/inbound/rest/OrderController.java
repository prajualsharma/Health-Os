package com.healthos.kitchen.adapters.inbound.rest;

import com.healthos.kitchen.adapters.inbound.rest.dto.OrderDtos;
import com.healthos.kitchen.application.OrderService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/kitchen")
@RequiredArgsConstructor
public class OrderController {
  private final OrderService orderService;

  @GetMapping("/kitchens/{kitchenId}/orders")
  public List<OrderDtos.OrderResponse> list(
      @PathVariable UUID kitchenId,
      @RequestParam(value = "activeOnly", defaultValue = "false") boolean activeOnly) {
    return orderService.listForKitchen(kitchenId, activeOnly).stream()
        .map(OrderDtos.OrderResponse::from)
        .toList();
  }

  @PostMapping("/kitchens/{kitchenId}/orders")
  public OrderDtos.OrderResponse create(
      @PathVariable UUID kitchenId, @Valid @RequestBody OrderDtos.CreateOrderRequest req) {
    return OrderDtos.OrderResponse.from(orderService.create(kitchenId, req));
  }

  @PatchMapping("/orders/{orderId}/status")
  public OrderDtos.OrderResponse updateStatus(
      @PathVariable UUID orderId, @Valid @RequestBody OrderDtos.UpdateOrderStatusRequest req) {
    return OrderDtos.OrderResponse.from(orderService.updateStatus(orderId, req.status()));
  }
}
