package com.healthos.gateway.security;

import com.healthos.gateway.config.GatewayProperties;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.Set;
import javax.crypto.SecretKey;
import org.springframework.stereotype.Service;

@Service
public class JwtIssuer {
  private final GatewayProperties props;
  private final SecretKey key;

  public JwtIssuer(GatewayProperties props) {
    this.props = props;
    this.key = Keys.hmacShaKeyFor(props.getSecurity().getJwt().getSecret().getBytes(StandardCharsets.UTF_8));
  }

  public String issueAccessToken(String userId, String email, Set<String> roles, Instant now) {
    var exp = now.plusSeconds(props.getSecurity().getJwt().getAccessTokenTtlSeconds());
    return Jwts.builder()
        .issuer(props.getSecurity().getJwt().getIssuer())
        .subject(userId)
        .issuedAt(Date.from(now))
        .expiration(Date.from(exp))
        .claim("email", email)
        .claim("roles", roles)
        .signWith(key, Jwts.SIG.HS256)
        .compact();
  }
}

