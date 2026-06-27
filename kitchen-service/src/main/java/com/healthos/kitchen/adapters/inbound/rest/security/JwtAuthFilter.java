package com.healthos.kitchen.adapters.inbound.rest.security;

import com.healthos.kitchen.config.HealthOsProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import javax.crypto.SecretKey;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/** Validates the shared HS256 JWT and exposes an {@link AuthPrincipal} in the security context. */
@Component
public class JwtAuthFilter extends OncePerRequestFilter {
  private final SecretKey key;

  public JwtAuthFilter(HealthOsProperties props) {
    this.key =
        Keys.hmacShaKeyFor(props.getSecurity().getJwt().getSecret().getBytes(StandardCharsets.UTF_8));
  }

  @Override
  protected void doFilterInternal(
      HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
      throws ServletException, IOException {
    String header = request.getHeader(HttpHeaders.AUTHORIZATION);
    if (header != null && header.startsWith("Bearer ")) {
      try {
        var claims = parse(header.substring("Bearer ".length()).trim());
        var principal = toPrincipal(claims);
        var authorities =
            principal.roles().stream()
                .map(r -> new SimpleGrantedAuthority("ROLE_" + r))
                .collect(Collectors.toList());
        var auth = new UsernamePasswordAuthenticationToken(principal, null, authorities);
        SecurityContextHolder.getContext().setAuthentication(auth);
      } catch (Exception ignored) {
        SecurityContextHolder.clearContext();
      }
    }
    filterChain.doFilter(request, response);
  }

  private Claims parse(String token) {
    return Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
  }

  @SuppressWarnings("unchecked")
  private AuthPrincipal toPrincipal(Claims claims) {
    var userId = UUID.fromString(claims.getSubject());
    var email = claims.get("email", String.class);
    var rolesRaw = claims.get("roles", List.class);
    Set<String> roles =
        rolesRaw == null
            ? Set.of()
            : ((List<?>) rolesRaw)
                .stream().map(Object::toString).collect(Collectors.toUnmodifiableSet());

    String portalType = null;
    String scopeType = null;
    UUID scopeId = null;
    var activeScope = claims.get("activeScope", Map.class);
    if (activeScope != null) {
      portalType = asString(activeScope.get("portal"));
      scopeType = asString(activeScope.get("scopeType"));
      var rawScopeId = asString(activeScope.get("scopeId"));
      if (rawScopeId != null) {
        scopeId = UUID.fromString(rawScopeId);
      }
    }

    return new AuthPrincipal(userId, email, roles, portalType, scopeType, scopeId);
  }

  private static String asString(Object o) {
    return o == null ? null : String.valueOf(o);
  }
}
