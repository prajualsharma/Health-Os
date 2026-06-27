package com.healthos.notification.adapters.outbound.messaging;

import com.healthos.notification.config.HealthOsProperties;
import com.healthos.notification.domain.NotificationEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class NotificationDltProducer {

  private final KafkaTemplate<String, NotificationEvent> kafkaTemplate;
  private final HealthOsProperties properties;

  public void publishToDlt(NotificationEvent event) {
    kafkaTemplate.send(properties.getNotification().getTopics().getDlt(), event.getEventId(), event);
  }
}
