package com.healthos.notification.config;

import com.healthos.notification.domain.NotificationLog;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.Index;
import org.springframework.data.mongodb.core.index.IndexOperations;

import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;

@Configuration
@RequiredArgsConstructor
public class MongoConfig {

  private final MongoTemplate mongoTemplate;

  @PostConstruct
  void ensureIndexes() {
    IndexOperations logOps = mongoTemplate.indexOps(NotificationLog.class);
    logOps.ensureIndex(
        new Index().on("createdAt", Sort.Direction.DESC).expire(90 * 24 * 3600L));
  }
}
