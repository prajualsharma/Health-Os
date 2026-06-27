package com.healthos.notification.application.strategy;

import com.healthos.notification.domain.Channel;
import com.healthos.notification.domain.NotificationContext;
import com.healthos.notification.domain.NotificationResult;

public interface NotificationStrategy {
  Channel channel();

  NotificationResult send(NotificationContext context);
}
