package com.healthos.usermgmt.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "healthos")
public class HealthOsProperties {
  private Security security = new Security();
  private Otp otp = new Otp();
  private Notification notification = new Notification();

  @Data
  public static class Security {
    private Jwt jwt = new Jwt();
  }

  @Data
  public static class Jwt {
    private String issuer;
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
  }

  @Data
  public static class Notification {
    private boolean enabled = false;
    private String baseUrl = "http://localhost:8082";
    private String tenantId = "healthos";
  }
}

