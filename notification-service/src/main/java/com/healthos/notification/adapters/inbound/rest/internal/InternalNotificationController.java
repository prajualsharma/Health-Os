package com.healthos.notification.adapters.inbound.rest.internal;

import com.healthos.notification.adapters.outbound.provider.MetaWhatsappClient;
import com.healthos.notification.adapters.outbound.provider.SmtpOtpMailer;
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
  private final SmtpOtpMailer smtpOtpMailer;
  private final HealthOsProperties props;

  @PostMapping("/whatsapp")
  public SendResult sendWhatsapp(@RequestBody WhatsappSendRequest req) {
    var message = render(props.getWhatsapp().getOtpMessageTemplate(), req.getVariables());
    boolean delivered = whatsappClient.sendText(req.getTo(), message);
    return new SendResult(delivered);
  }

  @PostMapping("/email")
  public SendResult sendEmail(@RequestBody EmailSendRequest req) {
    var variables = req.getVariables() != null ? req.getVariables() : Map.<String, String>of();
    if (req.getPhone() != null && !req.getPhone().isBlank()) {
      variables = new java.util.HashMap<>(variables);
      variables.putIfAbsent("phone", req.getPhone());
    }
    boolean delivered = smtpOtpMailer.send(req.getTo(), req.getPhone(), variables);
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

  @Data
  public static class EmailSendRequest {
    private String tenantId;
    @NotBlank private String to;
    private String phone;
    private String topic;
    private Map<String, String> variables;
  }

  public record SendResult(boolean delivered) {}
}
