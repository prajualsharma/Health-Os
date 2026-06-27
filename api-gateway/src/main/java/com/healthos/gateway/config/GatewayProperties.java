package com.healthos.gateway.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "healthos")
public class GatewayProperties {
  private Security security = new Security();
  private Downstream downstream = new Downstream();
  private Cors cors = new Cors();
  private RateLimit rateLimit = new RateLimit();

  @Data
  public static class Security {
    private Jwt jwt = new Jwt();
    private Google google = new Google();
  }

  @Data
  public static class Jwt {
    private String issuer;
    private String secret;
    private long accessTokenTtlSeconds;
  }

  @Data
  public static class Google {
    private String clientId;
  }

  @Data
  public static class Downstream {
    private UserManagement userManagement = new UserManagement();
  }

  @Data
  public static class UserManagement {
    private String baseUrl;
  }

  @Data
  public static class Cors {
    private String allowedOrigins;
  }

  @Data
  public static class RateLimit {
    private int replenishRate;
    private int burstCapacity;
  }
}

