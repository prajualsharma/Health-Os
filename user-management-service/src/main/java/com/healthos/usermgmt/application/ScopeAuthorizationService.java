package com.healthos.usermgmt.application;

import com.healthos.usermgmt.adapters.outbound.persistence.RoleRepository;
import com.healthos.usermgmt.adapters.outbound.persistence.ScopedMembershipRepository;
import com.healthos.usermgmt.domain.MembershipClaim;
import com.healthos.usermgmt.domain.PortalType;
import com.healthos.usermgmt.domain.ScopeType;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * Portal-agnostic authorization for scoped memberships. Authority is driven entirely by
 * permissions attached to the actor's scoped roles (looked up from the {@code roles} /
 * {@code role_permissions} catalog), so new portals (gym, kitchen, ...) and dynamically created
 * roles work without code changes - just attach the right permission to the role in the DB.
 */
@Service
@RequiredArgsConstructor
public class ScopeAuthorizationService {
  /** Authority to assign/revoke memberships within an applicable scope. */
  public static final String PERM_MANAGE_MEMBERSHIP = "scope:membership:manage";

  private final ScopedMembershipRepository membershipRepository;
  private final RoleRepository roleRepository;

  public boolean isPlatformAdmin(Set<String> globalRoles) {
    return globalRoles != null
        && (globalRoles.contains("SUPER_ADMIN") || globalRoles.contains("ADMIN"));
  }

  public boolean canAssignMembership(
      UUID actorId,
      Set<String> globalRoles,
      List<MembershipClaim> actorMemberships,
      PortalType portalType,
      ScopeType scopeType,
      UUID scopeId,
      String targetRoleName) {
    if (isPlatformAdmin(globalRoles)) {
      return true;
    }

    // Assigning a "privileged" role (one that can itself manage memberships, e.g. a manager/owner)
    // is restricted to platform admins or org-level managers within the same portal. This prevents
    // a location-level manager from minting peers/superiors.
    if (roleHasPermission(targetRoleName, PERM_MANAGE_MEMBERSHIP)) {
      return hasOrgScopedPermission(actorMemberships, portalType, PERM_MANAGE_MEMBERSHIP);
    }

    return hasScopedPermission(actorMemberships, portalType, scopeType, scopeId, PERM_MANAGE_MEMBERSHIP);
  }

  public boolean canManageScope(
      UUID actorId,
      Set<String> globalRoles,
      List<MembershipClaim> actorMemberships,
      PortalType portalType,
      ScopeType scopeType,
      UUID scopeId) {
    if (isPlatformAdmin(globalRoles)) {
      return true;
    }
    return hasScopedPermission(actorMemberships, portalType, scopeType, scopeId, PERM_MANAGE_MEMBERSHIP);
  }

  public boolean hasPermissionForScope(
      UUID actorId,
      Set<String> globalRoles,
      List<MembershipClaim> actorMemberships,
      PortalType portalType,
      ScopeType scopeType,
      UUID scopeId,
      String permission) {
    if (isPlatformAdmin(globalRoles)) {
      return true;
    }
    return hasScopedPermission(actorMemberships, portalType, scopeType, scopeId, permission);
  }

  /**
   * True if any of the actor's roles that apply to the given scope (direct membership at the scope,
   * or an organization-scoped membership in the same portal that covers child locations) carry the
   * requested permission.
   */
  private boolean hasScopedPermission(
      List<MembershipClaim> memberships,
      PortalType portalType,
      ScopeType scopeType,
      UUID scopeId,
      String permission) {
    for (var roleName : resolveApplicableScopedRoles(memberships, portalType, scopeType, scopeId)) {
      if (roleHasPermission(roleName, permission)) {
        return true;
      }
    }
    return false;
  }

  private boolean hasOrgScopedPermission(
      List<MembershipClaim> memberships, PortalType portalType, String permission) {
    if (memberships == null) {
      return false;
    }
    return memberships.stream()
        .filter(m -> m.portal() == portalType && m.scopeType() == ScopeType.ORGANIZATION)
        .map(MembershipClaim::role)
        .anyMatch(roleName -> roleHasPermission(roleName, permission));
  }

  private List<String> resolveApplicableScopedRoles(
      List<MembershipClaim> memberships, PortalType portalType, ScopeType scopeType, UUID scopeId) {
    if (memberships == null) {
      return List.of();
    }

    var roles = new ArrayList<String>();

    // Direct roles at the exact scope.
    memberships.stream()
        .filter(
            m ->
                m.portal() == portalType
                    && m.scopeType() == scopeType
                    && m.scopeId().equals(scopeId))
        .map(MembershipClaim::role)
        .forEach(roles::add);

    // Organization-scoped roles in the same portal cover their child locations.
    if (scopeType == ScopeType.LOCATION) {
      memberships.stream()
          .filter(m -> m.portal() == portalType && m.scopeType() == ScopeType.ORGANIZATION)
          .map(MembershipClaim::role)
          .forEach(roles::add);
    }

    return roles;
  }

  private boolean roleHasPermission(String roleName, String permission) {
    if (roleName == null) {
      return false;
    }
    return roleRepository
        .findByName(roleName)
        .map(role -> role.getPermissions().stream().anyMatch(p -> permission.equals(p.getName())))
        .orElse(false);
  }
}
