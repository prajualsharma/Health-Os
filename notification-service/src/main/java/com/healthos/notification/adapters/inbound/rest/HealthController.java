package com.healthos.notification.adapters.inbound.rest;

import com.healthos.notification.adapters.inbound.rest.dto.NotificationDtos;
import java.time.Instant;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

  @GetMapping("/health")
  public NotificationDtos.HealthResponse health() {
    return NotificationDtos.HealthResponse.builder()
        .status("UP")
        .service("notification-service")
        .timestamp(Instant.now())
        .build();
  }
}
