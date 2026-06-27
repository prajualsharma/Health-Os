package com.healthos.usermgmt.adapters.outbound.security;

import com.healthos.usermgmt.config.HealthOsProperties;
import com.healthos.usermgmt.domain.ActiveScope;
import com.healthos.usermgmt.domain.MembershipClaim;
import com.healthos.usermgmt.domain.Role;
import com.healthos.usermgmt.domain.User;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import javax.crypto.SecretKey;
import org.springframework.stereotype.Service;

@Service
public class JwtService {
  private final HealthOsProperties props;
  private final SecretKey key;

  public JwtService(HealthOsProperties props) {
    this.props = props;
    this.key = Keys.hmacShaKeyFor(props.getSecurity().getJwt().getSecret().getBytes(StandardCharsets.UTF_8));
  }

  public String issueAccessToken(
      User user, Instant now, List<MembershipClaim> memberships, ActiveScope activeScope) {
    var ttlSeconds = props.getSecurity().getJwt().getAccessTokenTtlSeconds();
    var exp = now.plusSeconds(ttlSeconds);

    Set<String> roles =
        user.getRoles().stream().map(Role::getName).collect(Collectors.toUnmodifiableSet());

    var builder =
        Jwts.builder()
            .issuer(props.getSecurity().getJwt().getIssuer())
            .subject(user.getId().toString())
            .issuedAt(Date.from(now))
            .expiration(Date.from(exp))
            .claim("roles", roles);

    if (user.getEmail() != null) {
      builder.claim("email", user.getEmail());
    }

    if (memberships != null && !memberships.isEmpty()) {
      builder.claim("memberships", memberships.stream().map(this::toClaimMap).toList());
    }
    if (activeScope != null) {
      builder.claim("activeScope", toActiveScopeMap(activeScope));
    }

    return builder.signWith(key, Jwts.SIG.HS256).compact();
  }

  private Map<String, Object> toClaimMap(MembershipClaim claim) {
    var map = new HashMap<String, Object>();
    map.put("portal", claim.portal().name());
    map.put("scopeType", claim.scopeType().name());
    map.put("scopeId", claim.scopeId().toString());
    map.put("role", claim.role());
    return map;
  }

  private Map<String, Object> toActiveScopeMap(ActiveScope scope) {
    var map = new HashMap<String, Object>();
    map.put("portal", scope.portal().name());
    map.put("scopeType", scope.scopeType().name());
    map.put("scopeId", scope.scopeId().toString());
    return map;
  }
}
