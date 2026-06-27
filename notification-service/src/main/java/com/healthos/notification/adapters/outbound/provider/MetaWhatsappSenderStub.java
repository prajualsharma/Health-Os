package com.healthos.notification.adapters.outbound.provider;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthos.notification.domain.Provider;
import org.springframework.stereotype.Component;

@Component
public class MetaWhatsappSenderStub extends AbstractStubProviderSender {

  public MetaWhatsappSenderStub(ObjectMapper objectMapper) {
    super(objectMapper);
  }

  @Override
  protected Provider providerType() {
    return Provider.META_WHATSAPP;
  }
}
