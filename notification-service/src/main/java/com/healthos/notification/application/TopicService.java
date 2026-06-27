package com.healthos.notification.application;

import com.healthos.notification.adapters.outbound.persistence.NotificationTopicRepository;
import com.healthos.notification.domain.NotificationTopic;
import java.time.Instant;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class TopicService {

  private final NotificationTopicRepository repository;

  public NotificationTopic create(NotificationTopic topic) {
    if (repository.findByTopic(topic.getTopic()).isPresent()) {
      throw new IllegalStateException("Topic already exists: " + topic.getTopic());
    }
    topic.setCreatedAt(Instant.now());
    return repository.save(topic);
  }

  public List<NotificationTopic> listAll() {
    return repository.findAll();
  }
}
