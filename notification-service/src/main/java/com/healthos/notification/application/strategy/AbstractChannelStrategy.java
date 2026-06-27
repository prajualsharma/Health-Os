package com.healthos.notification.application.strategy;

import com.healthos.notification.application.factory.ProviderSenderFactory;
import com.healthos.notification.domain.NotificationContext;
import com.healthos.notification.domain.NotificationResult;
import com.healthos.notification.domain.ProviderConfig;
import com.healthos.notification.domain.ProviderResponse;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public abstract class AbstractChannelStrategy implements NotificationStrategy {

  protected final ProviderSenderFactory providerSenderFactory;

  protected NotificationResult dispatch(NotificationContext context) {
    ProviderConfig config = context.getProviderConfig();
    if (config == null || !config.isActive()) {
      return NotificationResult.failed(
          null, "No active provider configuration", null);
    }
    var sender = providerSenderFactory.resolve(config.getProvider());
    ProviderResponse response =
        sender.send(
            config,
            context.getRecipient(),
            context.getRenderedSubject(),
            context.getRenderedBody());
    String rendered =
        context.getRenderedSubject() != null
            ? context.getRenderedSubject() + " | " + context.getRenderedBody()
            : context.getRenderedBody();
    if (response.isSuccess()) {
      return NotificationResult.sent(
          config.getProvider().name(),
          rendered,
          response.getRequestPayload(),
          response.getResponsePayload());
    }
    return NotificationResult.failed(
        config.getProvider().name(),
        response.getErrorMessage(),
        response.getRequestPayload());
  }
}
