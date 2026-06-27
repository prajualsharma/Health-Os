package com.healthos.notification.application.factory;

import static org.assertj.core.api.Assertions.assertThat;

import com.healthos.notification.adapters.outbound.provider.GupshupSenderStub;
import com.healthos.notification.adapters.outbound.provider.MetaWhatsappSenderStub;
import com.healthos.notification.adapters.outbound.provider.Msg91SmsSenderStub;
import com.healthos.notification.adapters.outbound.provider.SesEmailSenderStub;
import com.healthos.notification.adapters.outbound.provider.SmtpEmailSender;
import com.healthos.notification.adapters.outbound.provider.TwilioSmsSenderStub;
import com.healthos.notification.domain.Provider;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import org.junit.jupiter.api.Test;

class ProviderSenderFactoryTest {

  private final ObjectMapper objectMapper = new ObjectMapper();
  private final ProviderSenderFactory factory =
      new ProviderSenderFactory(
          List.of(
              new SmtpEmailSender(objectMapper),
              new SesEmailSenderStub(objectMapper),
              new TwilioSmsSenderStub(objectMapper),
              new Msg91SmsSenderStub(objectMapper),
              new MetaWhatsappSenderStub(objectMapper),
              new GupshupSenderStub(objectMapper)));

  @Test
  void resolvesSmtpSender() {
    assertThat(factory.resolve(Provider.SMTP).provider()).isEqualTo(Provider.SMTP);
  }
}
