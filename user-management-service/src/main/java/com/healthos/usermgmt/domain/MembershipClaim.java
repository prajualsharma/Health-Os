package com.healthos.usermgmt.domain;

import java.util.UUID;

public record MembershipClaim(
    PortalType portal, ScopeType scopeType, UUID scopeId, String role) {}
