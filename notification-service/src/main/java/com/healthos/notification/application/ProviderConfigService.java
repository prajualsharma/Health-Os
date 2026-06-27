package com.healthos.notification.application;

import com.healthos.notification.adapters.outbound.persistence.ProviderConfigRepository;
import com.healthos.notification.domain.ProviderConfig;
import com.healthos.notification.domain.ProviderType;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ProviderConfigService {

  private final ProviderConfigRepository repository;

  public Optional<ProviderConfig> findActive(String tenantId, ProviderType providerType) {
    Optional<ProviderConfig> tenantSpecific =
        repository.findFirstByTenantIdAndProviderTypeAndActiveTrue(tenantId, providerType);
    if (tenantSpecific.isPresent()) {
      return tenantSpecific;
    }
    return repository.findFirstByTenantIdIsNullAndProviderTypeAndActiveTrue(providerType);
  }

  public ProviderConfig create(ProviderConfig config) {
    config.setCreatedAt(Instant.now());
    config.setUpdatedAt(Instant.now());
    return repository.save(config);
  }

  public ProviderConfig update(String id, ProviderConfig updates) {
    ProviderConfig existing =
        repository.findById(id).orElseThrow(() -> new IllegalArgumentException("Provider config not found"));
    if (updates.getTenantId() != null) existing.setTenantId(updates.getTenantId());
    if (updates.getProviderType() != null) existing.setProviderType(updates.getProviderType());
    if (updates.getProvider() != null) existing.setProvider(updates.getProvider());
    if (updates.getConfig() != null) existing.setConfig(updates.getConfig());
    existing.setActive(updates.isActive());
    existing.setUpdatedAt(Instant.now());
    return repository.save(existing);
  }

  public ProviderConfig getById(String id) {
    return repository.findById(id).orElseThrow(() -> new IllegalArgumentException("Provider config not found"));
  }

  public List<ProviderConfig> listAll() {
    return repository.findAll();
  }
}
