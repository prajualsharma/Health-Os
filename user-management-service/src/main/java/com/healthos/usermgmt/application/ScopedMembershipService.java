package com.healthos.usermgmt.application;

import com.healthos.usermgmt.adapters.outbound.persistence.RoleRepository;
import com.healthos.usermgmt.adapters.outbound.persistence.ScopedMembershipRepository;
import com.healthos.usermgmt.adapters.outbound.persistence.UserRepository;
import com.healthos.usermgmt.domain.MembershipClaim;
import com.healthos.usermgmt.domain.MembershipStatus;
import com.healthos.usermgmt.domain.PortalType;
import com.healthos.usermgmt.domain.ScopeType;
import com.healthos.usermgmt.domain.ScopedMembership;
import jakarta.transaction.Transactional;
import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ScopedMembershipService {
  private final ScopedMembershipRepository membershipRepository;
  private final UserRepository userRepository;
  private final RoleRepository roleRepository;
  private final ScopeAuthorizationService authorizationService;

  public List<MembershipClaim> listClaimsForUser(UUID userId) {
    return membershipRepository.findByUserIdAndStatus(userId, MembershipStatus.ACTIVE).stream()
        .map(this::toClaim)
        .toList();
  }

  public List<ScopedMembership> listForUser(UUID userId) {
    return membershipRepository.findByUserIdAndStatus(userId, MembershipStatus.ACTIVE);
  }

  public List<ScopedMembership> listForScope(PortalType portalType, ScopeType scopeType, UUID scopeId) {
    return membershipRepository.findByScopeTypeAndScopeIdAndStatus(scopeType, scopeId, MembershipStatus.ACTIVE)
        .stream()
        .filter(m -> m.getPortalType() == portalType)
        .toList();
  }

  @Transactional
  public ScopedMembership assignInternal(
      UUID targetUserId,
      PortalType portalType,
      ScopeType scopeType,
      UUID scopeId,
      String roleName) {
    return persistMembership(targetUserId, portalType, scopeType, scopeId, roleName);
  }

  @Transactional
  public ScopedMembership assign(
      UUID actorId,
      Set<String> globalRoles,
      List<MembershipClaim> actorMemberships,
      UUID targetUserId,
      PortalType portalType,
      ScopeType scopeType,
      UUID scopeId,
      String roleName) {
    if (!roleRepository.existsByName(roleName)) {
      throw new IllegalArgumentException("Unknown role: " + roleName);
    }

    if (!authorizationService.canAssignMembership(
        actorId, globalRoles, actorMemberships, portalType, scopeType, scopeId, roleName)) {
      throw new SecurityException("Not authorized to assign role " + roleName);
    }

    return persistMembership(targetUserId, portalType, scopeType, scopeId, roleName);
  }

  private ScopedMembership persistMembership(
      UUID targetUserId,
      PortalType portalType,
      ScopeType scopeType,
      UUID scopeId,
      String roleName) {
    var targetUser =
        userRepository.findById(targetUserId).orElseThrow(() -> new IllegalArgumentException("User not found"));

    var existing =
        membershipRepository.findByUserIdAndPortalTypeAndScopeTypeAndScopeIdAndRoleName(
            targetUserId, portalType, scopeType, scopeId, roleName);

    if (existing.isPresent()) {
      var membership = existing.get();
      if (membership.getStatus() == MembershipStatus.ACTIVE) {
        return membership;
      }
      membership.setStatus(MembershipStatus.ACTIVE);
      return membershipRepository.save(membership);
    }

    var membership = new ScopedMembership();
    membership.setId(UUID.randomUUID());
    membership.setUser(targetUser);
    membership.setPortalType(portalType);
    membership.setScopeType(scopeType);
    membership.setScopeId(scopeId);
    membership.setRoleName(roleName);
    membership.setStatus(MembershipStatus.ACTIVE);
    membership.setCreatedAt(Instant.now());
    return membershipRepository.save(membership);
  }

  @Transactional
  public void revoke(
      UUID actorId,
      Set<String> globalRoles,
      List<MembershipClaim> actorMemberships,
      UUID membershipId) {
    var membership =
        membershipRepository
            .findById(membershipId)
            .orElseThrow(() -> new IllegalArgumentException("Membership not found"));

    if (membership.getStatus() == MembershipStatus.REVOKED) {
      return;
    }

    if (!authorizationService.canManageScope(
        actorId,
        globalRoles,
        actorMemberships,
        membership.getPortalType(),
        membership.getScopeType(),
        membership.getScopeId())) {
      throw new SecurityException("Not authorized to revoke this membership");
    }

    membership.setStatus(MembershipStatus.REVOKED);
    membershipRepository.save(membership);
  }

  public List<MembershipClaim> resolveAccessibleScopes(UUID userId, PortalType portalType) {
    return listClaimsForUser(userId).stream().filter(m -> m.portal() == portalType).toList();
  }

  private MembershipClaim toClaim(ScopedMembership membership) {
    return new MembershipClaim(
        membership.getPortalType(),
        membership.getScopeType(),
        membership.getScopeId(),
        membership.getRoleName());
  }
}
