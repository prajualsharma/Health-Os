package com.healthos.notification.adapters.inbound.rest;

import com.healthos.notification.adapters.inbound.rest.dto.NotificationDtos;
import com.healthos.notification.adapters.inbound.rest.mapper.NotificationMapper;
import com.healthos.notification.application.TopicService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/topics")
@RequiredArgsConstructor
public class TopicController {

  private final TopicService topicService;
  private final NotificationMapper mapper;

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  @PreAuthorize("hasAnyRole('SUPER_ADMIN','NOTIFICATION_ADMIN')")
  public NotificationDtos.TopicResponse create(@Valid @RequestBody NotificationDtos.TopicRequest request) {
    return mapper.toResponse(topicService.create(mapper.toEntity(request)));
  }

  @GetMapping
  @PreAuthorize("hasAnyRole('SUPER_ADMIN','NOTIFICATION_ADMIN','READ_ONLY')")
  public List<NotificationDtos.TopicResponse> list() {
    return topicService.listAll().stream().map(mapper::toResponse).toList();
  }
}
