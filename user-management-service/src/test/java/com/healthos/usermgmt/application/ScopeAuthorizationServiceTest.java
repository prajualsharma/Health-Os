package com.healthos.usermgmt.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

import com.healthos.usermgmt.adapters.outbound.persistence.RoleRepository;
import com.healthos.usermgmt.adapters.outbound.persistence.ScopedMembershipRepository;
import com.healthos.usermgmt.domain.MembershipClaim;
import com.healthos.usermgmt.domain.MembershipStatus;
import com.healthos.usermgmt.domain.Permission;
import com.healthos.usermgmt.domain.PortalType;
import com.healthos.usermgmt.domain.Role;
import com.healthos.usermgmt.domain.ScopeType;
import com.healthos.usermgmt.domain.ScopedRoleName;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

class ScopeAuthorizationServiceTest {
  private ScopedMembershipRepository membershipRepository;
  private RoleRepository roleRepository;
  private ScopeAuthorizationService service;

  private final UUID ownerId = UUID.randomUUID();
  private final UUID managerAId = UUID.randomUUID();
  private final UUID orgId = UUID.randomUUID();
  private final UUID gymAId = UUID.randomUUID();
  private final UUID gymBId = UUID.randomUUID();

  @BeforeEach
  void setUp() {
    membershipRepository = Mockito.mock(ScopedMembershipRepository.class);
    roleRepository = Mockito.mock(RoleRepository.class);
    service = new ScopeAuthorizationService(membershipRepository, roleRepository);

    when(roleRepository.findByName(ScopedRoleName.GYM_OWNER))
        .thenReturn(Optional.of(roleWithPerm(ScopeAuthorizationService.PERM_MANAGE_MEMBERSHIP)));
    when(roleRepository.findByName(ScopedRoleName.GYM_MANAGER))
        .thenReturn(Optional.of(roleWithPerm(ScopeAuthorizationService.PERM_MANAGE_MEMBERSHIP)));
  }

  @Test
  void ownerCanAssignManagerToAnyLocation() {
    var ownerMemberships =
        List.of(new MembershipClaim(PortalType.GYM, ScopeType.ORGANIZATION, orgId, ScopedRoleName.GYM_OWNER));

    assertThat(
            service.canAssignMembership(
                ownerId,
                Set.of(ScopedRoleName.GYM_OWNER),
                ownerMemberships,
                PortalType.GYM,
                ScopeType.LOCATION,
                gymAId,
                ScopedRoleName.GYM_MANAGER))
        .isTrue();
  }

  @Test
  void managerACannotAssignManagerToGymB() {
    var managerMemberships =
        List.of(new MembershipClaim(PortalType.GYM, ScopeType.LOCATION, gymAId, ScopedRoleName.GYM_MANAGER));

    when(membershipRepository.existsActiveMembership(
            eq(managerAId),
            eq(MembershipStatus.ACTIVE),
            eq(PortalType.GYM),
            eq(ScopeType.LOCATION),
            eq(gymBId),
            any()))
        .thenReturn(false);

    assertThat(
            service.canAssignMembership(
                managerAId,
                Set.of(),
                managerMemberships,
                PortalType.GYM,
                ScopeType.LOCATION,
                gymBId,
                ScopedRoleName.GYM_MANAGER))
        .isFalse();
  }

  @Test
  void managerACanInviteStaffToOwnGym() {
    var managerMemberships =
        List.of(new MembershipClaim(PortalType.GYM, ScopeType.LOCATION, gymAId, ScopedRoleName.GYM_MANAGER));

    when(membershipRepository.existsActiveMembership(
            eq(managerAId),
            eq(MembershipStatus.ACTIVE),
            eq(PortalType.GYM),
            eq(ScopeType.LOCATION),
            eq(gymAId),
            eq(List.of(ScopedRoleName.GYM_MANAGER))))
        .thenReturn(true);

    assertThat(
            service.canAssignMembership(
                managerAId,
                Set.of(),
                managerMemberships,
                PortalType.GYM,
                ScopeType.LOCATION,
                gymAId,
                ScopedRoleName.STAFF))
        .isTrue();
  }

  @Test
  void managerCannotManageDifferentGymScope() {
    var managerMemberships =
        List.of(new MembershipClaim(PortalType.GYM, ScopeType.LOCATION, gymAId, ScopedRoleName.GYM_MANAGER));

    when(membershipRepository.existsActiveMembership(
            eq(managerAId),
            eq(MembershipStatus.ACTIVE),
            eq(PortalType.GYM),
            eq(ScopeType.LOCATION),
            eq(gymBId),
            any()))
        .thenReturn(false);

    assertThat(
            service.canManageScope(
                managerAId,
                Set.of(),
                managerMemberships,
                PortalType.GYM,
                ScopeType.LOCATION,
                gymBId))
        .isFalse();
  }

  private static Role roleWithPerm(String permissionName) {
    var permission = new Permission();
    permission.setName(permissionName);
    var role = new Role();
    role.setName(ScopedRoleName.GYM_MANAGER);
    role.setPermissions(Set.of(permission));
    return role;
  }
}
