package com.healthos.usermgmt.adapters.inbound.rest.mappers;

import com.healthos.usermgmt.adapters.inbound.rest.dto.AdminDtos;
import com.healthos.usermgmt.domain.Permission;
import com.healthos.usermgmt.domain.Role;
import com.healthos.usermgmt.domain.User;
import java.util.Set;
import java.util.stream.Collectors;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface AdminMapper {
  @Mapping(target = "roles", expression = "java(mapRoles(user))")
  AdminDtos.UserResponse toUserResponse(User user);

  AdminDtos.RoleResponse toRoleResponse(Role role);

  AdminDtos.PermissionResponse toPermissionResponse(Permission permission);

  default Set<String> mapRoles(User user) {
    if (user.getRoles() == null) return Set.of();
    return user.getRoles().stream().map(Role::getName).collect(Collectors.toUnmodifiableSet());
  }
}

