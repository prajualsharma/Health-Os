package com.healthos.notification.domain;

import java.util.List;
import java.util.Map;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationEvent {
  private String eventId;
  private String tenantId;
  private String topic;
  private List<Channel> channels;
  private Recipient recipient;
  private Map<String, Object> variables;
}
