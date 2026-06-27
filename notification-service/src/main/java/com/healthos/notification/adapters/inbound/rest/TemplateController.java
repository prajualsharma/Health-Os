package com.healthos.notification.adapters.inbound.rest;

import com.healthos.notification.adapters.inbound.rest.dto.NotificationDtos;
import com.healthos.notification.adapters.inbound.rest.mapper.NotificationMapper;
import com.healthos.notification.application.TemplateService;
import com.healthos.notification.domain.NotificationTemplate;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/templates")
@RequiredArgsConstructor
public class TemplateController {

  private final TemplateService templateService;
  private final NotificationMapper mapper;

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  @PreAuthorize("hasAnyRole('SUPER_ADMIN','NOTIFICATION_ADMIN')")
  public NotificationDtos.TemplateResponse create(@Valid @RequestBody NotificationDtos.TemplateRequest request) {
    NotificationTemplate saved = templateService.create(mapper.toEntity(request));
    return mapper.toResponse(saved);
  }

  @PutMapping("/{id}")
  @PreAuthorize("hasAnyRole('SUPER_ADMIN','NOTIFICATION_ADMIN')")
  public NotificationDtos.TemplateResponse update(
      @PathVariable String id, @Valid @RequestBody NotificationDtos.TemplateRequest request) {
    NotificationTemplate updates = mapper.toEntity(request);
    return mapper.toResponse(templateService.update(id, updates));
  }

  @GetMapping
  @PreAuthorize("hasAnyRole('SUPER_ADMIN','NOTIFICATION_ADMIN','READ_ONLY')")
  public List<NotificationDtos.TemplateResponse> list() {
    return templateService.listAll().stream().map(mapper::toResponse).toList();
  }

  @GetMapping("/{id}")
  @PreAuthorize("hasAnyRole('SUPER_ADMIN','NOTIFICATION_ADMIN','READ_ONLY')")
  public NotificationDtos.TemplateResponse get(@PathVariable String id) {
    return mapper.toResponse(templateService.getById(id));
  }

  @DeleteMapping("/{id}")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  @PreAuthorize("hasAnyRole('SUPER_ADMIN','NOTIFICATION_ADMIN')")
  public void delete(@PathVariable String id) {
    templateService.delete(id);
  }
}
