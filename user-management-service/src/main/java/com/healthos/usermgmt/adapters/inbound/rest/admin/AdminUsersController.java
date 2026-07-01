package com.healthos.usermgmt.adapters.inbound.rest.admin;

import com.healthos.usermgmt.adapters.inbound.rest.dto.AdminDtos;
import com.healthos.usermgmt.adapters.inbound.rest.mappers.AdminMapper;
import com.healthos.usermgmt.application.AccountAdminService;
import com.healthos.usermgmt.shared.domain.AccountType;
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
  private final AccountAdminService accountAdminService;
  private final AdminMapper mapper;

  @GetMapping
  public List<AdminDtos.UserResponse> list() {
    return accountAdminService.listAccounts().stream().map(mapper::toUserResponse).toList();
  }

  @GetMapping("/{id}")
  public AdminDtos.UserResponse get(@PathVariable UUID id) {
    return mapper.toUserResponse(accountAdminService.getAccount(id));
  }

  @PutMapping("/{id}/status")
  public AdminDtos.UserResponse updateStatus(
      @PathVariable UUID id, @Valid @RequestBody AdminDtos.UpdateUserStatusRequest req) {
    return mapper.toUserResponse(accountAdminService.updateStatus(id, req.getStatus()));
  }

  @PutMapping("/{id}/roles")
  public AdminDtos.UserResponse setRoles(
      @PathVariable UUID id, @Valid @RequestBody AdminDtos.SetUserRolesRequest req) {
    var account = accountAdminService.getAccount(id);
    if (account.accountType() != AccountType.STAFF) {
      throw new IllegalArgumentException("Roles can only be assigned to staff accounts");
    }
    return mapper.toUserResponse(accountAdminService.setStaffRoles(id, req.getRoles()));
  }
}
