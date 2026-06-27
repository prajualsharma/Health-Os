package com.healthos.notification.application.strategy;

import com.healthos.notification.application.factory.ProviderSenderFactory;
import com.healthos.notification.domain.Channel;
import com.healthos.notification.domain.NotificationContext;
import com.healthos.notification.domain.NotificationResult;
import org.springframework.stereotype.Component;

@Component
public class SmsNotificationStrategy extends AbstractChannelStrategy {

  public SmsNotificationStrategy(ProviderSenderFactory providerSenderFactory) {
    super(providerSenderFactory);
  }

  @Override
  public Channel channel() {
    return Channel.SMS;
  }

  @Override
  public NotificationResult send(NotificationContext context) {
    return dispatch(context);
  }
}
