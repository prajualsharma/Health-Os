package com.healthos.notification.adapters.inbound.rest.mapper;

import com.healthos.notification.adapters.inbound.rest.dto.NotificationDtos;
import com.healthos.notification.domain.NotificationLog;
import com.healthos.notification.domain.NotificationTemplate;
import com.healthos.notification.domain.NotificationTopic;
import com.healthos.notification.domain.ProviderConfig;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface NotificationMapper {

  NotificationDtos.TemplateResponse toResponse(NotificationTemplate entity);

  @Mapping(target = "id", ignore = true)
  @Mapping(target = "createdAt", ignore = true)
  @Mapping(target = "updatedAt", ignore = true)
  NotificationTemplate toEntity(NotificationDtos.TemplateRequest request);

  NotificationDtos.ProviderConfigResponse toResponse(ProviderConfig entity);

  @Mapping(target = "id", ignore = true)
  @Mapping(target = "createdAt", ignore = true)
  @Mapping(target = "updatedAt", ignore = true)
  ProviderConfig toEntity(NotificationDtos.ProviderConfigRequest request);

  NotificationDtos.TopicResponse toResponse(NotificationTopic entity);

  @Mapping(target = "id", ignore = true)
  @Mapping(target = "createdAt", ignore = true)
  NotificationTopic toEntity(NotificationDtos.TopicRequest request);

  NotificationDtos.LogResponse toResponse(NotificationLog entity);
}
