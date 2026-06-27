package com.healthos.notification.adapters.inbound.rest;

import com.healthos.notification.adapters.inbound.rest.dto.NotificationDtos;
import com.healthos.notification.adapters.inbound.rest.mapper.NotificationMapper;
import com.healthos.notification.application.ProviderConfigService;
import com.healthos.notification.domain.ProviderConfig;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/provider-configs")
@RequiredArgsConstructor
public class ProviderConfigController {

  private final ProviderConfigService providerConfigService;
  private final NotificationMapper mapper;

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  @PreAuthorize("hasAnyRole('SUPER_ADMIN','NOTIFICATION_ADMIN')")
  public NotificationDtos.ProviderConfigResponse create(
      @Valid @RequestBody NotificationDtos.ProviderConfigRequest request) {
    ProviderConfig saved = providerConfigService.create(mapper.toEntity(request));
    return mapper.toResponse(saved);
  }

  @PutMapping("/{id}")
  @PreAuthorize("hasAnyRole('SUPER_ADMIN','NOTIFICATION_ADMIN')")
  public NotificationDtos.ProviderConfigResponse update(
      @PathVariable String id, @Valid @RequestBody NotificationDtos.ProviderConfigRequest request) {
    ProviderConfig updates = mapper.toEntity(request);
    return mapper.toResponse(providerConfigService.update(id, updates));
  }

  @GetMapping
  @PreAuthorize("hasAnyRole('SUPER_ADMIN','NOTIFICATION_ADMIN','READ_ONLY')")
  public List<NotificationDtos.ProviderConfigResponse> list() {
    return providerConfigService.listAll().stream().map(mapper::toResponse).toList();
  }

  @GetMapping("/{id}")
  @PreAuthorize("hasAnyRole('SUPER_ADMIN','NOTIFICATION_ADMIN','READ_ONLY')")
  public NotificationDtos.ProviderConfigResponse get(@PathVariable String id) {
    return mapper.toResponse(providerConfigService.getById(id));
  }
}
