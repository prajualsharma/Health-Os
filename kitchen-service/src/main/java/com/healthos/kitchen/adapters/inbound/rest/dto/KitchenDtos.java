package com.healthos.kitchen.adapters.inbound.rest.dto;

import com.healthos.kitchen.domain.Kitchen;
import jakarta.validation.constraints.NotBlank;
import java.time.Instant;
import java.util.UUID;

public final class KitchenDtos {
  private KitchenDtos() {}

  public record CreateKitchenRequest(
      @NotBlank String name, String address, String city, UUID orgId, UUID staffUserId) {}

  public record KitchenResponse(
      UUID id, UUID orgId, String name, String address, String city, String status, Instant createdAt) {
    public static KitchenResponse from(Kitchen k) {
      return new KitchenResponse(
          k.getId(),
          k.getOrgId(),
          k.getName(),
          k.getAddress(),
          k.getCity(),
          k.getStatus().name(),
          k.getCreatedAt());
    }
  }
}
