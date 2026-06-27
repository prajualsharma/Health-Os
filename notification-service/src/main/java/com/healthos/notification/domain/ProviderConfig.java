package com.healthos.notification.domain;

import java.time.Instant;
import java.util.Map;
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
@Document(collection = "notification_provider_configs")
@CompoundIndex(name = "tenant_type_active", def = "{'tenantId': 1, 'providerType': 1, 'active': 1}")
public class ProviderConfig {
  @Id
  private String id;
  private String tenantId;
  private ProviderType providerType;
  private Provider provider;
  private boolean active;
  private Map<String, String> config;
  private Instant createdAt;
  private Instant updatedAt;
}
