package com.healthos.kitchen.adapters.inbound.rest.dto;

import com.healthos.kitchen.domain.MealCategory;
import com.healthos.kitchen.domain.MenuItem;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import java.util.UUID;

public final class MenuDtos {
  private MenuDtos() {}

  public record CreateMenuItemRequest(
      @NotBlank String name,
      String description,
      @NotNull MealCategory category,
      @PositiveOrZero int priceCents,
      boolean veg,
      Boolean available) {}

  public record UpdateMenuItemRequest(
      String name, String description, MealCategory category, Integer priceCents, Boolean veg, Boolean available) {}

  public record MenuItemResponse(
      UUID id,
      UUID kitchenId,
      String name,
      String description,
      String category,
      int priceCents,
      boolean veg,
      boolean available) {
    public static MenuItemResponse from(MenuItem m) {
      return new MenuItemResponse(
          m.getId(),
          m.getKitchenId(),
          m.getName(),
          m.getDescription(),
          m.getCategory().name(),
          m.getPriceCents(),
          m.isVeg(),
          m.isAvailable());
    }
  }
}
