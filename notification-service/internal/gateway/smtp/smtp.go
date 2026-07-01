package smtp

import (
	"crypto/tls"
	"encoding/json"
	"fmt"
	"net/smtp"
	"strings"

	"github.com/healthos/notification-service/internal/config"
	"github.com/healthos/notification-service/internal/domain"
	"go.uber.org/zap"
)

type EmailSender struct {
	logger *zap.Logger
}

func NewEmailSender(logger *zap.Logger) *EmailSender {
	return &EmailSender{logger: logger}
}

func (s *EmailSender) Provider() domain.Provider { return domain.ProviderSMTP }

func (s *EmailSender) Send(cfg domain.ProviderConfig, recipient domain.Recipient, subject, body string) domain.ProviderResponse {
	m := cfg.Config
	if m == nil || recipient.Email == "" {
		return domain.ProviderResponse{Success: false, ErrorMessage: "SMTP config or recipient email missing"}
	}
	host := m["host"]
	user := m["username"]
	pass := m["password"]
	port := m["port"]
	if port == "" {
		port = "587"
	}
	from := m["from"]
	if from == "" {
		from = user
	}
	addr := host + ":" + port
	msg := buildMessage(from, recipient.Email, subject, body)
	auth := smtp.PlainAuth("", user, pass, host)
	var err error
	if strings.EqualFold(m["starttls"], "true") || m["starttls"] == "" {
		err = sendStartTLS(addr, host, auth, from, []string{recipient.Email}, msg)
	} else {
		err = smtp.SendMail(addr, auth, from, []string{recipient.Email}, msg)
	}
	if err != nil {
		s.logger.Error("smtp send failed", zap.Error(err))
		return domain.ProviderResponse{Success: false, ErrorMessage: err.Error(), RequestPayload: `{"provider":"SMTP"}`}
	}
	req, _ := json.Marshal(map[string]string{"to": recipient.Email, "subject": subject, "provider": "SMTP"})
	return domain.ProviderResponse{
		Success: true, RequestPayload: string(req), ResponsePayload: `{"status":"sent"}`,
	}
}

func buildMessage(from, to, subject, body string) []byte {
	if subject == "" {
		subject = "Notification"
	}
	if body == "" {
		body = ""
	}
	headers := fmt.Sprintf("From: %s\r\nTo: %s\r\nSubject: %s\r\nMIME-Version: 1.0\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n", from, to, subject)
	return []byte(headers + body)
}

func sendStartTLS(addr, host string, auth smtp.Auth, from string, to []string, msg []byte) error {
	client, err := smtp.Dial(addr)
	if err != nil {
		return err
	}
	defer client.Close()
	if ok, _ := client.Extension("STARTTLS"); ok {
		if err := client.StartTLS(&tls.Config{ServerName: host}); err != nil {
			return err
		}
	}
	if auth != nil {
		if err := client.Auth(auth); err != nil {
			return err
		}
	}
	if err := client.Mail(from); err != nil {
		return err
	}
	for _, rcpt := range to {
		if err := client.Rcpt(rcpt); err != nil {
			return err
		}
	}
	w, err := client.Data()
	if err != nil {
		return err
	}
	if _, err := w.Write(msg); err != nil {
		return err
	}
	if err := w.Close(); err != nil {
		return err
	}
	return client.Quit()
}

type OTPMailer struct {
	cfg    config.SMTPConfig
	logger *zap.Logger
}

func NewOTPMailer(cfg config.Config, logger *zap.Logger) *OTPMailer {
	return &OTPMailer{cfg: cfg.SMTP, logger: logger}
}

func (m *OTPMailer) Send(to, phone string, variables map[string]string) bool {
	if !m.cfg.Enabled {
		m.logger.Info("[DEV OTP EMAIL]", zap.String("to", to), zap.String("phone", phone), zap.Any("variables", variables))
		return false
	}
	if strings.TrimSpace(m.cfg.Username) == "" || strings.TrimSpace(m.cfg.Password) == "" {
		m.logger.Warn("SMTP credentials missing; logging OTP instead of sending")
		m.logger.Info("[DEV OTP EMAIL]", zap.String("to", to), zap.String("phone", phone), zap.Any("variables", variables))
		return false
	}
	subject := renderTemplate(m.cfg.OTPSubjectTemplate, variables)
	body := renderTemplate(m.cfg.OTPBodyTemplate, variables)
	from := m.cfg.FromAddress()
	addr := fmt.Sprintf("%s:%d", m.cfg.Host, m.cfg.Port)
	msg := buildMessage(from, to, subject, body)
	auth := smtp.PlainAuth("", m.cfg.Username, m.cfg.Password, m.cfg.Host)
	var err error
	if m.cfg.StartTLS {
		err = sendStartTLS(addr, m.cfg.Host, auth, from, []string{to}, msg)
	} else {
		err = smtp.SendMail(addr, auth, from, []string{to}, msg)
	}
	if err != nil {
		m.logger.Error("failed to send OTP email", zap.String("to", to), zap.Error(err))
		return false
	}
	m.logger.Info("OTP email sent", zap.String("to", to), zap.String("phone", phone))
	return true
}

func renderTemplate(template string, variables map[string]string) string {
	result := template
	for k, v := range variables {
		result = strings.ReplaceAll(result, "{{"+k+"}}", v)
	}
	return result
}
