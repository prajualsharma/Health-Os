package com.healthos.usermgmt.domain;

import java.util.UUID;

public record ActiveScope(PortalType portal, ScopeType scopeType, UUID scopeId) {}
