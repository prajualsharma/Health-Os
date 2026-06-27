package com.healthos.notification.adapters.outbound.provider;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthos.notification.domain.Provider;
import org.springframework.stereotype.Component;

@Component
public class TwilioSmsSenderStub extends AbstractStubProviderSender {

  public TwilioSmsSenderStub(ObjectMapper objectMapper) {
    super(objectMapper);
  }

  @Override
  protected Provider providerType() {
    return Provider.TWILIO;
  }
}
