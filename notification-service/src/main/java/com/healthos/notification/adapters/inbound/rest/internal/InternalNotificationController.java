package com.healthos.notification.adapters.inbound.rest.internal;

import com.healthos.notification.adapters.outbound.provider.MetaWhatsappClient;
import com.healthos.notification.config.HealthOsProperties;
import jakarta.validation.constraints.NotBlank;
import java.util.Map;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Synchronous, service-to-service notification endpoints. Unlike the Kafka pipeline these send
 * immediately, which auth flows (OTP) require. Reachable only inside the cluster (gateway does not
 * route {@code /internal/**} to the public internet beyond trusted callers).
 */
@RestController
@RequestMapping("/internal/notifications")
@RequiredArgsConstructor
public class InternalNotificationController {
  private final MetaWhatsappClient whatsappClient;
  private final HealthOsProperties props;

  @PostMapping("/whatsapp")
  public SendResult sendWhatsapp(@RequestBody WhatsappSendRequest req) {
    var message = render(props.getWhatsapp().getOtpMessageTemplate(), req.getVariables());
    boolean delivered = whatsappClient.sendText(req.getTo(), message);
    return new SendResult(delivered);
  }

  private static String render(String template, Map<String, String> variables) {
    if (variables == null) {
      return template;
    }
    var result = template;
    for (var entry : variables.entrySet()) {
      result = result.replace("{{" + entry.getKey() + "}}", entry.getValue());
    }
    return result;
  }

  @Data
  public static class WhatsappSendRequest {
    private String tenantId;
    @NotBlank private String to;
    private String topic;
    private Map<String, String> variables;
  }

  public record SendResult(boolean delivered) {}
}
