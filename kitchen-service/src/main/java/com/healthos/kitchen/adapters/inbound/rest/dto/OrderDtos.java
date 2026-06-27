package com.healthos.kitchen.adapters.inbound.rest.dto;

import com.healthos.kitchen.domain.FoodOrder;
import com.healthos.kitchen.domain.OrderStatus;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public final class OrderDtos {
  private OrderDtos() {}

  public record CreateOrderRequest(
      @NotBlank String customerName,
      String customerPhone,
      @NotEmpty @Valid List<OrderLineRequest> items) {}

  public record OrderLineRequest(
      UUID menuItemId, @NotBlank String name, @Positive int quantity, int priceCents) {}

  public record UpdateOrderStatusRequest(@NotNull OrderStatus status) {}

  public record OrderLineResponse(UUID id, UUID menuItemId, String name, int quantity, int priceCents) {}

  public record OrderResponse(
      UUID id,
      UUID kitchenId,
      String orderCode,
      String customerName,
      String customerPhone,
      String status,
      int totalCents,
      List<OrderLineResponse> items,
      Instant createdAt,
      Instant updatedAt) {
    public static OrderResponse from(FoodOrder o) {
      var lines =
          o.getItems().stream()
              .map(
                  l ->
                      new OrderLineResponse(
                          l.getId(), l.getMenuItemId(), l.getName(), l.getQuantity(), l.getPriceCents()))
              .toList();
      return new OrderResponse(
          o.getId(),
          o.getKitchenId(),
          o.getOrderCode(),
          o.getCustomerName(),
          o.getCustomerPhone(),
          o.getStatus().name(),
          o.getTotalCents(),
          lines,
          o.getCreatedAt(),
          o.getUpdatedAt());
    }
  }
}
