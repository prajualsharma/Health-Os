package com.healthos.notification.adapters.outbound.provider;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthos.notification.domain.Provider;
import org.springframework.stereotype.Component;

@Component
public class SesEmailSenderStub extends AbstractStubProviderSender {

  public SesEmailSenderStub(ObjectMapper objectMapper) {
    super(objectMapper);
  }

  @Override
  protected Provider providerType() {
    return Provider.AWS_SES;
  }
}
