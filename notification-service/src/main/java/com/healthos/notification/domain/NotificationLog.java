package com.healthos.notification.domain;

import java.time.Instant;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "notification_logs")
@CompoundIndex(name = "tenant_event_channel", def = "{'tenantId': 1, 'eventId': 1, 'channel': 1}")
public class NotificationLog {
  @Id
  private String id;
  private String eventId;
  private String tenantId;
  private String topic;
  private Channel channel;
  private String recipient;
  private String renderedMessage;
  private String provider;
  private NotificationStatus status;
  private int retryCount;
  private String requestPayload;
  private String responsePayload;
  private String errorMessage;
  @Indexed
  private Instant createdAt;
}
