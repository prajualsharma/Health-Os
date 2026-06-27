package com.healthos.kitchen.adapters.inbound.rest;

import com.healthos.kitchen.adapters.inbound.rest.dto.MenuDtos;
import com.healthos.kitchen.application.MenuService;
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
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/kitchen")
@RequiredArgsConstructor
public class MenuController {
  private final MenuService menuService;

  @GetMapping("/kitchens/{kitchenId}/menu")
  public List<MenuDtos.MenuItemResponse> list(@PathVariable UUID kitchenId) {
    return menuService.listForKitchen(kitchenId).stream()
        .map(MenuDtos.MenuItemResponse::from)
        .toList();
  }

  @PostMapping("/kitchens/{kitchenId}/menu")
  public MenuDtos.MenuItemResponse create(
      @PathVariable UUID kitchenId, @Valid @RequestBody MenuDtos.CreateMenuItemRequest req) {
    return MenuDtos.MenuItemResponse.from(menuService.create(kitchenId, req));
  }

  @PatchMapping("/menu/{itemId}")
  public MenuDtos.MenuItemResponse update(
      @PathVariable UUID itemId, @Valid @RequestBody MenuDtos.UpdateMenuItemRequest req) {
    return MenuDtos.MenuItemResponse.from(menuService.update(itemId, req));
  }
}
