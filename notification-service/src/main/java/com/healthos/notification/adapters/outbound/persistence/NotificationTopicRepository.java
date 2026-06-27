package com.healthos.notification.adapters.outbound.persistence;

import com.healthos.notification.domain.NotificationTopic;
import java.util.Optional;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface NotificationTopicRepository extends MongoRepository<NotificationTopic, String> {

  Optional<NotificationTopic> findByTopic(String topic);
}
