package com.healthos.usermgmt.staff.adapters.inbound.rest.internal;

import com.healthos.usermgmt.adapters.inbound.rest.dto.ScopedMembershipDtos;
import com.healthos.usermgmt.adapters.inbound.rest.mappers.ScopedMembershipMapper;
import com.healthos.usermgmt.application.ScopedMembershipService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/internal/staff/scoped-memberships")
@RequiredArgsConstructor
public class StaffInternalScopedMembershipController {
  private final ScopedMembershipService membershipService;
  private final ScopedMembershipMapper mapper;

  @PostMapping
  public ScopedMembershipDtos.MembershipResponse assign(
      @Valid @RequestBody ScopedMembershipDtos.AssignMembershipRequest req) {
    var created =
        membershipService.assignInternal(
            req.getUserId(),
            req.getPortalType(),
            req.getScopeType(),
            req.getScopeId(),
            req.getRoleName());
    return mapper.toResponse(created);
  }
}
