package com.healthos.notification.adapters.inbound.rest.security;

import com.healthos.notification.config.HealthOsProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.Collection;
import java.util.List;
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

  public JwtAuthenticationProvider(HealthOsProperties props) {
    this.key =
        Keys.hmacShaKeyFor(props.getSecurity().getJwt().getSecret().getBytes(StandardCharsets.UTF_8));
  }

  @Override
  public JwtAuthenticationToken authenticate(
      org.springframework.security.core.Authentication authentication) {
    if (!(authentication instanceof JwtAuthenticationToken jwtAuth)
        || jwtAuth.getCredentials() == null) {
      return null;
    }

    String token = jwtAuth.getCredentials().toString();
    Claims claims;
    try {
      claims =
          Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
    } catch (Exception e) {
      throw new BadCredentialsException("Invalid JWT", e);
    }

    var userId = UUID.fromString(claims.getSubject());
    var email = claims.get("email", String.class);
    var roles = claims.get("roles", List.class);

    Collection<? extends GrantedAuthority> authorities =
        roles == null
            ? List.of()
            : ((List<?>) roles)
                .stream()
                .map(Object::toString)
                .map(r -> new SimpleGrantedAuthority("ROLE_" + r))
                .collect(Collectors.toUnmodifiableList());

    Set<String> roleNames =
        roles == null
            ? Set.of()
            : ((List<?>) roles).stream().map(Object::toString).collect(Collectors.toUnmodifiableSet());
    var principal = new AuthPrincipal(userId, email, roleNames);

    return new JwtAuthenticationToken(principal, token, authorities);
  }

  @Override
  public boolean supports(Class<?> authentication) {
    return JwtAuthenticationToken.class.isAssignableFrom(authentication);
  }
}
