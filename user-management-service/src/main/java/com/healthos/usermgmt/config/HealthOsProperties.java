package com.healthos.usermgmt.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "healthos")
public class HealthOsProperties {
  private Security security = new Security();
  private Otp otp = new Otp();
  private Notification notification = new Notification();
  private Smtp smtp = new Smtp();
  private ConsumerScale consumerScale = new ConsumerScale();

  @Data
  public static class Smtp {
    private boolean enabled = true;
    private String host = "smtp.gmail.com";
    private int port = 587;
    private String username;
    private String password;
    private String from;
    private boolean starttls = true;
    private String otpSubject = "Your NutriKit verification code";
    private String otpBody =
        "Your NutriKit verification code for {{phone}} is {{otp}}.\n\nIt expires in 10 minutes.";
  }

  @Data
  public static class Security {
    private Jwt jwt = new Jwt();
  }

  @Data
  public static class Jwt {
    private String issuer = "healthos";
    private String consumerIssuer = "healthos-consumer";
    private String staffIssuer = "healthos-staff";
    private String secret;
    private long accessTokenTtlSeconds;
    private long refreshTokenTtlSeconds;
  }

  @Data
  public static class Otp {
    private String devCode;
    private long ttlSeconds;
    private int length = 6;
    private boolean devBypass = true;
    private int maxAttempts = 5;
    private long registrationTtlSeconds = 900;
    /** Max OTP initiate requests per phone per hour (consumer pool). */
    private int consumerRateLimitPerHour = 10;
  }

  @Data
  public static class ConsumerScale {
    /**
     * Split consumer-identity-service when NutriKit MAU exceeds this threshold and DB is
     * the bottleneck. See application.yml healthos.consumer-scale.split-triggers.
     */
    private long splitMauThreshold = 500_000;
    private boolean readReplicaEnabled = false;
    private String readReplicaUrl;
  }

  @Data
  public static class Notification {
    private boolean enabled = false;
    private String baseUrl = "http://localhost:8082";
    private String tenantId = "healthos";
    /** Inbox that receives OTP emails during phone login (e.g. your Gmail). */
    private String otpEmailTo;
  }
}

