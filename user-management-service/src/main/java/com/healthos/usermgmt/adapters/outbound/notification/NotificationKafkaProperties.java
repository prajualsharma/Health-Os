package com.healthos.usermgmt.adapters.outbound.notification;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "healthos.kafka")
public class NotificationKafkaProperties {
  private boolean enabled = false;
  private String bootstrapServers = "localhost:9092";
  private String topic = "notification-topic";
}
