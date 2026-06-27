package com.healthos.notification.application;

import com.healthos.notification.adapters.outbound.persistence.NotificationTemplateRepository;
import com.healthos.notification.domain.Channel;
import com.healthos.notification.domain.NotificationTemplate;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class TemplateService {

  private final NotificationTemplateRepository repository;

  public Optional<NotificationTemplate> findActive(String tenantId, String topic, Channel channel) {
    Optional<NotificationTemplate> tenantSpecific =
        repository.findFirstByTenantIdAndTopicAndChannelAndActiveTrue(tenantId, topic, channel);
    if (tenantSpecific.isPresent()) {
      return tenantSpecific;
    }
    return repository.findFirstByTenantIdIsNullAndTopicAndChannelAndActiveTrue(topic, channel);
  }

  public NotificationTemplate create(NotificationTemplate template) {
    template.setCreatedAt(Instant.now());
    template.setUpdatedAt(Instant.now());
    return repository.save(template);
  }

  public NotificationTemplate update(String id, NotificationTemplate updates) {
    NotificationTemplate existing =
        repository.findById(id).orElseThrow(() -> new IllegalArgumentException("Template not found"));
    if (updates.getTopic() != null) existing.setTopic(updates.getTopic());
    if (updates.getTenantId() != null) existing.setTenantId(updates.getTenantId());
    if (updates.getChannel() != null) existing.setChannel(updates.getChannel());
    if (updates.getSubject() != null) existing.setSubject(updates.getSubject());
    if (updates.getBody() != null) existing.setBody(updates.getBody());
    existing.setActive(updates.isActive());
    existing.setUpdatedAt(Instant.now());
    return repository.save(existing);
  }

  public NotificationTemplate getById(String id) {
    return repository.findById(id).orElseThrow(() -> new IllegalArgumentException("Template not found"));
  }

  public List<NotificationTemplate> listAll() {
    return repository.findAll();
  }

  public void delete(String id) {
    repository.deleteById(id);
  }
}
