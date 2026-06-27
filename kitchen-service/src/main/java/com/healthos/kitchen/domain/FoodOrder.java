package com.healthos.kitchen.domain;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** A customer order allocated to a cloud kitchen. Named FoodOrder to avoid the SQL ORDER keyword. */
@Entity
@Table(name = "food_orders")
@Getter
@Setter
@NoArgsConstructor
public class FoodOrder {
  @Id private UUID id;

  @Column(name = "kitchen_id", nullable = false)
  private UUID kitchenId;

  @Column(name = "order_code", nullable = false, length = 16)
  private String orderCode;

  @Column(name = "customer_name", nullable = false, length = 120)
  private String customerName;

  @Column(name = "customer_phone", length = 32)
  private String customerPhone;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 16)
  private OrderStatus status = OrderStatus.NEW;

  @Column(name = "total_cents", nullable = false)
  private int totalCents;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt = Instant.now();

  @Column(name = "updated_at", nullable = false)
  private Instant updatedAt = Instant.now();

  @OneToMany(
      mappedBy = "order",
      cascade = CascadeType.ALL,
      orphanRemoval = true,
      fetch = FetchType.EAGER)
  @OrderBy("createdAt asc")
  private List<OrderLine> items = new ArrayList<>();

  public void addItem(OrderLine line) {
    line.setOrder(this);
    items.add(line);
  }
}
