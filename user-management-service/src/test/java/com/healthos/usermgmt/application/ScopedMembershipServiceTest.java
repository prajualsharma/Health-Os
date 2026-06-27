package com.healthos.usermgmt.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.healthos.usermgmt.adapters.outbound.persistence.RoleRepository;
import com.healthos.usermgmt.adapters.outbound.persistence.ScopedMembershipRepository;
import com.healthos.usermgmt.adapters.outbound.persistence.UserRepository;
import com.healthos.usermgmt.domain.MembershipClaim;
import com.healthos.usermgmt.domain.MembershipStatus;
import com.healthos.usermgmt.domain.PortalType;
import com.healthos.usermgmt.domain.ScopeType;
import com.healthos.usermgmt.domain.ScopedMembership;
import com.healthos.usermgmt.domain.ScopedRoleName;
import com.healthos.usermgmt.domain.User;
import com.healthos.usermgmt.domain.UserStatus;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;

class ScopedMembershipServiceTest {
  private ScopedMembershipRepository membershipRepository;
  private UserRepository userRepository;
  private RoleRepository roleRepository;
  private ScopeAuthorizationService authorizationService;
  private ScopedMembershipService service;

  private final UUID ownerId = UUID.randomUUID();
  private final UUID managerId = UUID.randomUUID();
  private final UUID orgId = UUID.randomUUID();
  private final UUID gymAId = UUID.randomUUID();
  private final UUID gymBId = UUID.randomUUID();

  @BeforeEach
  void setUp() {
    membershipRepository = Mockito.mock(ScopedMembershipRepository.class);
    userRepository = Mockito.mock(UserRepository.class);
    roleRepository = Mockito.mock(RoleRepository.class);
    authorizationService = Mockito.mock(ScopeAuthorizationService.class);
    service =
        new ScopedMembershipService(
            membershipRepository, userRepository, roleRepository, authorizationService);
    when(roleRepository.existsByName(any())).thenReturn(true);
  }

  @Test
  void ownerAssignsDifferentManagersPerGym() {
    var ownerMemberships =
        List.of(new MembershipClaim(PortalType.GYM, ScopeType.ORGANIZATION, orgId, ScopedRoleName.GYM_OWNER));

    when(authorizationService.canAssignMembership(any(), any(), any(), any(), any(), any(), any()))
        .thenReturn(true);
    when(userRepository.findById(managerId)).thenReturn(Optional.of(activeUser(managerId)));
    when(membershipRepository.findByUserIdAndPortalTypeAndScopeTypeAndScopeIdAndRoleName(
            any(), any(), any(), any(), any()))
        .thenReturn(Optional.empty());
    when(membershipRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

    service.assign(
        ownerId,
        Set.of(ScopedRoleName.GYM_OWNER),
        ownerMemberships,
        managerId,
        PortalType.GYM,
        ScopeType.LOCATION,
        gymAId,
        ScopedRoleName.GYM_MANAGER);

    service.assign(
        ownerId,
        Set.of(ScopedRoleName.GYM_OWNER),
        ownerMemberships,
        managerId,
        PortalType.GYM,
        ScopeType.LOCATION,
        gymBId,
        ScopedRoleName.GYM_MANAGER);

    var captor = ArgumentCaptor.forClass(ScopedMembership.class);
    verify(membershipRepository, Mockito.times(2)).save(captor.capture());
    assertThat(captor.getAllValues())
        .extracting(ScopedMembership::getScopeId)
        .containsExactlyInAnyOrder(gymAId, gymBId);
  }

  @Test
  void assignRejectsUnauthorizedActor() {
    when(authorizationService.canAssignMembership(any(), any(), any(), any(), any(), any(), any()))
        .thenReturn(false);

    assertThatThrownBy(
            () ->
                service.assign(
                    managerId,
                    Set.of(),
                    List.of(
                        new MembershipClaim(
                            PortalType.GYM, ScopeType.LOCATION, gymAId, ScopedRoleName.GYM_MANAGER)),
                    managerId,
                    PortalType.GYM,
                    ScopeType.LOCATION,
                    gymBId,
                    ScopedRoleName.STAFF))
        .isInstanceOf(SecurityException.class);
  }

  @Test
  void revokeSetsMembershipStatusRevoked() {
    var membership = new ScopedMembership();
    membership.setId(UUID.randomUUID());
    membership.setPortalType(PortalType.GYM);
    membership.setScopeType(ScopeType.LOCATION);
    membership.setScopeId(gymAId);
    membership.setStatus(MembershipStatus.ACTIVE);

    when(membershipRepository.findById(membership.getId())).thenReturn(Optional.of(membership));
    when(authorizationService.canManageScope(any(), any(), any(), any(), any(), any())).thenReturn(true);
    when(membershipRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

    service.revoke(
        ownerId,
        Set.of(ScopedRoleName.GYM_OWNER),
        List.of(new MembershipClaim(PortalType.GYM, ScopeType.ORGANIZATION, orgId, ScopedRoleName.GYM_OWNER)),
        membership.getId());

    assertThat(membership.getStatus()).isEqualTo(MembershipStatus.REVOKED);
  }

  private static User activeUser(UUID id) {
    var user = new User();
    user.setId(id);
    user.setFirstName("Test");
    user.setEmail("test@example.com");
    user.setPassword("hash");
    user.setStatus(UserStatus.ACTIVE);
    user.setCreatedAt(Instant.now());
    user.setUpdatedAt(Instant.now());
    return user;
  }
}
