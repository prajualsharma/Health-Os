package com.healthos.notification.application;

import com.healthos.notification.adapters.outbound.redis.IdempotencyService;
import com.healthos.notification.adapters.outbound.redis.RateLimiter;
import com.healthos.notification.application.factory.NotificationStrategyFactory;
import com.healthos.notification.config.NotificationMetrics;
import com.healthos.notification.domain.Channel;
import com.healthos.notification.domain.NotificationContext;
import com.healthos.notification.domain.NotificationEvent;
import com.healthos.notification.domain.NotificationResult;
import com.healthos.notification.domain.NotificationStatus;
import com.healthos.notification.domain.NotificationTemplate;
import com.healthos.notification.domain.ProviderConfig;
import com.healthos.notification.domain.ProviderType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationProcessor {

  private final IdempotencyService idempotencyService;
  private final RateLimiter rateLimiter;
  private final TemplateService templateService;
  private final ProviderConfigService providerConfigService;
  private final HandlebarsTemplateRenderer templateRenderer;
  private final NotificationStrategyFactory strategyFactory;
  private final LogService logService;
  private final NotificationMetrics metrics;

  public void process(NotificationEvent event) {
    MDC.put("eventId", event.getEventId());
    MDC.put("tenantId", event.getTenantId());

    if (!rateLimiter.allow(event.getTenantId())) {
      log.warn("Rate limit exceeded for tenant {}", event.getTenantId());
      for (Channel channel : event.getChannels()) {
        logService.saveStatus(event, channel, event.getRecipient(), NotificationStatus.RATE_LIMITED);
        metrics.recordSent(channel, null, NotificationStatus.RATE_LIMITED);
      }
      return;
    }

    for (Channel channel : event.getChannels()) {
      processChannel(event, channel);
    }
  }

  private void processChannel(NotificationEvent event, Channel channel) {
    if (channel == Channel.PUSH) {
      log.info("PUSH channel not yet implemented, skipping event {}", event.getEventId());
      return;
    }

    if (!idempotencyService.tryAcquire(event.getTenantId(), event.getEventId(), channel)) {
      log.info("Duplicate event skipped: {} channel {}", event.getEventId(), channel);
      logService.saveStatus(event, channel, event.getRecipient(), NotificationStatus.DUPLICATE);
      metrics.recordSent(channel, null, NotificationStatus.DUPLICATE);
      return;
    }

    NotificationTemplate template =
        templateService
            .findActive(event.getTenantId(), event.getTopic(), channel)
            .orElseThrow(
                () ->
                    new IllegalArgumentException(
                        "No active template for topic="
                            + event.getTopic()
                            + " channel="
                            + channel));

    String renderedSubject =
        template.getSubject() != null
            ? templateRenderer.render(template.getSubject(), event.getVariables())
            : null;
    String renderedBody = templateRenderer.render(template.getBody(), event.getVariables());

    ProviderType providerType = mapChannelToProviderType(channel);
    ProviderConfig providerConfig =
        providerConfigService
            .findActive(event.getTenantId(), providerType)
            .orElseThrow(
                () ->
                    new IllegalArgumentException(
                        "No active provider config for type=" + providerType));

    NotificationContext context =
        NotificationContext.builder()
            .eventId(event.getEventId())
            .tenantId(event.getTenantId())
            .topic(event.getTopic())
            .channel(channel)
            .recipient(event.getRecipient())
            .variables(event.getVariables())
            .renderedSubject(renderedSubject)
            .renderedBody(renderedBody)
            .providerConfig(providerConfig)
            .build();

    NotificationResult result = strategyFactory.resolve(channel).send(context);
    logService.save(event, channel, event.getRecipient(), result);
    metrics.recordSent(channel, result.getProvider(), result.getStatus());
    log.info(
        "Notification processed eventId={} channel={} status={}",
        event.getEventId(),
        channel,
        result.getStatus());
  }

  private static ProviderType mapChannelToProviderType(Channel channel) {
    return switch (channel) {
      case EMAIL -> ProviderType.EMAIL;
      case SMS -> ProviderType.SMS;
      case WHATSAPP -> ProviderType.WHATSAPP;
      default -> throw new IllegalArgumentException("Unsupported channel: " + channel);
    };
  }
}
