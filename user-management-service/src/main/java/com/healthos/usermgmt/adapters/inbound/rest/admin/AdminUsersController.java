package com.healthos.usermgmt.adapters.inbound.rest.admin;

import com.healthos.usermgmt.adapters.inbound.rest.dto.AdminDtos;
import com.healthos.usermgmt.adapters.inbound.rest.mappers.AdminMapper;
import com.healthos.usermgmt.application.UserAdminService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin/users")
@RequiredArgsConstructor
@PreAuthorize("hasRole('SUPER_ADMIN') or hasRole('ADMIN')")
public class AdminUsersController {
  private final UserAdminService userAdminService;
  private final AdminMapper mapper;

  @GetMapping
  public List<AdminDtos.UserResponse> list() {
    return userAdminService.listUsers().stream().map(mapper::toUserResponse).toList();
  }

  @GetMapping("/{id}")
  public AdminDtos.UserResponse get(@PathVariable UUID id) {
    return mapper.toUserResponse(userAdminService.getUser(id));
  }

  @PutMapping("/{id}/status")
  public AdminDtos.UserResponse updateStatus(
      @PathVariable UUID id, @Valid @RequestBody AdminDtos.UpdateUserStatusRequest req) {
    return mapper.toUserResponse(userAdminService.updateStatus(id, req.getStatus()));
  }

  @PutMapping("/{id}/roles")
  public AdminDtos.UserResponse setRoles(
      @PathVariable UUID id, @Valid @RequestBody AdminDtos.SetUserRolesRequest req) {
    return mapper.toUserResponse(userAdminService.setRoles(id, req.getRoles()));
  }
}

