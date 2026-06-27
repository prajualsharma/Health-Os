package com.healthos.notification.application.factory;

import com.healthos.notification.application.strategy.NotificationStrategy;
import com.healthos.notification.domain.Channel;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;

@Component
public class NotificationStrategyFactory {

  private final Map<Channel, NotificationStrategy> strategies;

  public NotificationStrategyFactory(List<NotificationStrategy> strategyList) {
    this.strategies =
        strategyList.stream()
            .collect(Collectors.toMap(NotificationStrategy::channel, Function.identity()));
  }

  public NotificationStrategy resolve(Channel channel) {
    NotificationStrategy strategy = strategies.get(channel);
    if (strategy == null) {
      throw new IllegalArgumentException("No strategy registered for channel: " + channel);
    }
    return strategy;
  }
}
