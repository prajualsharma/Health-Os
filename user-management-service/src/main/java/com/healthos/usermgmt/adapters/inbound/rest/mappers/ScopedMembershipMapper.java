package com.healthos.usermgmt.adapters.inbound.rest.mappers;

import com.healthos.usermgmt.adapters.inbound.rest.dto.ScopedMembershipDtos;
import com.healthos.usermgmt.domain.ActiveScope;
import com.healthos.usermgmt.domain.MembershipClaim;
import com.healthos.usermgmt.domain.ScopedMembership;
import org.springframework.stereotype.Component;

@Component
public class ScopedMembershipMapper {
  public ScopedMembershipDtos.MembershipResponse toResponse(ScopedMembership membership) {
    var res = new ScopedMembershipDtos.MembershipResponse();
    res.setId(membership.getId());
    res.setUserId(membership.getUser().getId());
    res.setPortalType(membership.getPortalType());
    res.setScopeType(membership.getScopeType());
    res.setScopeId(membership.getScopeId());
    res.setRoleName(membership.getRoleName());
    res.setCreatedAt(membership.getCreatedAt());
    return res;
  }

  public ScopedMembershipDtos.MembershipClaimResponse toClaimResponse(MembershipClaim claim) {
    var res = new ScopedMembershipDtos.MembershipClaimResponse();
    res.setPortal(claim.portal());
    res.setScopeType(claim.scopeType());
    res.setScopeId(claim.scopeId());
    res.setRole(claim.role());
    return res;
  }

  public ScopedMembershipDtos.ActiveScopeResponse toActiveScopeResponse(ActiveScope scope) {
    var res = new ScopedMembershipDtos.ActiveScopeResponse();
    res.setPortal(scope.portal());
    res.setScopeType(scope.scopeType());
    res.setScopeId(scope.scopeId());
    return res;
  }
}
