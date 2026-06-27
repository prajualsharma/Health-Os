package com.healthos.usermgmt.application;

import com.healthos.usermgmt.config.HealthOsProperties;
import java.security.SecureRandom;
import java.time.Duration;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

/**
 * Generates, stores and verifies phone OTP codes in Redis, and mints one-use registration tokens
 * for users who pass OTP verification but do not yet have an account.
 */
@Service
@RequiredArgsConstructor
public class OtpService {
  private static final String OTP_PREFIX = "otp:";
  private static final String ATTEMPT_PREFIX = "otp:attempts:";
  private static final String REG_TOKEN_PREFIX = "regtoken:";

  private final StringRedisTemplate redis;
  private final HealthOsProperties props;
  private final SecureRandom random = new SecureRandom();

  /** Generates an OTP, stores it with a TTL and returns the code (for dev logging / delivery). */
  public String generate(String phone) {
    var otp = props.getOtp();
    String code;
    if (otp.isDevBypass()) {
      code = otp.getDevCode();
    } else {
      int bound = (int) Math.pow(10, otp.getLength());
      code = String.format("%0" + otp.getLength() + "d", random.nextInt(bound));
    }
    redis.opsForValue().set(OTP_PREFIX + phone, code, Duration.ofSeconds(otp.getTtlSeconds()));
    redis.delete(ATTEMPT_PREFIX + phone);
    return code;
  }

  /** Validates an OTP code, enforcing an attempt cap. Throws on any failure. Consumes on success. */
  public void verify(String phone, String code) {
    var key = OTP_PREFIX + phone;
    var stored = redis.opsForValue().get(key);
    if (stored == null) {
      throw new IllegalArgumentException("OTP expired or not requested");
    }

    var attemptKey = ATTEMPT_PREFIX + phone;
    Long attempts = redis.opsForValue().increment(attemptKey);
    if (attempts != null && attempts == 1L) {
      redis.expire(attemptKey, Duration.ofSeconds(props.getOtp().getTtlSeconds()));
    }
    if (attempts != null && attempts > props.getOtp().getMaxAttempts()) {
      redis.delete(key);
      redis.delete(attemptKey);
      throw new IllegalArgumentException("Too many attempts. Request a new code.");
    }

    if (!stored.equals(code)) {
      throw new IllegalArgumentException("Invalid OTP");
    }

    redis.delete(key);
    redis.delete(attemptKey);
  }

  /** Issues a short-lived, one-use registration token bound to a verified phone number. */
  public String issueRegistrationToken(String phone) {
    var token = UUID.randomUUID().toString();
    redis.opsForValue()
        .set(
            REG_TOKEN_PREFIX + token,
            phone,
            Duration.ofSeconds(props.getOtp().getRegistrationTtlSeconds()));
    return token;
  }

  /** Consumes a registration token and returns the phone it was bound to. Throws if invalid. */
  public String consumeRegistrationToken(String token) {
    var key = REG_TOKEN_PREFIX + token;
    var phone = redis.opsForValue().get(key);
    if (phone == null) {
      throw new IllegalArgumentException("Registration session expired. Verify your phone again.");
    }
    redis.delete(key);
    return phone;
  }
}
