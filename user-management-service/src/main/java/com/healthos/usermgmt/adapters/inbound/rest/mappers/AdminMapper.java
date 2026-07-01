package com.healthos.usermgmt.adapters.inbound.rest.mappers;

import com.healthos.usermgmt.adapters.inbound.rest.dto.AdminDtos;
import com.healthos.usermgmt.application.AccountAdminService.AdminAccountView;
import com.healthos.usermgmt.domain.Permission;
import com.healthos.usermgmt.domain.Role;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface AdminMapper {
  @Mapping(target = "roles", source = "roles")
  AdminDtos.UserResponse toUserResponse(AdminAccountView account);

  AdminDtos.RoleResponse toRoleResponse(Role role);

  AdminDtos.PermissionResponse toPermissionResponse(Permission permission);
}
