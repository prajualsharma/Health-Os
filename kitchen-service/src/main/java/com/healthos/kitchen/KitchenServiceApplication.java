package com.healthos.kitchen;

import com.healthos.kitchen.config.HealthOsProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties(HealthOsProperties.class)
public class KitchenServiceApplication {
  public static void main(String[] args) {
    SpringApplication.run(KitchenServiceApplication.class, args);
  }
}
