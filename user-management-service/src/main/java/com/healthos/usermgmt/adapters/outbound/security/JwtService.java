package com.healthos.usermgmt.adapters.outbound.security;

import com.healthos.usermgmt.config.HealthOsProperties;
import com.healthos.usermgmt.consumer.domain.ConsumerAccount;
import com.healthos.usermgmt.domain.ActiveScope;
import com.healthos.usermgmt.domain.MembershipClaim;
import com.healthos.usermgmt.domain.Role;
import com.healthos.usermgmt.shared.domain.AccountType;
import com.healthos.usermgmt.staff.domain.StaffAccount;
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

  public String issueConsumerToken(ConsumerAccount account, Instant now) {
    var ttlSeconds = props.getSecurity().getJwt().getAccessTokenTtlSeconds();
    var exp = now.plusSeconds(ttlSeconds);
    var builder =
        baseBuilder(props.getSecurity().getJwt().getConsumerIssuer(), account.getId().toString(), now, exp)
            .claim("accountType", AccountType.CONSUMER.name())
            .claim("aud", "nutrikit");
    if (account.getEmail() != null) {
      builder.claim("email", account.getEmail());
    }
    return builder.signWith(key, Jwts.SIG.HS256).compact();
  }

  public String issueStaffToken(
      StaffAccount account,
      Instant now,
      List<MembershipClaim> memberships,
      ActiveScope activeScope) {
    return issueStaffToken(
        account.getId(),
        account.getEmail(),
        roleNames(account.getRoles()),
        now,
        memberships,
        activeScope);
  }

  private String issueStaffToken(
      java.util.UUID accountId,
      String email,
      Set<String> roles,
      Instant now,
      List<MembershipClaim> memberships,
      ActiveScope activeScope) {
    var ttlSeconds = props.getSecurity().getJwt().getAccessTokenTtlSeconds();
    var exp = now.plusSeconds(ttlSeconds);

    var builder =
        baseBuilder(props.getSecurity().getJwt().getStaffIssuer(), accountId.toString(), now, exp)
            .claim("accountType", AccountType.STAFF.name())
            .claim("aud", "staff")
            .claim("roles", roles);

    if (email != null) {
      builder.claim("email", email);
    }
    if (memberships != null && !memberships.isEmpty()) {
      builder.claim("memberships", memberships.stream().map(this::toClaimMap).toList());
    }
    if (activeScope != null) {
      builder.claim("activeScope", toActiveScopeMap(activeScope));
    }

    return builder.signWith(key, Jwts.SIG.HS256).compact();
  }

  public boolean isAllowedIssuer(String issuer) {
    var jwt = props.getSecurity().getJwt();
    return jwt.getIssuer().equals(issuer)
        || jwt.getConsumerIssuer().equals(issuer)
        || jwt.getStaffIssuer().equals(issuer);
  }

  private io.jsonwebtoken.JwtBuilder baseBuilder(
      String issuer, String subject, Instant now, Instant exp) {
    return Jwts.builder()
        .issuer(issuer)
        .subject(subject)
        .issuedAt(Date.from(now))
        .expiration(Date.from(exp));
  }

  private static Set<String> roleNames(Set<Role> roles) {
    if (roles == null) {
      return Set.of();
    }
    return roles.stream().map(Role::getName).collect(Collectors.toUnmodifiableSet());
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
