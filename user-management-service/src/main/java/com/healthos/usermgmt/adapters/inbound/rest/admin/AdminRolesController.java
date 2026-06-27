package com.healthos.usermgmt.adapters.inbound.rest.admin;

import com.healthos.usermgmt.adapters.inbound.rest.dto.AdminDtos;
import com.healthos.usermgmt.adapters.inbound.rest.mappers.AdminMapper;
import com.healthos.usermgmt.application.RoleAdminService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin/roles")
@RequiredArgsConstructor
@PreAuthorize("hasRole('SUPER_ADMIN') or hasRole('ADMIN')")
public class AdminRolesController {
  private final RoleAdminService roleAdminService;
  private final AdminMapper mapper;

  @GetMapping
  public List<AdminDtos.RoleResponse> list() {
    return roleAdminService.list().stream().map(mapper::toRoleResponse).toList();
  }

  @PostMapping
  public AdminDtos.RoleResponse create(@Valid @RequestBody AdminDtos.RoleRequest req) {
    return mapper.toRoleResponse(roleAdminService.create(req.getName(), req.getDescription()));
  }

  @PutMapping("/{id}")
  public AdminDtos.RoleResponse update(@PathVariable UUID id, @Valid @RequestBody AdminDtos.RoleUpdateRequest req) {
    return mapper.toRoleResponse(roleAdminService.update(id, req.getDescription()));
  }

  @PutMapping("/{id}/permissions")
  public AdminDtos.RoleResponse setPermissions(
      @PathVariable UUID id, @Valid @RequestBody AdminDtos.SetRolePermissionsRequest req) {
    return mapper.toRoleResponse(roleAdminService.setPermissions(id, req.getPermissions()));
  }

  @DeleteMapping("/{id}")
  public void delete(@PathVariable UUID id) {
    roleAdminService.delete(id);
  }
}

