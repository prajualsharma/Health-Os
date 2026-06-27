package com.healthos.usermgmt.application;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthos.usermgmt.domain.ActiveScope;
import com.healthos.usermgmt.domain.MembershipClaim;
import com.healthos.usermgmt.domain.PortalType;
import com.healthos.usermgmt.domain.ScopeType;
import java.time.Duration;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ActiveScopeService {
  private static final String KEY_PREFIX = "active-scope:";
  private static final Duration TTL = Duration.ofDays(30);

  private final StringRedisTemplate redis;
  private final ObjectMapper objectMapper;

  public Optional<ActiveScope> get(UUID userId) {
    var json = redis.opsForValue().get(KEY_PREFIX + userId);
    if (json == null || json.isBlank()) {
      return Optional.empty();
    }
    try {
      return Optional.of(objectMapper.readValue(json, ActiveScope.class));
    } catch (JsonProcessingException e) {
      return Optional.empty();
    }
  }

  public ActiveScope set(UUID userId, PortalType portal, ScopeType scopeType, UUID scopeId) {
    var scope = new ActiveScope(portal, scopeType, scopeId);
    try {
      redis.opsForValue().set(KEY_PREFIX + userId, objectMapper.writeValueAsString(scope), TTL);
    } catch (JsonProcessingException e) {
      throw new IllegalStateException("Failed to persist active scope", e);
    }
    return scope;
  }

  public Optional<ActiveScope> resolveDefault(List<MembershipClaim> memberships) {
    if (memberships == null || memberships.isEmpty()) {
      return Optional.empty();
    }
    return memberships.stream()
        .filter(m -> m.scopeType() == ScopeType.LOCATION)
        .findFirst()
        .map(m -> new ActiveScope(m.portal(), m.scopeType(), m.scopeId()));
  }
}
