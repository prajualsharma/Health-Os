package com.healthos.kitchen.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "healthos")
public class HealthOsProperties {
  private Security security = new Security();
  private Downstream downstream = new Downstream();

  @Data
  public static class Security {
    private Jwt jwt = new Jwt();
  }

  @Data
  public static class Jwt {
    private String issuer = "healthos";
    private String secret = "dev-only-change-me-dev-only-change-me";
  }

  @Data
  public static class Downstream {
    private UserManagement userManagement = new UserManagement();
  }

  @Data
  public static class UserManagement {
    private String baseUrl = "http://localhost:8081";
  }
}
