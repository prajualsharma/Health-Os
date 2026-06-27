package com.healthos.notification.adapters.outbound.persistence;

import com.healthos.notification.domain.NotificationLog;
import java.util.List;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface NotificationLogRepository extends MongoRepository<NotificationLog, String> {

  List<NotificationLog> findByTenantIdOrderByCreatedAtDesc(String tenantId);

  List<NotificationLog> findAllByOrderByCreatedAtDesc();
}
