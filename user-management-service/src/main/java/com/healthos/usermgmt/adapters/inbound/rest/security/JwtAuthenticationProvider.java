package com.healthos.usermgmt.adapters.inbound.rest.security;

import com.healthos.usermgmt.application.ActiveScopeService;
import com.healthos.usermgmt.application.ScopedMembershipService;
import com.healthos.usermgmt.config.HealthOsProperties;
import com.healthos.usermgmt.domain.ActiveScope;
import com.healthos.usermgmt.domain.MembershipClaim;
import com.healthos.usermgmt.domain.PortalType;
import com.healthos.usermgmt.domain.ScopeType;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import javax.crypto.SecretKey;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

@Component
public class JwtAuthenticationProvider implements AuthenticationProvider {
  private final SecretKey key;
  private final ScopedMembershipService membershipService;
  private final ActiveScopeService activeScopeService;

  public JwtAuthenticationProvider(
      HealthOsProperties props,
      ScopedMembershipService membershipService,
      ActiveScopeService activeScopeService) {
    this.key = Keys.hmacShaKeyFor(props.getSecurity().getJwt().getSecret().getBytes(StandardCharsets.UTF_8));
    this.membershipService = membershipService;
    this.activeScopeService = activeScopeService;
  }

  @Override
  public JwtAuthenticationToken authenticate(org.springframework.security.core.Authentication authentication) {
    if (!(authentication instanceof JwtAuthenticationToken jwtAuth) || jwtAuth.getCredentials() == null) {
      return null;
    }

    String token = jwtAuth.getCredentials().toString();
    Claims claims;
    try {
      claims =
          Jwts.parser()
              .verifyWith(key)
              .build()
              .parseSignedClaims(token)
              .getPayload();
    } catch (Exception e) {
      throw new BadCredentialsException("Invalid JWT", e);
    }

    var userId = UUID.fromString(claims.getSubject());
    var email = claims.get("email", String.class);
    var roles = claims.get("roles", List.class);

    Collection<? extends GrantedAuthority> authorities =
        roles == null
            ? List.of()
            : ((List<?>) roles).stream()
                .map(Object::toString)
                .map(r -> new SimpleGrantedAuthority("ROLE_" + r))
                .collect(Collectors.toUnmodifiableList());

    Set<String> roleNames =
        roles == null
            ? Set.of()
            : ((List<?>) roles).stream().map(Object::toString).collect(Collectors.toUnmodifiableSet());

    var memberships = parseMemberships(claims.get("memberships", List.class));
    if (memberships.isEmpty()) {
      memberships = membershipService.listClaimsForUser(userId);
    }

    ActiveScope activeScope = parseActiveScope(claims.get("activeScope", Map.class));
    if (activeScope == null) {
      activeScope = activeScopeService.get(userId).orElse(null);
    }
    if (activeScope == null) {
      activeScope = activeScopeService.resolveDefault(memberships).orElse(null);
    }

    var principal = new AuthPrincipal(userId, email, roleNames, memberships, activeScope);

    return new JwtAuthenticationToken(principal, token, authorities);
  }

  @Override
  public boolean supports(Class<?> authentication) {
    return JwtAuthenticationToken.class.isAssignableFrom(authentication);
  }

  @SuppressWarnings("unchecked")
  private List<MembershipClaim> parseMemberships(List<?> raw) {
    if (raw == null || raw.isEmpty()) {
      return List.of();
    }
    var claims = new ArrayList<MembershipClaim>();
    for (var item : raw) {
      if (!(item instanceof Map<?, ?> map)) {
        continue;
      }
      claims.add(
          new MembershipClaim(
              PortalType.valueOf(String.valueOf(map.get("portal"))),
              ScopeType.valueOf(String.valueOf(map.get("scopeType"))),
              UUID.fromString(String.valueOf(map.get("scopeId"))),
              String.valueOf(map.get("role"))));
    }
    return List.copyOf(claims);
  }

  private ActiveScope parseActiveScope(Map<?, ?> map) {
    if (map == null || map.isEmpty()) {
      return null;
    }
    return new ActiveScope(
        PortalType.valueOf(String.valueOf(map.get("portal"))),
        ScopeType.valueOf(String.valueOf(map.get("scopeType"))),
        UUID.fromString(String.valueOf(map.get("scopeId"))));
  }
}
