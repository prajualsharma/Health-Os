package com.healthos.kitchen.adapters.inbound.rest.security;

import java.util.Set;
import java.util.UUID;

/**
 * Authenticated caller resolved from the JWT. activeScopeId is the scope_id of the active scope
 * (organization for corporate users, kitchen location for staff), used to filter kitchen data.
 */
public record AuthPrincipal(
    UUID userId,
    String email,
    Set<String> roles,
    String portalType,
    String scopeType,
    UUID activeScopeId) {}
