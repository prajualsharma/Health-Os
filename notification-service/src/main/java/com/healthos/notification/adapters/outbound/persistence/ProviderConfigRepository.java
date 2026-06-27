package com.healthos.notification.adapters.outbound.persistence;

import com.healthos.notification.domain.ProviderConfig;
import com.healthos.notification.domain.ProviderType;
import java.util.List;
import java.util.Optional;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ProviderConfigRepository extends MongoRepository<ProviderConfig, String> {

  Optional<ProviderConfig> findFirstByTenantIdAndProviderTypeAndActiveTrue(
      String tenantId, ProviderType providerType);

  Optional<ProviderConfig> findFirstByTenantIdIsNullAndProviderTypeAndActiveTrue(
      ProviderType providerType);

  List<ProviderConfig> findByTenantId(String tenantId);

  List<ProviderConfig> findAll();
}
