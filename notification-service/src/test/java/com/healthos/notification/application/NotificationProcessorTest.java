package com.healthos.notification.application;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.healthos.notification.adapters.outbound.redis.IdempotencyService;
import com.healthos.notification.adapters.outbound.redis.RateLimiter;
import com.healthos.notification.application.factory.NotificationStrategyFactory;
import com.healthos.notification.application.strategy.NotificationStrategy;
import com.healthos.notification.config.NotificationMetrics;
import com.healthos.notification.domain.Channel;
import com.healthos.notification.domain.NotificationEvent;
import com.healthos.notification.domain.NotificationResult;
import com.healthos.notification.domain.NotificationStatus;
import com.healthos.notification.domain.NotificationTemplate;
import com.healthos.notification.domain.Provider;
import com.healthos.notification.domain.ProviderConfig;
import com.healthos.notification.domain.ProviderType;
import com.healthos.notification.domain.Recipient;
import io.micrometer.core.instrument.simple.SimpleMeterRegistry;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class NotificationProcessorTest {

  @Mock private IdempotencyService idempotencyService;
  @Mock private RateLimiter rateLimiter;
  @Mock private TemplateService templateService;
  @Mock private ProviderConfigService providerConfigService;
  @Mock private NotificationStrategyFactory strategyFactory;
  @Mock private NotificationStrategy emailStrategy;
  @Mock private LogService logService;

  private NotificationProcessor processor;

  @BeforeEach
  void setUp() {
    processor =
        new NotificationProcessor(
            idempotencyService,
            rateLimiter,
            templateService,
            providerConfigService,
            new HandlebarsTemplateRenderer(),
            strategyFactory,
            logService,
            new NotificationMetrics(new SimpleMeterRegistry()));
  }

  @Test
  void processesEmailChannel() {
    NotificationEvent event = sampleEvent();
    when(rateLimiter.allow("gym001")).thenReturn(true);
    when(idempotencyService.tryAcquire("gym001", "evt-1", Channel.EMAIL)).thenReturn(true);
    when(templateService.findActive("gym001", "MEMBERSHIP_EXPIRED", Channel.EMAIL))
        .thenReturn(Optional.of(sampleTemplate()));
    when(providerConfigService.findActive("gym001", ProviderType.EMAIL))
        .thenReturn(Optional.of(sampleProviderConfig()));
    when(strategyFactory.resolve(Channel.EMAIL)).thenReturn(emailStrategy);
    when(emailStrategy.send(any()))
        .thenReturn(NotificationResult.sent("SMTP", "sub | body", "{}", "{}"));

    processor.process(event);

    verify(logService).save(eq(event), eq(Channel.EMAIL), any(), any());
  }

  @Test
  void skipsDuplicate() {
    NotificationEvent event = sampleEvent();
    when(rateLimiter.allow("gym001")).thenReturn(true);
    when(idempotencyService.tryAcquire("gym001", "evt-1", Channel.EMAIL)).thenReturn(false);

    processor.process(event);

    verify(strategyFactory, never()).resolve(any());
    verify(logService)
        .saveStatus(event, Channel.EMAIL, event.getRecipient(), NotificationStatus.DUPLICATE);
  }

  private static NotificationEvent sampleEvent() {
    return NotificationEvent.builder()
        .eventId("evt-1")
        .tenantId("gym001")
        .topic("MEMBERSHIP_EXPIRED")
        .channels(List.of(Channel.EMAIL))
        .recipient(Recipient.builder().email("john@gmail.com").build())
        .variables(Map.of("firstName", "John"))
        .build();
  }

  private static NotificationTemplate sampleTemplate() {
    return NotificationTemplate.builder()
        .topic("MEMBERSHIP_EXPIRED")
        .channel(Channel.EMAIL)
        .subject("Hi {{firstName}}")
        .body("Expires soon")
        .active(true)
        .build();
  }

  private static ProviderConfig sampleProviderConfig() {
    return ProviderConfig.builder()
        .providerType(ProviderType.EMAIL)
        .provider(Provider.SMTP)
        .active(true)
        .config(Map.of("host", "localhost", "port", "1025"))
        .build();
  }
}
