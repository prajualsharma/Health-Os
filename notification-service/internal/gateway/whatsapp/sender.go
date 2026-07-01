package whatsapp

import (
	"encoding/json"

	"github.com/healthos/notification-service/internal/config"
	"github.com/healthos/notification-service/internal/domain"
	"go.uber.org/zap"
)

// Sender delivers WhatsApp messages through the Meta Cloud API for Kafka events.
type Sender struct {
	client *Client
	logger *zap.Logger
}

func NewSender(cfg config.Config, logger *zap.Logger) *Sender {
	return &Sender{client: NewClient(cfg, logger), logger: logger}
}

func (s *Sender) Provider() domain.Provider { return domain.ProviderMetaWhatsApp }

func (s *Sender) Send(cfg domain.ProviderConfig, recipient domain.Recipient, subject, body string) domain.ProviderResponse {
	_ = subject
	if recipient.Mobile == "" {
		return domain.ProviderResponse{Success: false, ErrorMessage: "recipient mobile missing"}
	}
	message := body
	if message == "" {
		message = "Notification from NutriKit"
	}
	ok := s.client.SendText(recipient.Mobile, message)
	req, _ := json.Marshal(map[string]string{"to": recipient.Mobile, "provider": string(domain.ProviderMetaWhatsApp)})
	if ok {
		return domain.ProviderResponse{
			Success:         true,
			RequestPayload:  string(req),
			ResponsePayload: `{"status":"sent"}`,
		}
	}
	return domain.ProviderResponse{
		Success:         false,
		ErrorMessage:    "whatsapp delivery failed",
		RequestPayload:  string(req),
		ResponsePayload: `{"status":"failed"}`,
	}
}
