package com.healthos.notification.application.factory;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.healthos.notification.application.strategy.EmailNotificationStrategy;
import com.healthos.notification.application.strategy.SmsNotificationStrategy;
import com.healthos.notification.application.strategy.WhatsappNotificationStrategy;
import com.healthos.notification.domain.Channel;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class NotificationStrategyFactoryTest {

  @Mock private ProviderSenderFactory providerSenderFactory;

  private NotificationStrategyFactory factory;

  @BeforeEach
  void setUp() {
    factory =
        new NotificationStrategyFactory(
            List.of(
                new EmailNotificationStrategy(providerSenderFactory),
                new SmsNotificationStrategy(providerSenderFactory),
                new WhatsappNotificationStrategy(providerSenderFactory)));
  }

  @Test
  void resolvesEmailStrategy() {
    assertThat(factory.resolve(Channel.EMAIL).channel()).isEqualTo(Channel.EMAIL);
  }

  @Test
  void throwsForUnknownChannel() {
    assertThatThrownBy(() -> factory.resolve(Channel.PUSH))
        .isInstanceOf(IllegalArgumentException.class);
  }
}
