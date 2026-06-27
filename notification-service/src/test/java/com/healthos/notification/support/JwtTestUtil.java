package com.healthos.notification.support;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.Set;
import javax.crypto.SecretKey;

public final class JwtTestUtil {
  public static final String TEST_SECRET = "test-secret-test-secret-test-secret-test-secret";

  private JwtTestUtil() {}

  public static String token(String userId, String email, Set<String> roles) {
    SecretKey key = Keys.hmacShaKeyFor(TEST_SECRET.getBytes(StandardCharsets.UTF_8));
    return Jwts.builder()
        .issuer("healthos")
        .subject(userId)
        .issuedAt(Date.from(Instant.now()))
        .expiration(Date.from(Instant.now().plusSeconds(3600)))
        .claim("email", email)
        .claim("roles", roles)
        .signWith(key, Jwts.SIG.HS256)
        .compact();
  }
}
