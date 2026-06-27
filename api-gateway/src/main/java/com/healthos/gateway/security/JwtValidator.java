package com.healthos.gateway.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthos.gateway.config.GatewayProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import javax.crypto.SecretKey;
import org.springframework.stereotype.Component;

@Component
public class JwtValidator {
  private final SecretKey key;
  private final ObjectMapper objectMapper;

  public JwtValidator(GatewayProperties props, ObjectMapper objectMapper) {
    this.key = Keys.hmacShaKeyFor(props.getSecurity().getJwt().getSecret().getBytes(StandardCharsets.UTF_8));
    this.objectMapper = objectMapper;
  }

  public ValidatedJwt validate(String token) {
    Claims claims =
        Jwts.parser()
            .verifyWith(key)
            .build()
            .parseSignedClaims(token)
            .getPayload();

    var userId = claims.getSubject();
    var email = claims.get("email", String.class);
    var rolesRaw = claims.get("roles", List.class);
    Set<String> roles =
        rolesRaw == null
            ? Set.of()
            : ((List<?>) rolesRaw).stream().map(Object::toString).collect(Collectors.toUnmodifiableSet());

    String membershipsJson = serializeClaim(claims.get("memberships"));
    String activeScopeJson = serializeClaim(claims.get("activeScope"));

    return new ValidatedJwt(
        UUID.fromString(userId),
        email,
        roles,
        membershipsJson,
        activeScopeJson,
        parseActiveScopeHeader(claims.get("activeScope", Map.class)));
  }

  private String serializeClaim(Object claim) {
    if (claim == null) {
      return "";
    }
    try {
      return objectMapper.writeValueAsString(claim);
    } catch (Exception e) {
      return "";
    }
  }

  private ActiveScopeHeader parseActiveScopeHeader(Map<?, ?> map) {
    if (map == null || map.isEmpty()) {
      return null;
    }
    return new ActiveScopeHeader(
        String.valueOf(map.get("portal")),
        String.valueOf(map.get("scopeType")),
        String.valueOf(map.get("scopeId")));
  }

  public record ValidatedJwt(
      UUID userId,
      String email,
      Set<String> roles,
      String membershipsJson,
      String activeScopeJson,
      ActiveScopeHeader activeScope) {}

  public record ActiveScopeHeader(String portal, String scopeType, String scopeId) {}
}
