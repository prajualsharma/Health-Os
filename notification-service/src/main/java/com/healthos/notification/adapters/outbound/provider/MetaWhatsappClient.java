package com.healthos.notification.adapters.outbound.provider;

import com.healthos.notification.config.HealthOsProperties;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * Sends a WhatsApp text message via the Meta Cloud API. When the provider is not configured
 * (no token), the message is logged instead — this keeps OTP delivery working in dev without a
 * WhatsApp Business account.
 */
@Slf4j
@Component
public class MetaWhatsappClient {
  private final HealthOsProperties.Whatsapp config;
  private final RestClient restClient;

  public MetaWhatsappClient(HealthOsProperties props, RestClient.Builder builder) {
    this.config = props.getWhatsapp();
    this.restClient = builder.build();
  }

  /** Returns true if the message was handed off to Meta, false if only logged (dev fallback). */
  public boolean sendText(String to, String message) {
    if (!config.isEnabled() || isBlank(config.getAccessToken()) || isBlank(config.getPhoneNumberId())) {
      log.info("[DEV WhatsApp] to={} message=\"{}\"", to, message);
      return false;
    }

    var recipient = to.startsWith("+") ? to.substring(1) : to;
    var url = config.getApiUrl() + "/" + config.getPhoneNumberId() + "/messages";
    restClient
        .post()
        .uri(url)
        .header("Authorization", "Bearer " + config.getAccessToken())
        .contentType(MediaType.APPLICATION_JSON)
        .body(
            Map.of(
                "messaging_product", "whatsapp",
                "to", recipient,
                "type", "text",
                "text", Map.of("body", message)))
        .retrieve()
        .toBodilessEntity();
    log.info("WhatsApp message sent to {}", to);
    return true;
  }

  private static boolean isBlank(String s) {
    return s == null || s.isBlank();
  }
}
