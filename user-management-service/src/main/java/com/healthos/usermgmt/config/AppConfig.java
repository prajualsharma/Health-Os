package com.healthos.usermgmt.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthos.usermgmt.consumer.application.OnboardingReminderProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties({HealthOsProperties.class, OnboardingReminderProperties.class})
public class AppConfig {
  @Bean
  public ObjectMapper objectMapper() {
    return new ObjectMapper().findAndRegisterModules();
  }
}

