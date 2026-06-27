package com.healthos.notification.adapters.outbound.redis;

import com.healthos.notification.config.HealthOsProperties;
import com.healthos.notification.domain.Channel;
import java.time.Duration;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class IdempotencyService {

  private static final String KEY_PREFIX = "notif:idem:";

  private final StringRedisTemplate redisTemplate;
  private final HealthOsProperties properties;

  public boolean tryAcquire(String tenantId, String eventId, Channel channel) {
    String key = KEY_PREFIX + tenantId + ":" + eventId + ":" + channel.name();
    Boolean acquired =
        redisTemplate
            .opsForValue()
            .setIfAbsent(
                key,
                "1",
                Duration.ofSeconds(properties.getNotification().getIdempotencyTtlSeconds()));
    return Boolean.TRUE.equals(acquired);
  }
}
