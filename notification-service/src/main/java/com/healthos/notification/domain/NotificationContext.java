package com.healthos.notification.domain;

import java.util.Map;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationContext {
  private String eventId;
  private String tenantId;
  private String topic;
  private Channel channel;
  private Recipient recipient;
  private Map<String, Object> variables;
  private String renderedSubject;
  private String renderedBody;
  private ProviderConfig providerConfig;
}
