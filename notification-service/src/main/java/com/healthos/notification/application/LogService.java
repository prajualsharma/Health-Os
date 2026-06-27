package com.healthos.notification.application;

import com.healthos.notification.adapters.outbound.persistence.NotificationLogRepository;
import com.healthos.notification.domain.Channel;
import com.healthos.notification.domain.NotificationEvent;
import com.healthos.notification.domain.NotificationLog;
import com.healthos.notification.domain.NotificationResult;
import com.healthos.notification.domain.NotificationStatus;
import com.healthos.notification.domain.Recipient;
import java.time.Instant;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class LogService {

  private final NotificationLogRepository repository;

  public NotificationLog save(
      NotificationEvent event,
      Channel channel,
      Recipient recipient,
      NotificationResult result) {
    NotificationLog log =
        NotificationLog.builder()
            .eventId(event.getEventId())
            .tenantId(event.getTenantId())
            .topic(event.getTopic())
            .channel(channel)
            .recipient(formatRecipient(recipient, channel))
            .renderedMessage(result.getRenderedMessage())
            .provider(result.getProvider())
            .status(result.getStatus())
            .retryCount(result.getRetryCount())
            .requestPayload(result.getRequestPayload())
            .responsePayload(result.getResponsePayload())
            .errorMessage(result.getErrorMessage())
            .createdAt(Instant.now())
            .build();
    return repository.save(log);
  }

  public NotificationLog saveStatus(
      NotificationEvent event, Channel channel, Recipient recipient, NotificationStatus status) {
    return save(
        event,
        channel,
        recipient,
        NotificationResult.builder().status(status).build());
  }

  public NotificationLog getById(String id) {
    return repository.findById(id).orElseThrow(() -> new IllegalArgumentException("Log not found"));
  }

  public List<NotificationLog> listAll() {
    return repository.findAllByOrderByCreatedAtDesc();
  }

  private static String formatRecipient(Recipient recipient, Channel channel) {
    if (recipient == null) return null;
    return switch (channel) {
      case EMAIL -> recipient.getEmail();
      case SMS, WHATSAPP -> recipient.getMobile();
      default -> recipient.getUserId();
    };
  }
}
