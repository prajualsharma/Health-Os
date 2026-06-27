package com.healthos.kitchen.application;

import com.healthos.kitchen.adapters.inbound.rest.dto.MenuDtos;
import com.healthos.kitchen.adapters.outbound.persistence.MenuItemRepository;
import com.healthos.kitchen.domain.MenuItem;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MenuService {
  private final MenuItemRepository menuItemRepository;

  public List<MenuItem> listForKitchen(UUID kitchenId) {
    return menuItemRepository.findByKitchenIdOrderByCategoryAscNameAsc(kitchenId);
  }

  @Transactional
  public MenuItem create(UUID kitchenId, MenuDtos.CreateMenuItemRequest req) {
    var item = new MenuItem();
    item.setId(UUID.randomUUID());
    item.setKitchenId(kitchenId);
    item.setName(req.name());
    item.setDescription(req.description());
    item.setCategory(req.category());
    item.setPriceCents(req.priceCents());
    item.setVeg(req.veg());
    item.setAvailable(req.available() == null || req.available());
    item.setCreatedAt(Instant.now());
    return menuItemRepository.save(item);
  }

  @Transactional
  public MenuItem update(UUID itemId, MenuDtos.UpdateMenuItemRequest req) {
    var item =
        menuItemRepository
            .findById(itemId)
            .orElseThrow(() -> new NotFoundException("Menu item not found: " + itemId));
    if (req.name() != null) item.setName(req.name());
    if (req.description() != null) item.setDescription(req.description());
    if (req.category() != null) item.setCategory(req.category());
    if (req.priceCents() != null) item.setPriceCents(req.priceCents());
    if (req.veg() != null) item.setVeg(req.veg());
    if (req.available() != null) item.setAvailable(req.available());
    return menuItemRepository.save(item);
  }
}
