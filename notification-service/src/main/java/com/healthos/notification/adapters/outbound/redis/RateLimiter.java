package com.healthos.notification.adapters.outbound.redis;

import com.healthos.notification.config.HealthOsProperties;
import java.time.Duration;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RateLimiter {

  private static final String KEY_PREFIX = "notif:rate:";

  private final StringRedisTemplate redisTemplate;
  private final HealthOsProperties properties;

  public boolean allow(String tenantId) {
    String key = KEY_PREFIX + tenantId;
    Long count = redisTemplate.opsForValue().increment(key);
    if (count != null && count == 1L) {
      redisTemplate.expire(
          key, Duration.ofSeconds(properties.getNotification().getRateLimit().getWindowSeconds()));
    }
    int max = properties.getNotification().getRateLimit().getMaxPerWindow();
    return count != null && count <= max;
  }
}
