package com.healthos.notification.application.factory;

import com.healthos.notification.adapters.outbound.provider.ProviderSender;
import com.healthos.notification.domain.Provider;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;

@Component
public class ProviderSenderFactory {

  private final Map<Provider, ProviderSender> senders;

  public ProviderSenderFactory(List<ProviderSender> senderList) {
    this.senders =
        senderList.stream().collect(Collectors.toMap(ProviderSender::provider, Function.identity()));
  }

  public ProviderSender resolve(Provider provider) {
    ProviderSender sender = senders.get(provider);
    if (sender == null) {
      throw new IllegalArgumentException("No provider sender registered for: " + provider);
    }
    return sender;
  }
}
