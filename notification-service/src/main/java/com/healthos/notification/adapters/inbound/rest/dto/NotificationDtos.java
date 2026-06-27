package com.healthos.notification.adapters.inbound.rest.dto;

import com.healthos.notification.domain.Channel;
import com.healthos.notification.domain.NotificationStatus;
import com.healthos.notification.domain.Provider;
import com.healthos.notification.domain.ProviderType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.Instant;
import java.util.Map;
import lombok.Builder;

public final class NotificationDtos {
  private NotificationDtos() {}

  @Builder
  public record TemplateRequest(
      String tenantId,
      @NotBlank String topic,
      @NotNull Channel channel,
      String subject,
      @NotBlank String body,
      boolean active) {}

  @Builder
  public record TemplateResponse(
      String id,
      String tenantId,
      String topic,
      Channel channel,
      String subject,
      String body,
      boolean active,
      Instant createdAt,
      Instant updatedAt) {}

  @Builder
  public record ProviderConfigRequest(
      String tenantId,
      @NotNull ProviderType providerType,
      @NotNull Provider provider,
      boolean active,
      Map<String, String> config) {}

  @Builder
  public record ProviderConfigResponse(
      String id,
      String tenantId,
      ProviderType providerType,
      Provider provider,
      boolean active,
      Map<String, String> config,
      Instant createdAt,
      Instant updatedAt) {}

  @Builder
  public record TopicRequest(@NotBlank String topic, String description) {}

  @Builder
  public record TopicResponse(String id, String topic, String description, Instant createdAt) {}

  @Builder
  public record LogResponse(
      String id,
      String eventId,
      String tenantId,
      String topic,
      Channel channel,
      String recipient,
      String renderedMessage,
      String provider,
      NotificationStatus status,
      int retryCount,
      String requestPayload,
      String responsePayload,
      String errorMessage,
      Instant createdAt) {}

  @Builder
  public record HealthResponse(String status, String service, Instant timestamp) {}
}
