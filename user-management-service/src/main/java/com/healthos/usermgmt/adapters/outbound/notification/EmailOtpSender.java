package com.healthos.usermgmt.adapters.outbound.notification;

import com.healthos.usermgmt.config.HealthOsProperties;
import java.util.Properties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class EmailOtpSender {
  private final HealthOsProperties props;

  public boolean send(String to, String phone, String code) {
    var smtp = props.getSmtp();
    if (!smtp.isEnabled()) {
      return false;
    }
    if (smtp.getUsername() == null
        || smtp.getUsername().isBlank()
        || smtp.getPassword() == null
        || smtp.getPassword().isBlank()) {
      log.warn("SMTP credentials missing; cannot send OTP email");
      return false;
    }

    try {
      var mailSender = buildMailSender(smtp);
      var message = mailSender.createMimeMessage();
      var helper = new MimeMessageHelper(message, false, "UTF-8");
      helper.setTo(to);
      helper.setSubject(smtp.getOtpSubject());
      helper.setText(
          smtp.getOtpBody().replace("{{phone}}", phone).replace("{{otp}}", code), false);
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
}
