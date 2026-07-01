package com.healthos.usermgmt.application;

import com.healthos.usermgmt.config.HealthOsProperties;
import java.time.Duration;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

/** Redis-backed OTP rate limiting for the consumer identity pool. */
@Service
@RequiredArgsConstructor
public class OtpRateLimitService {
  private static final Duration WINDOW = Duration.ofHours(1);

  private final StringRedisTemplate redis;
  private final HealthOsProperties props;

  public void checkConsumerAllowed(String phone) {
    var key = "otp:rate:consumer:" + phone;
    var count = redis.opsForValue().increment(key);
    if (count != null && count == 1L) {
      redis.expire(key, WINDOW);
    }
    if (count != null && count > props.getOtp().getConsumerRateLimitPerHour()) {
      throw new IllegalStateException("Too many OTP requests. Try again later.");
    }
  }
}
