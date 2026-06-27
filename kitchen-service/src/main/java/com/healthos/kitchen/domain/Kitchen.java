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
@Table(name = "kitchens")
@Getter
@Setter
@NoArgsConstructor
public class Kitchen {
  @Id private UUID id;

  /** Organization (corporate) that owns this cloud kitchen; maps to a scoped-membership scope_id. */
  @Column(name = "org_id", nullable = false)
  private UUID orgId;

  @Column(nullable = false, length = 120)
  private String name;

  @Column(length = 255)
  private String address;

  @Column(length = 80)
  private String city;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 16)
  private KitchenStatus status = KitchenStatus.ACTIVE;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt = Instant.now();
}
