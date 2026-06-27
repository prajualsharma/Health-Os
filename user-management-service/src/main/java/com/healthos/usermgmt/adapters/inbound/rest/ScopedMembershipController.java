package com.healthos.usermgmt.adapters.inbound.rest;

import com.healthos.usermgmt.adapters.inbound.rest.dto.ScopedMembershipDtos;
import com.healthos.usermgmt.adapters.inbound.rest.mappers.ScopedMembershipMapper;
import com.healthos.usermgmt.adapters.inbound.rest.security.AuthPrincipal;
import com.healthos.usermgmt.application.ScopeAuthorizationService;
import com.healthos.usermgmt.application.ScopedMembershipService;
import com.healthos.usermgmt.domain.MembershipClaim;
import com.healthos.usermgmt.domain.PortalType;
import com.healthos.usermgmt.domain.ScopeType;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/scoped-memberships")
@RequiredArgsConstructor
public class ScopedMembershipController {
  private final ScopedMembershipService membershipService;
  private final ScopeAuthorizationService authorizationService;
  private final ScopedMembershipMapper mapper;

  @GetMapping
  public List<ScopedMembershipDtos.MembershipResponse> list(
      Authentication authentication,
      @RequestParam PortalType portalType,
      @RequestParam ScopeType scopeType,
      @RequestParam UUID scopeId) {
    var principal = (AuthPrincipal) authentication.getPrincipal();
    var memberships = resolveMemberships(principal);

    if (!authorizationService.canManageScope(
        principal.userId(), principal.roles(), memberships, portalType, scopeType, scopeId)) {
      throw new SecurityException("Not authorized to list memberships for this scope");
    }

    return membershipService.listForScope(portalType, scopeType, scopeId).stream()
        .map(mapper::toResponse)
        .toList();
  }

  @PostMapping
  public ScopedMembershipDtos.MembershipResponse assign(
      Authentication authentication, @Valid @RequestBody ScopedMembershipDtos.AssignMembershipRequest req) {
    var principal = (AuthPrincipal) authentication.getPrincipal();
    var memberships = resolveMemberships(principal);

    var created =
        membershipService.assign(
            principal.userId(),
            principal.roles(),
            memberships,
            req.getUserId(),
            req.getPortalType(),
            req.getScopeType(),
            req.getScopeId(),
            req.getRoleName());
    return mapper.toResponse(created);
  }

  @DeleteMapping("/{id}")
  public void revoke(Authentication authentication, @PathVariable UUID id) {
    var principal = (AuthPrincipal) authentication.getPrincipal();
    membershipService.revoke(principal.userId(), principal.roles(), resolveMemberships(principal), id);
  }

  private List<MembershipClaim> resolveMemberships(AuthPrincipal principal) {
    if (principal.memberships() != null && !principal.memberships().isEmpty()) {
      return principal.memberships();
    }
    return membershipService.listClaimsForUser(principal.userId());
  }

}
