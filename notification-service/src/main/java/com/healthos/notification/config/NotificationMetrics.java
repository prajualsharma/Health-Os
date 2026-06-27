package com.healthos.notification.config;

import com.healthos.notification.domain.Channel;
import com.healthos.notification.domain.NotificationStatus;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.stereotype.Component;

@Component
public class NotificationMetrics {

  private final MeterRegistry meterRegistry;

  public NotificationMetrics(MeterRegistry meterRegistry) {
    this.meterRegistry = meterRegistry;
  }

  public void recordSent(Channel channel, String provider, NotificationStatus status) {
    Counter.builder("notifications_sent_total")
        .tag("channel", channel.name())
        .tag("provider", provider != null ? provider : "unknown")
        .tag("status", status.name())
        .register(meterRegistry)
        .increment();
  }
}
