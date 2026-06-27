package com.healthos.notification.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "healthos")
public class HealthOsProperties {
  private Security security = new Security();
  private Notification notification = new Notification();
  private Whatsapp whatsapp = new Whatsapp();

  @Data
  public static class Security {
    private Jwt jwt = new Jwt();
  }

  @Data
  public static class Whatsapp {
    /** When false (default), OTP messages are logged instead of sent (dev mode). */
    private boolean enabled = false;

    private String apiUrl = "https://graph.facebook.com/v21.0";
    private String phoneNumberId;
    private String accessToken;
    private String otpMessageTemplate = "Your NutriKit verification code is {{otp}}. It expires in 10 minutes.";
  }

  @Data
  public static class Jwt {
    private String issuer;
    private String secret;
    private long accessTokenTtlSeconds;
  }

  @Data
  public static class Notification {
    private Topics topics = new Topics();
    private long idempotencyTtlSeconds = 86400;
    private RateLimit rateLimit = new RateLimit();
  }

  @Data
  public static class Topics {
    private String main = "notification-topic";
    private String retry = "notification-retry";
    private String dlt = "notification-dlt";
  }

  @Data
  public static class RateLimit {
    private int maxPerWindow = 100;
    private int windowSeconds = 60;
  }
}
