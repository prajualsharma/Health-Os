package com.healthos.notification.adapters.inbound.messaging;

import com.healthos.notification.application.NotificationProcessor;
import com.healthos.notification.domain.NotificationEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.annotation.RetryableTopic;
import org.springframework.kafka.retrytopic.DltStrategy;
import org.springframework.kafka.retrytopic.TopicSuffixingStrategy;
import org.springframework.retry.annotation.Backoff;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class NotificationKafkaConsumer {

  private final NotificationProcessor notificationProcessor;

  @RetryableTopic(
      attempts = "4",
      backoff = @Backoff(delay = 1000, multiplier = 2.0, maxDelay = 10000),
      autoCreateTopics = "true",
      retryTopicSuffix = "-retry",
      dltTopicSuffix = "-dlt",
      topicSuffixingStrategy = TopicSuffixingStrategy.SUFFIX_WITH_INDEX_VALUE,
      dltStrategy = DltStrategy.FAIL_ON_ERROR)
  @KafkaListener(
      topics = "${healthos.notification.topics.main:notification-topic}",
      groupId = "notification-service",
      containerFactory = "notificationKafkaListenerContainerFactory")
  public void consume(NotificationEvent event) {
    String correlationId = MDC.get("correlationId");
    if (correlationId == null) {
      MDC.put("correlationId", event.getEventId());
    }
    MDC.put("eventId", event.getEventId());
    MDC.put("tenantId", event.getTenantId());
    log.info(
        "Consuming notification event eventId={} tenantId={} topic={}",
        event.getEventId(),
        event.getTenantId(),
        event.getTopic());
    notificationProcessor.process(event);
  }

  @KafkaListener(
      topics = "${healthos.notification.topics.dlt:notification-dlt}",
      groupId = "notification-service-dlt")
  public void consumeDlt(NotificationEvent event) {
    log.error(
        "Message in DLT eventId={} tenantId={} — manual replay required",
        event.getEventId(),
        event.getTenantId());
  }
}
