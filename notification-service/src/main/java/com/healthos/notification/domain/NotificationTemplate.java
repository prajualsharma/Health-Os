package com.healthos.notification.domain;

import java.time.Instant;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "notification_templates")
@CompoundIndex(name = "tenant_topic_channel_active", def = "{'tenantId': 1, 'topic': 1, 'channel': 1, 'active': 1}")
public class NotificationTemplate {
  @Id
  private String id;
  private String tenantId;
  private String topic;
  private Channel channel;
  private String subject;
  private String body;
  private boolean active;
  private Instant createdAt;
  private Instant updatedAt;
}
