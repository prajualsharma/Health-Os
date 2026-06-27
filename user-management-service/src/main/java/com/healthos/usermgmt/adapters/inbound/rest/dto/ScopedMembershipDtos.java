package com.healthos.usermgmt.adapters.inbound.rest.dto;

import com.healthos.usermgmt.domain.PortalType;
import com.healthos.usermgmt.domain.ScopeType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import lombok.Data;

public class ScopedMembershipDtos {
  @Data
  public static class MembershipResponse {
    private UUID id;
    private UUID userId;
    private PortalType portalType;
    private ScopeType scopeType;
    private UUID scopeId;
    private String roleName;
    private Instant createdAt;
  }

  @Data
  public static class MembershipClaimResponse {
    private PortalType portal;
    private ScopeType scopeType;
    private UUID scopeId;
    private String role;
  }

  @Data
  public static class ActiveScopeResponse {
    private PortalType portal;
    private ScopeType scopeType;
    private UUID scopeId;
  }

  @Data
  public static class AssignMembershipRequest {
    @NotNull private UUID userId;
    @NotNull private PortalType portalType;
    @NotNull private ScopeType scopeType;
    @NotNull private UUID scopeId;
    @NotBlank private String roleName;
  }

  @Data
  public static class SetActiveScopeRequest {
    @NotNull private PortalType portal;
    @NotNull private ScopeType scopeType;
    @NotNull private UUID scopeId;
  }

  @Data
  public static class MyMembershipsResponse {
    private List<MembershipClaimResponse> memberships;
    private ActiveScopeResponse activeScope;
  }
}
