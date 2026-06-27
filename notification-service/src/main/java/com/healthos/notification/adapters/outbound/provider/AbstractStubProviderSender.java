package com.healthos.notification.adapters.outbound.provider;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthos.notification.domain.Provider;
import com.healthos.notification.domain.ProviderConfig;
import com.healthos.notification.domain.ProviderResponse;
import com.healthos.notification.domain.Recipient;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RequiredArgsConstructor
public abstract class AbstractStubProviderSender implements ProviderSender {

  private final ObjectMapper objectMapper;

  protected abstract Provider providerType();

  @Override
  public Provider provider() {
    return providerType();
  }

  @Override
  public ProviderResponse send(
      ProviderConfig config, Recipient recipient, String subject, String body) {
    log.info(
        "STUB provider {} send (configure real integration to enable)",
        providerType());
    try {
      String req =
          objectMapper.writeValueAsString(
              Map.of(
                  "provider", providerType().name(),
                  "recipient", recipient,
                  "subject", subject,
                  "body", body,
                  "configKeys", config.getConfig() != null ? config.getConfig().keySet() : Map.of()));
      return ProviderResponse.builder()
          .success(true)
          .requestPayload(req)
          .responsePayload(
              "{\"status\":\"simulated\",\"message\":\"Provider stub - not sent to external API\"}")
          .build();
    } catch (Exception e) {
      return ProviderResponse.builder().success(false).errorMessage(e.getMessage()).build();
    }
  }
}
