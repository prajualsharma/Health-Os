package com.healthos.notification.adapters.outbound.provider;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthos.notification.domain.Provider;
import com.healthos.notification.domain.ProviderConfig;
import com.healthos.notification.domain.ProviderResponse;
import com.healthos.notification.domain.Recipient;
import java.util.Map;
import java.util.Properties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class SmtpEmailSender implements ProviderSender {

  private final ObjectMapper objectMapper;

  @Override
  public Provider provider() {
    return Provider.SMTP;
  }

  @Override
  public ProviderResponse send(
      ProviderConfig config, Recipient recipient, String subject, String body) {
    Map<String, String> cfg = config.getConfig();
    if (cfg == null || recipient.getEmail() == null) {
      return ProviderResponse.builder()
          .success(false)
          .errorMessage("SMTP config or recipient email missing")
          .build();
    }
    try {
      JavaMailSenderImpl mailSender = buildMailSender(cfg);
      var message = mailSender.createMimeMessage();
      var helper = new MimeMessageHelper(message, true, "UTF-8");
      helper.setTo(recipient.getEmail());
      helper.setSubject(subject != null ? subject : "Notification");
      helper.setText(body != null ? body : "", false);
      String from = cfg.getOrDefault("from", cfg.get("username"));
      if (from != null) {
        helper.setFrom(from);
      }
      mailSender.send(message);
      String req =
          objectMapper.writeValueAsString(
              Map.of("to", recipient.getEmail(), "subject", subject, "provider", "SMTP"));
      return ProviderResponse.builder()
          .success(true)
          .requestPayload(req)
          .responsePayload("{\"status\":\"sent\"}")
          .build();
    } catch (Exception e) {
      log.error("SMTP send failed", e);
      return ProviderResponse.builder()
          .success(false)
          .errorMessage(e.getMessage())
          .requestPayload("{\"provider\":\"SMTP\"}")
          .build();
    }
  }

  private static JavaMailSenderImpl buildMailSender(Map<String, String> cfg) {
    JavaMailSenderImpl sender = new JavaMailSenderImpl();
    sender.setHost(cfg.get("host"));
    if (cfg.get("port") != null) {
      sender.setPort(Integer.parseInt(cfg.get("port")));
    }
    sender.setUsername(cfg.get("username"));
    sender.setPassword(cfg.get("password"));
    Properties props = sender.getJavaMailProperties();
    props.put("mail.transport.protocol", "smtp");
    props.put("mail.smtp.auth", cfg.getOrDefault("auth", "true"));
    props.put("mail.smtp.starttls.enable", cfg.getOrDefault("starttls", "true"));
    return sender;
  }
}
