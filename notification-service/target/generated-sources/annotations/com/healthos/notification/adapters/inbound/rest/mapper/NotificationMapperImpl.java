package com.healthos.notification.adapters.inbound.rest.mapper;

import com.healthos.notification.adapters.inbound.rest.dto.NotificationDtos;
import com.healthos.notification.domain.NotificationLog;
import com.healthos.notification.domain.NotificationTemplate;
import com.healthos.notification.domain.NotificationTopic;
import com.healthos.notification.domain.ProviderConfig;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-06-19T18:13:58+0530",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.11 (Ubuntu)"
)
@Component
public class NotificationMapperImpl implements NotificationMapper {

    @Override
    public NotificationDtos.TemplateResponse toResponse(NotificationTemplate entity) {
        if ( entity == null ) {
            return null;
        }

        NotificationDtos.TemplateResponse.TemplateResponseBuilder templateResponse = NotificationDtos.TemplateResponse.builder();

        templateResponse.id( entity.getId() );
        templateResponse.tenantId( entity.getTenantId() );
        templateResponse.topic( entity.getTopic() );
        templateResponse.channel( entity.getChannel() );
        templateResponse.subject( entity.getSubject() );
        templateResponse.body( entity.getBody() );
        templateResponse.active( entity.isActive() );
        templateResponse.createdAt( entity.getCreatedAt() );
        templateResponse.updatedAt( entity.getUpdatedAt() );

        return templateResponse.build();
    }

    @Override
    public NotificationTemplate toEntity(NotificationDtos.TemplateRequest request) {
        if ( request == null ) {
            return null;
        }

        NotificationTemplate.NotificationTemplateBuilder notificationTemplate = NotificationTemplate.builder();

        notificationTemplate.tenantId( request.tenantId() );
        notificationTemplate.topic( request.topic() );
        notificationTemplate.channel( request.channel() );
        notificationTemplate.subject( request.subject() );
        notificationTemplate.body( request.body() );
        notificationTemplate.active( request.active() );

        return notificationTemplate.build();
    }

    @Override
    public NotificationDtos.ProviderConfigResponse toResponse(ProviderConfig entity) {
        if ( entity == null ) {
            return null;
        }

        NotificationDtos.ProviderConfigResponse.ProviderConfigResponseBuilder providerConfigResponse = NotificationDtos.ProviderConfigResponse.builder();

        providerConfigResponse.id( entity.getId() );
        providerConfigResponse.tenantId( entity.getTenantId() );
        providerConfigResponse.providerType( entity.getProviderType() );
        providerConfigResponse.provider( entity.getProvider() );
        providerConfigResponse.active( entity.isActive() );
        Map<String, String> map = entity.getConfig();
        if ( map != null ) {
            providerConfigResponse.config( new LinkedHashMap<String, String>( map ) );
        }
        providerConfigResponse.createdAt( entity.getCreatedAt() );
        providerConfigResponse.updatedAt( entity.getUpdatedAt() );

        return providerConfigResponse.build();
    }

    @Override
    public ProviderConfig toEntity(NotificationDtos.ProviderConfigRequest request) {
        if ( request == null ) {
            return null;
        }

        ProviderConfig.ProviderConfigBuilder providerConfig = ProviderConfig.builder();

        providerConfig.tenantId( request.tenantId() );
        providerConfig.providerType( request.providerType() );
        providerConfig.provider( request.provider() );
        providerConfig.active( request.active() );
        Map<String, String> map = request.config();
        if ( map != null ) {
            providerConfig.config( new LinkedHashMap<String, String>( map ) );
        }

        return providerConfig.build();
    }

    @Override
    public NotificationDtos.TopicResponse toResponse(NotificationTopic entity) {
        if ( entity == null ) {
            return null;
        }

        NotificationDtos.TopicResponse.TopicResponseBuilder topicResponse = NotificationDtos.TopicResponse.builder();

        topicResponse.id( entity.getId() );
        topicResponse.topic( entity.getTopic() );
        topicResponse.description( entity.getDescription() );
        topicResponse.createdAt( entity.getCreatedAt() );

        return topicResponse.build();
    }

    @Override
    public NotificationTopic toEntity(NotificationDtos.TopicRequest request) {
        if ( request == null ) {
            return null;
        }

        NotificationTopic.NotificationTopicBuilder notificationTopic = NotificationTopic.builder();

        notificationTopic.topic( request.topic() );
        notificationTopic.description( request.description() );

        return notificationTopic.build();
    }

    @Override
    public NotificationDtos.LogResponse toResponse(NotificationLog entity) {
        if ( entity == null ) {
            return null;
        }

        NotificationDtos.LogResponse.LogResponseBuilder logResponse = NotificationDtos.LogResponse.builder();

        logResponse.id( entity.getId() );
        logResponse.eventId( entity.getEventId() );
        logResponse.tenantId( entity.getTenantId() );
        logResponse.topic( entity.getTopic() );
        logResponse.channel( entity.getChannel() );
        logResponse.recipient( entity.getRecipient() );
        logResponse.renderedMessage( entity.getRenderedMessage() );
        logResponse.provider( entity.getProvider() );
        logResponse.status( entity.getStatus() );
        logResponse.retryCount( entity.getRetryCount() );
        logResponse.requestPayload( entity.getRequestPayload() );
        logResponse.responsePayload( entity.getResponsePayload() );
        logResponse.errorMessage( entity.getErrorMessage() );
        logResponse.createdAt( entity.getCreatedAt() );

        return logResponse.build();
    }
}
