package com.healthos.usermgmt.adapters.inbound.rest.admin;

import com.healthos.usermgmt.adapters.inbound.rest.dto.AdminDtos;
import com.healthos.usermgmt.adapters.inbound.rest.mappers.AdminMapper;
import com.healthos.usermgmt.application.PermissionAdminService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin/permissions")
@RequiredArgsConstructor
@PreAuthorize("hasRole('SUPER_ADMIN') or hasRole('ADMIN')")
public class AdminPermissionsController {
  private final PermissionAdminService permissionAdminService;
  private final AdminMapper mapper;

  @GetMapping
  public List<AdminDtos.PermissionResponse> list() {
    return permissionAdminService.list().stream().map(mapper::toPermissionResponse).toList();
  }

  @PostMapping
  public AdminDtos.PermissionResponse create(@Valid @RequestBody AdminDtos.PermissionRequest req) {
    return mapper.toPermissionResponse(permissionAdminService.create(req.getName(), req.getDescription()));
  }

  @PutMapping("/{id}")
  public AdminDtos.PermissionResponse update(
      @PathVariable UUID id, @Valid @RequestBody AdminDtos.PermissionUpdateRequest req) {
    return mapper.toPermissionResponse(permissionAdminService.update(id, req.getDescription()));
  }

  @DeleteMapping("/{id}")
  public void delete(@PathVariable UUID id) {
    permissionAdminService.delete(id);
  }
}

