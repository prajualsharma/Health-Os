package com.healthos.notification.adapters.outbound.persistence;

import com.healthos.notification.domain.Channel;
import com.healthos.notification.domain.NotificationTemplate;
import java.util.List;
import java.util.Optional;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface NotificationTemplateRepository extends MongoRepository<NotificationTemplate, String> {

  Optional<NotificationTemplate> findFirstByTenantIdAndTopicAndChannelAndActiveTrue(
      String tenantId, String topic, Channel channel);

  Optional<NotificationTemplate> findFirstByTenantIdIsNullAndTopicAndChannelAndActiveTrue(
      String topic, Channel channel);

  List<NotificationTemplate> findByTenantId(String tenantId);

  List<NotificationTemplate> findAll();
}
