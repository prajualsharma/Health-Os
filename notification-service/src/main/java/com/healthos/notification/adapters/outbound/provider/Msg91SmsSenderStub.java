package com.healthos.notification.adapters.outbound.provider;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthos.notification.domain.Provider;
import org.springframework.stereotype.Component;

@Component
public class Msg91SmsSenderStub extends AbstractStubProviderSender {

  public Msg91SmsSenderStub(ObjectMapper objectMapper) {
    super(objectMapper);
  }

  @Override
  protected Provider providerType() {
    return Provider.MSG91;
  }
}
