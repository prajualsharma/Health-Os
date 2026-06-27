package com.healthos.notification.adapters.outbound.provider;

import com.healthos.notification.domain.Provider;
import com.healthos.notification.domain.ProviderConfig;
import com.healthos.notification.domain.ProviderResponse;
import com.healthos.notification.domain.Recipient;

public interface ProviderSender {
  Provider provider();

  ProviderResponse send(
      ProviderConfig config,
      Recipient recipient,
      String subject,
      String body);
}
