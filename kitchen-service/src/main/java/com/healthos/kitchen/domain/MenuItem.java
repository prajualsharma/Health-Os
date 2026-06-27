package com.healthos.kitchen.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "menu_items")
@Getter
@Setter
@NoArgsConstructor
public class MenuItem {
  @Id private UUID id;

  @Column(name = "kitchen_id", nullable = false)
  private UUID kitchenId;

  @Column(nullable = false, length = 120)
  private String name;

  @Column(length = 255)
  private String description;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 16)
  private MealCategory category;

  /** Price in minor units (paise/cents). */
  @Column(name = "price_cents", nullable = false)
  private int priceCents;

  @Column(nullable = false)
  private boolean veg = true;

  @Column(nullable = false)
  private boolean available = true;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt = Instant.now();
}
