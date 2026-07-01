package com.healthos.usermgmt.adapters.inbound.rest.mappers;

import com.healthos.usermgmt.adapters.inbound.rest.dto.AdminDtos;
import com.healthos.usermgmt.domain.Permission;
import com.healthos.usermgmt.domain.Role;
import com.healthos.usermgmt.domain.User;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-07-01T17:01:19+0530",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.11 (Ubuntu)"
)
@Component
public class AdminMapperImpl implements AdminMapper {

    @Override
    public AdminDtos.UserResponse toUserResponse(User user) {
        if ( user == null ) {
            return null;
        }

        AdminDtos.UserResponse userResponse = new AdminDtos.UserResponse();

        userResponse.setId( user.getId() );
        userResponse.setFirstName( user.getFirstName() );
        userResponse.setLastName( user.getLastName() );
        userResponse.setEmail( user.getEmail() );
        userResponse.setPhone( user.getPhone() );
        userResponse.setStatus( user.getStatus() );
        userResponse.setCreatedAt( user.getCreatedAt() );
        userResponse.setUpdatedAt( user.getUpdatedAt() );

        userResponse.setRoles( mapRoles(user) );

        return userResponse;
    }

    @Override
    public AdminDtos.RoleResponse toRoleResponse(Role role) {
        if ( role == null ) {
            return null;
        }

        AdminDtos.RoleResponse roleResponse = new AdminDtos.RoleResponse();

        roleResponse.setId( role.getId() );
        roleResponse.setName( role.getName() );
        roleResponse.setDescription( role.getDescription() );

        return roleResponse;
    }

    @Override
    public AdminDtos.PermissionResponse toPermissionResponse(Permission permission) {
        if ( permission == null ) {
            return null;
        }

        AdminDtos.PermissionResponse permissionResponse = new AdminDtos.PermissionResponse();

        permissionResponse.setId( permission.getId() );
        permissionResponse.setName( permission.getName() );
        permissionResponse.setDescription( permission.getDescription() );

        return permissionResponse;
    }
}
