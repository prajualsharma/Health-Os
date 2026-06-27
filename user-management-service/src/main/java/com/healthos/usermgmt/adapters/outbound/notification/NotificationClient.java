package com.healthos.usermgmt.adapters.outbound.notification;

import com.healthos.usermgmt.config.HealthOsProperties;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * Sends transactional messages (currently auth OTP) through notification-service.
 *
 * <p>In dev (or when notification delivery is disabled / unreachable) the OTP is logged to the
 * server console so it can be read without a configured WhatsApp provider.
 */
@Slf4j
@Component
public class NotificationClient {
  private final HealthOsProperties props;
  private final RestClient restClient;

  public NotificationClient(HealthOsProperties props, RestClient.Builder builder) {
    this.props = props;
    this.restClient = builder.build();
  }

  /**
   * Attempts to deliver the OTP via WhatsApp. Returns {@code true} if it was handed off to the
   * notification service, {@code false} if it was only logged (dev fallback).
   */
  public boolean sendOtp(String phone, String code) {
    var notification = props.getNotification();
    if (!notification.isEnabled()) {
      log.info("[DEV OTP] WhatsApp OTP for {} is {}", phone, code);
      return false;
    }

    try {
      restClient
          .post()
          .uri(notification.getBaseUrl() + "/internal/notifications/whatsapp")
          .body(
              Map.of(
                  "tenantId", notification.getTenantId(),
                  "to", phone,
                  "topic", "auth.otp",
                  "variables", Map.of("otp", code)))
          .retrieve()
          .toBodilessEntity();
      return true;
    } catch (Exception e) {
      log.warn("WhatsApp OTP delivery failed for {}, falling back to log: {}", phone, e.getMessage());
      log.info("[DEV OTP] WhatsApp OTP for {} is {}", phone, code);
      return false;
    }
  }
}
