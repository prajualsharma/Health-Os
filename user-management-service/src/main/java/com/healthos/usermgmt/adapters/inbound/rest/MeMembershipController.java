package com.healthos.usermgmt.adapters.inbound.rest;

import com.healthos.usermgmt.adapters.inbound.rest.dto.ScopedMembershipDtos;
import com.healthos.usermgmt.adapters.inbound.rest.mappers.ScopedMembershipMapper;
import com.healthos.usermgmt.adapters.inbound.rest.security.AuthPrincipal;
import com.healthos.usermgmt.application.ActiveScopeService;
import com.healthos.usermgmt.application.ScopedMembershipService;
import com.healthos.usermgmt.domain.MembershipClaim;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/me")
@RequiredArgsConstructor
public class MeMembershipController {
  private final ScopedMembershipService membershipService;
  private final ActiveScopeService activeScopeService;
  private final ScopedMembershipMapper mapper;

  @GetMapping("/memberships")
  public ScopedMembershipDtos.MyMembershipsResponse memberships(Authentication authentication) {
    var principal = (AuthPrincipal) authentication.getPrincipal();
    var memberships = membershipService.listClaimsForUser(principal.userId());
    var activeScope =
        principal.activeScope() != null
            ? principal.activeScope()
            : activeScopeService.resolveDefault(memberships).orElse(null);

    var res = new ScopedMembershipDtos.MyMembershipsResponse();
    res.setMemberships(memberships.stream().map(mapper::toClaimResponse).toList());
    if (activeScope != null) {
      res.setActiveScope(mapper.toActiveScopeResponse(activeScope));
    }
    return res;
  }

  @PostMapping("/active-scope")
  public ScopedMembershipDtos.ActiveScopeResponse setActiveScope(
      Authentication authentication, @Valid @RequestBody ScopedMembershipDtos.SetActiveScopeRequest req) {
    var principal = (AuthPrincipal) authentication.getPrincipal();
    var memberships = resolveMemberships(principal);

    var allowed =
        memberships.stream()
            .anyMatch(
                m ->
                    m.portal() == req.getPortal()
                        && m.scopeType() == req.getScopeType()
                        && m.scopeId().equals(req.getScopeId()));

    if (!allowed) {
      throw new SecurityException("Active scope must match one of your memberships");
    }

    var scope = activeScopeService.set(principal.userId(), req.getPortal(), req.getScopeType(), req.getScopeId());
    return mapper.toActiveScopeResponse(scope);
  }

  private List<MembershipClaim> resolveMemberships(AuthPrincipal principal) {
    if (principal.memberships() != null && !principal.memberships().isEmpty()) {
      return principal.memberships();
    }
    return membershipService.listClaimsForUser(principal.userId());
  }
}
