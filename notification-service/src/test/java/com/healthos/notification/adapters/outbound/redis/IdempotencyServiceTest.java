package com.healthos.notification.adapters.outbound.redis;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

import com.healthos.notification.config.HealthOsProperties;
import com.healthos.notification.domain.Channel;
import java.time.Duration;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

@ExtendWith(MockitoExtension.class)
class IdempotencyServiceTest {

  @Mock private StringRedisTemplate redisTemplate;
  @Mock private ValueOperations<String, String> valueOps;

  private IdempotencyService idempotencyService;

  @BeforeEach
  void setUp() {
    HealthOsProperties props = new HealthOsProperties();
    props.getNotification().setIdempotencyTtlSeconds(3600);
    idempotencyService = new IdempotencyService(redisTemplate, props);
    when(redisTemplate.opsForValue()).thenReturn(valueOps);
  }

  @Test
  void acquiresOnFirstAttempt() {
    when(valueOps.setIfAbsent(eq("notif:idem:gym001:evt-1:EMAIL"), eq("1"), any(Duration.class)))
        .thenReturn(true);
    assertThat(idempotencyService.tryAcquire("gym001", "evt-1", Channel.EMAIL)).isTrue();
  }

  @Test
  void rejectsDuplicate() {
    when(valueOps.setIfAbsent(any(), any(), any(Duration.class))).thenReturn(false);
    assertThat(idempotencyService.tryAcquire("gym001", "evt-1", Channel.EMAIL)).isFalse();
  }
}
