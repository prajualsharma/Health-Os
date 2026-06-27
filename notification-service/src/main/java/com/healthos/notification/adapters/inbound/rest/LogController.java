package com.healthos.notification.adapters.inbound.rest;

import com.healthos.notification.adapters.inbound.rest.dto.NotificationDtos;
import com.healthos.notification.adapters.inbound.rest.mapper.NotificationMapper;
import com.healthos.notification.application.LogService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/logs")
@RequiredArgsConstructor
public class LogController {

  private final LogService logService;
  private final NotificationMapper mapper;

  @GetMapping
  @PreAuthorize("hasAnyRole('SUPER_ADMIN','NOTIFICATION_ADMIN','READ_ONLY')")
  public List<NotificationDtos.LogResponse> list() {
    return logService.listAll().stream().map(mapper::toResponse).toList();
  }

  @GetMapping("/{id}")
  @PreAuthorize("hasAnyRole('SUPER_ADMIN','NOTIFICATION_ADMIN','READ_ONLY')")
  public NotificationDtos.LogResponse get(@PathVariable String id) {
    return mapper.toResponse(logService.getById(id));
  }
}
