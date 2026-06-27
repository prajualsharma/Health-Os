package com.healthos.notification.domain;

import java.time.Instant;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "notification_topics")
public class NotificationTopic {
  @Id
  private String id;
  @Indexed(unique = true)
  private String topic;
  private String description;
  private Instant createdAt;
}
