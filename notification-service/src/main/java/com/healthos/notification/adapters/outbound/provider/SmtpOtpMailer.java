package com.healthos.notification.adapters.outbound.provider;

import com.healthos.notification.config.HealthOsProperties;
import java.util.Map;
import java.util.Properties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Component;

/** Sends auth OTP codes over SMTP (e.g. Gmail). */
@Slf4j
@Component
@RequiredArgsConstructor
public class SmtpOtpMailer {
  private final HealthOsProperties props;

  public boolean send(String to, String phone, Map<String, String> variables) {
    var smtp = props.getSmtp();
    if (!smtp.isEnabled()) {
      log.info("[DEV OTP EMAIL] to={} phone={} variables={}", to, phone, variables);
      return false;
    }
    if (smtp.getUsername() == null
        || smtp.getUsername().isBlank()
        || smtp.getPassword() == null
        || smtp.getPassword().isBlank()) {
      log.warn("SMTP credentials missing; logging OTP instead of sending");
      log.info("[DEV OTP EMAIL] to={} phone={} variables={}", to, phone, variables);
      return false;
    }

    try {
      var mailSender = buildMailSender(smtp);
      var message = mailSender.createMimeMessage();
      var helper = new MimeMessageHelper(message, false, "UTF-8");
      helper.setTo(to);
      helper.setSubject(render(smtp.getOtpSubjectTemplate(), variables));
      helper.setText(render(smtp.getOtpBodyTemplate(), variables), false);
      var from = smtp.getFrom() != null ? smtp.getFrom() : smtp.getUsername();
      helper.setFrom(from);
      mailSender.send(message);
      log.info("OTP email sent to {} for phone {}", to, phone);
      return true;
    } catch (Exception e) {
      log.error("Failed to send OTP email to {}", to, e);
      return false;
    }
  }

  private static JavaMailSenderImpl buildMailSender(HealthOsProperties.Smtp smtp) {
    var sender = new JavaMailSenderImpl();
    sender.setHost(smtp.getHost());
    sender.setPort(smtp.getPort());
    sender.setUsername(smtp.getUsername());
    sender.setPassword(smtp.getPassword());
    Properties mailProps = sender.getJavaMailProperties();
    mailProps.put("mail.transport.protocol", "smtp");
    mailProps.put("mail.smtp.auth", "true");
    mailProps.put("mail.smtp.starttls.enable", String.valueOf(smtp.isStarttls()));
    return sender;
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
}
