package com.healthos.usermgmt.application;

import com.healthos.usermgmt.adapters.outbound.persistence.PermissionRepository;
import com.healthos.usermgmt.domain.Permission;
import jakarta.transaction.Transactional;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PermissionAdminService {
  private final PermissionRepository permissionRepository;

  public List<Permission> list() {
    return permissionRepository.findAll();
  }

  public Permission get(UUID id) {
    return permissionRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Permission not found"));
  }

  @Transactional
  public Permission create(String name, String description) {
    if (permissionRepository.existsByName(name)) {
      throw new IllegalArgumentException("Permission already exists");
    }
    var p = new Permission();
    p.setId(UUID.randomUUID());
    p.setName(name);
    p.setDescription(description);
    p.setCreatedAt(Instant.now());
    return permissionRepository.save(p);
  }

  @Transactional
  public Permission update(UUID id, String description) {
    var p = get(id);
    p.setDescription(description);
    return permissionRepository.save(p);
  }

  @Transactional
  public void delete(UUID id) {
    permissionRepository.delete(get(id));
  }
}

