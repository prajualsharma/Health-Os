package com.healthos.usermgmt.application;

import com.healthos.usermgmt.adapters.outbound.persistence.PermissionRepository;
import com.healthos.usermgmt.adapters.outbound.persistence.RoleRepository;
import com.healthos.usermgmt.domain.Permission;
import com.healthos.usermgmt.domain.Role;
import jakarta.transaction.Transactional;
import java.time.Instant;
import java.util.HashSet;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RoleAdminService {
  private final RoleRepository roleRepository;
  private final PermissionRepository permissionRepository;

  public List<Role> list() {
    return roleRepository.findAll();
  }

  public Role get(UUID id) {
    return roleRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Role not found"));
  }

  @Transactional
  public Role create(String name, String description) {
    if (roleRepository.existsByName(name)) {
      throw new IllegalArgumentException("Role already exists");
    }
    var r = new Role();
    r.setId(UUID.randomUUID());
    r.setName(name);
    r.setDescription(description);
    r.setCreatedAt(Instant.now());
    return roleRepository.save(r);
  }

  @Transactional
  public Role update(UUID id, String description) {
    var r = get(id);
    r.setDescription(description);
    return roleRepository.save(r);
  }

  @Transactional
  public Role setPermissions(UUID roleId, List<String> permissionNames) {
    var role = get(roleId);
    var permissions = new HashSet<Permission>();
    for (var name : permissionNames) {
      permissions.add(
          permissionRepository
              .findByName(name)
              .orElseThrow(() -> new IllegalArgumentException("Permission not found: " + name)));
    }
    role.setPermissions(permissions);
    return roleRepository.save(role);
  }

  @Transactional
  public void delete(UUID id) {
    roleRepository.delete(get(id));
  }
}

