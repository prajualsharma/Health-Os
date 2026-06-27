package com.healthos.notification.adapters.inbound.rest.security;

import java.util.Set;
import java.util.UUID;

public record AuthPrincipal(UUID userId, String email, Set<String> roles) {}
