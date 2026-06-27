package com.healthos.usermgmt.adapters.outbound.persistence;

import com.healthos.usermgmt.domain.MembershipStatus;
import com.healthos.usermgmt.domain.PortalType;
import com.healthos.usermgmt.domain.ScopeType;
import com.healthos.usermgmt.domain.ScopedMembership;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ScopedMembershipRepository extends JpaRepository<ScopedMembership, UUID> {
  List<ScopedMembership> findByUserIdAndStatus(UUID userId, MembershipStatus status);

  List<ScopedMembership> findByScopeTypeAndScopeIdAndStatus(
      ScopeType scopeType, UUID scopeId, MembershipStatus status);

  @Query(
      """
      select count(m) > 0 from ScopedMembership m
      where m.user.id = :userId
        and m.status = :status
        and m.portalType = :portalType
        and m.scopeType = :scopeType
        and m.scopeId = :scopeId
        and m.roleName in :roleNames
      """)
  boolean existsActiveMembership(
      @Param("userId") UUID userId,
      @Param("status") MembershipStatus status,
      @Param("portalType") PortalType portalType,
      @Param("scopeType") ScopeType scopeType,
      @Param("scopeId") UUID scopeId,
      @Param("roleNames") List<String> roleNames);

  Optional<ScopedMembership> findByUserIdAndPortalTypeAndScopeTypeAndScopeIdAndRoleName(
      UUID userId, PortalType portalType, ScopeType scopeType, UUID scopeId, String roleName);
}
