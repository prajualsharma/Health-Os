package com.healthos.kitchen.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "order_lines")
@Getter
@Setter
@NoArgsConstructor
public class OrderLine {
  @Id private UUID id;

  @ManyToOne(optional = false)
  @JoinColumn(name = "order_id", nullable = false)
  private FoodOrder order;

  @Column(name = "menu_item_id")
  private UUID menuItemId;

  @Column(nullable = false, length = 120)
  private String name;

  @Column(nullable = false)
  private int quantity;

  @Column(name = "price_cents", nullable = false)
  private int priceCents;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt = Instant.now();
}
