package com.healthos.usermgmt.adapters.inbound.rest.dto;

import com.healthos.usermgmt.domain.UserStatus;
import com.healthos.usermgmt.shared.domain.AccountType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import lombok.Data;

public class AdminDtos {
  @Data
  public static class UserResponse {
    private UUID id;
    private AccountType accountType;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private UserStatus status;
    private Instant createdAt;
    private Instant updatedAt;
    private Set<String> roles;
  }

  @Data
  public static class UpdateUserStatusRequest {
    @NotNull private UserStatus status;
  }

  @Data
  public static class SetUserRolesRequest {
    @NotNull @Size(min = 1) private List<@NotBlank String> roles;
  }

  @Data
  public static class RoleRequest {
    @NotBlank @Size(max = 64) private String name;
    @Size(max = 255) private String description;
  }

  @Data
  public static class RoleUpdateRequest {
    @Size(max = 255) private String description;
  }

  @Data
  public static class SetRolePermissionsRequest {
    @NotNull @Size(min = 0) private List<@NotBlank String> permissions;
  }

  @Data
  public static class RoleResponse {
    private UUID id;
    private String name;
    private String description;
  }

  @Data
  public static class PermissionRequest {
    @NotBlank @Size(max = 128) private String name;
    @Size(max = 255) private String description;
  }

  @Data
  public static class PermissionUpdateRequest {
    @Size(max = 255) private String description;
  }

  @Data
  public static class PermissionResponse {
    private UUID id;
    private String name;
    private String description;
  }
}

