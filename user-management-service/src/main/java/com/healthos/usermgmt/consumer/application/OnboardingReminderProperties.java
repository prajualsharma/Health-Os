package com.healthos.usermgmt.consumer.application;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "healthos.onboarding-reminder")
public class OnboardingReminderProperties {
  /** Minutes of inactivity before sending a reminder. */
  private long delayMinutes = 120;

  private String resumeBaseUrl = "https://nutrikit.vercel.app";

  private long pollIntervalMs = 300_000L;
}
