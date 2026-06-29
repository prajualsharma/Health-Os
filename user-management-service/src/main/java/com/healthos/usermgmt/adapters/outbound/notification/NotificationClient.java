package com.healthos.usermgmt.adapters.outbound.notification;

import com.healthos.usermgmt.config.HealthOsProperties;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * Sends auth OTP codes by email (SMTP direct, or notification-service when configured).
 *
 * <p>When delivery fails, the OTP is logged server-side so dev environments still work.
 */
@Slf4j
@Component
public class NotificationClient {
  private final HealthOsProperties props;
  private final EmailOtpSender emailOtpSender;
  private final RestClient restClient;

  public NotificationClient(
      HealthOsProperties props, EmailOtpSender emailOtpSender, RestClient.Builder builder) {
    this.props = props;
    this.emailOtpSender = emailOtpSender;
    this.restClient = builder.build();
  }

  /** Attempts email OTP delivery. Returns {@code true} when handed off successfully. */
  public boolean sendOtp(String phone, String code) {
    var notification = props.getNotification();
    if (!notification.isEnabled()) {
      log.info("[DEV OTP] Email OTP for {} is {}", phone, code);
      return false;
    }

    var to = notification.getOtpEmailTo();
    if (to == null || to.isBlank()) {
      log.warn("OTP_EMAIL_TO is not set; logging OTP instead");
      log.info("[DEV OTP] Email OTP for {} is {}", phone, code);
      return false;
    }

    if (emailOtpSender.send(to, phone, code)) {
      return true;
    }

    try {
      restClient
          .post()
          .uri(notification.getBaseUrl() + "/internal/notifications/email")
          .body(
              Map.of(
                  "tenantId", notification.getTenantId(),
                  "to", to,
                  "phone", phone,
                  "topic", "auth.otp",
                  "variables", Map.of("otp", code, "phone", phone)))
          .retrieve()
          .toBodilessEntity();
      return true;
    } catch (Exception e) {
      log.warn("Email OTP delivery failed for {}, falling back to log: {}", phone, e.getMessage());
      log.info("[DEV OTP] Email OTP for {} is {}", phone, code);
      return false;
    }
  }
}
