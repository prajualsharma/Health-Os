package com.healthos.usermgmt.adapters.inbound.rest.mappers;

import com.healthos.usermgmt.adapters.inbound.rest.dto.AdminDtos;
import com.healthos.usermgmt.application.AccountAdminService;
import com.healthos.usermgmt.domain.Permission;
import com.healthos.usermgmt.domain.Role;
import java.util.LinkedHashSet;
import java.util.Set;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-07-01T22:48:20+0530",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.11 (Ubuntu)"
)
@Component
public class AdminMapperImpl implements AdminMapper {

    @Override
    public AdminDtos.UserResponse toUserResponse(AccountAdminService.AdminAccountView account) {
        if ( account == null ) {
            return null;
        }

        AdminDtos.UserResponse userResponse = new AdminDtos.UserResponse();

        Set<String> set = account.roles();
        if ( set != null ) {
            userResponse.setRoles( new LinkedHashSet<String>( set ) );
        }
        userResponse.setId( account.id() );
        userResponse.setAccountType( account.accountType() );
        userResponse.setFirstName( account.firstName() );
        userResponse.setLastName( account.lastName() );
        userResponse.setEmail( account.email() );
        userResponse.setPhone( account.phone() );
        userResponse.setStatus( account.status() );
        userResponse.setCreatedAt( account.createdAt() );
        userResponse.setUpdatedAt( account.updatedAt() );

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
