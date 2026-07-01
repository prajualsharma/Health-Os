package com.healthos.usermgmt.adapters.outbound.notification;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class NotificationEventPublisher {
  private final ObjectMapper objectMapper;
  private final NotificationKafkaProperties properties;

  @Autowired(required = false)
  private KafkaTemplate<String, String> kafkaTemplate;

  public void publishAbandonedOnboarding(
      String tenantId,
      String phone,
      String email,
      String firstName,
      String stepLabel,
      String resumeUrl) {
    if (!properties.isEnabled() || kafkaTemplate == null) {
      log.info(
          "Kafka notifications disabled; skipped abandoned onboarding event for {}",
          phone);
      return;
    }

    var channels = new java.util.ArrayList<String>();
    channels.add("WHATSAPP");
    channels.add("SMS");
    if (email != null && !email.isBlank()) {
      channels.add("EMAIL");
    }

    var recipient = new LinkedHashMap<String, String>();
    recipient.put("mobile", phone);
    if (email != null && !email.isBlank()) {
      recipient.put("email", email);
    }

    var variables = new LinkedHashMap<String, String>();
    variables.put("firstName", firstName != null && !firstName.isBlank() ? firstName : "there");
    variables.put("stepLabel", stepLabel);
    variables.put("resumeUrl", resumeUrl);

    var event =
        Map.of(
            "eventId", UUID.randomUUID().toString(),
            "tenantId", tenantId,
            "topic", "nutrikit.onboarding.abandoned",
            "channels", channels,
            "recipient", recipient,
            "variables", variables);

    try {
      var payload = objectMapper.writeValueAsString(event);
      kafkaTemplate.send(properties.getTopic(), phone, payload);
      log.info("Published abandoned onboarding notification for {}", phone);
    } catch (JsonProcessingException e) {
      throw new IllegalStateException("Failed to serialize notification event", e);
    }
  }
}
