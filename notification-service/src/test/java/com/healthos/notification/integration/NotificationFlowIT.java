package com.healthos.notification.integration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.awaitility.Awaitility.await;

import com.healthos.notification.adapters.outbound.persistence.NotificationLogRepository;
import com.healthos.notification.adapters.outbound.persistence.NotificationTemplateRepository;
import com.healthos.notification.adapters.outbound.persistence.ProviderConfigRepository;
import com.healthos.notification.domain.Channel;
import com.healthos.notification.domain.NotificationEvent;
import com.healthos.notification.domain.NotificationStatus;
import com.healthos.notification.domain.NotificationTemplate;
import com.healthos.notification.domain.Provider;
import com.healthos.notification.domain.ProviderConfig;
import com.healthos.notification.domain.ProviderType;
import com.healthos.notification.domain.Recipient;
import java.time.Duration;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.MongoDBContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.kafka.KafkaContainer;

@SpringBootTest
@ActiveProfiles("test")
@Testcontainers(disabledWithoutDocker = true)
class NotificationFlowIT {

  @Container static MongoDBContainer mongo = new MongoDBContainer("mongo:7");

  @Container static KafkaContainer kafka = new KafkaContainer("apache/kafka-native:3.7.0");

  @DynamicPropertySource
  static void props(DynamicPropertyRegistry registry) {
    registry.add("spring.data.mongodb.uri", mongo::getReplicaSetUrl);
    registry.add("spring.kafka.bootstrap-servers", kafka::getBootstrapServers);
    registry.add("healthos.notification.topics.main", () -> "notification-topic");
  }

  @Autowired private KafkaTemplate<String, NotificationEvent> kafkaTemplate;
  @Autowired private NotificationLogRepository logRepository;
  @Autowired private NotificationTemplateRepository templateRepository;
  @Autowired private ProviderConfigRepository providerConfigRepository;

  @MockBean private com.healthos.notification.adapters.outbound.redis.IdempotencyService idempotencyService;
  @MockBean private com.healthos.notification.adapters.outbound.redis.RateLimiter rateLimiter;

  @BeforeEach
  void seed() {
    logRepository.deleteAll();
    templateRepository.deleteAll();
    providerConfigRepository.deleteAll();

    templateRepository.save(
        NotificationTemplate.builder()
            .tenantId("gym001")
            .topic("MEMBERSHIP_EXPIRED")
            .channel(Channel.EMAIL)
            .subject("Hi {{firstName}}")
            .body("Expires {{expiryDate}}")
            .active(true)
            .build());

    providerConfigRepository.save(
        ProviderConfig.builder()
            .tenantId("gym001")
            .providerType(ProviderType.EMAIL)
            .provider(Provider.SMTP)
            .active(true)
            .config(
                Map.of(
                    "host", "localhost",
                    "port", "1025",
                    "auth", "false",
                    "from", "noreply@healthos.test"))
            .build());

    org.mockito.Mockito.when(idempotencyService.tryAcquire(org.mockito.ArgumentMatchers.anyString(), org.mockito.ArgumentMatchers.anyString(), org.mockito.ArgumentMatchers.any()))
        .thenReturn(true);
    org.mockito.Mockito.when(rateLimiter.allow(org.mockito.ArgumentMatchers.anyString())).thenReturn(true);
  }

  @Test
  void consumesEventAndPersistsLog() {
    NotificationEvent event =
        NotificationEvent.builder()
            .eventId("flow-evt-1")
            .tenantId("gym001")
            .topic("MEMBERSHIP_EXPIRED")
            .channels(List.of(Channel.EMAIL))
            .recipient(Recipient.builder().email("john@gmail.com").userId("123").build())
            .variables(Map.of("firstName", "John", "expiryDate", "2026-06-15"))
            .build();

    kafkaTemplate.send("notification-topic", event.getEventId(), event);

    await()
        .atMost(Duration.ofSeconds(30))
        .untilAsserted(
            () ->
                assertThat(
                        logRepository.findAll().stream()
                            .anyMatch(
                                l ->
                                    "flow-evt-1".equals(l.getEventId())
                                        && (l.getStatus() == NotificationStatus.SENT
                                            || l.getStatus() == NotificationStatus.FAILED)))
                    .isTrue());
  }
}
