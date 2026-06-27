package com.healthos.kitchen.application;

import com.healthos.kitchen.adapters.outbound.persistence.KitchenRepository;
import com.healthos.kitchen.adapters.outbound.usermgmt.UserManagementClient;
import com.healthos.kitchen.domain.Kitchen;
import com.healthos.kitchen.domain.KitchenStatus;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class KitchenService {
  private final KitchenRepository kitchenRepository;
  private final UserManagementClient userManagementClient;

  public List<Kitchen> list(UUID orgId) {
    if (orgId != null) {
      return kitchenRepository.findByOrgIdOrderByCreatedAtDesc(orgId);
    }
    return kitchenRepository.findAll();
  }

  public Kitchen get(UUID id) {
    return kitchenRepository
        .findById(id)
        .orElseThrow(() -> new NotFoundException("Kitchen not found: " + id));
  }

  @Transactional
  public Kitchen create(
      UUID orgId, String name, String address, String city, UUID staffUserId) {
    var kitchen = new Kitchen();
    kitchen.setId(UUID.randomUUID());
    kitchen.setOrgId(orgId);
    kitchen.setName(name);
    kitchen.setAddress(address);
    kitchen.setCity(city);
    kitchen.setStatus(KitchenStatus.ACTIVE);
    kitchen.setCreatedAt(Instant.now());
    var saved = kitchenRepository.save(kitchen);

    if (staffUserId != null) {
      userManagementClient.grantKitchenStaff(staffUserId, saved.getId());
    }
    return saved;
  }
}
