package provider

import (
	"encoding/json"
	"fmt"

	"github.com/healthos/notification-service/internal/domain"
	"go.uber.org/zap"
)

type Sender interface {
	Provider() domain.Provider
	Send(cfg domain.ProviderConfig, recipient domain.Recipient, subject, body string) domain.ProviderResponse
}

type Factory struct {
	senders map[domain.Provider]Sender
}

func NewFactory(senders []Sender) *Factory {
	m := make(map[domain.Provider]Sender, len(senders))
	for _, s := range senders {
		m[s.Provider()] = s
	}
	return &Factory{senders: m}
}

func (f *Factory) Resolve(p domain.Provider) (Sender, error) {
	s, ok := f.senders[p]
	if !ok {
		return nil, fmt.Errorf("no provider sender registered for: %s", p)
	}
	return s, nil
}

type stubSender struct {
	provider domain.Provider
	logger   *zap.Logger
}

func NewStub(provider domain.Provider, logger *zap.Logger) Sender {
	return &stubSender{provider: provider, logger: logger}
}

func (s *stubSender) Provider() domain.Provider { return s.provider }

func (s *stubSender) Send(cfg domain.ProviderConfig, recipient domain.Recipient, subject, body string) domain.ProviderResponse {
	s.logger.Info("stub provider send", zap.String("provider", string(s.provider)))
	req, _ := json.Marshal(map[string]any{
		"provider": s.provider, "recipient": recipient, "subject": subject, "body": body,
	})
	return domain.ProviderResponse{
		Success:         true,
		RequestPayload:  string(req),
		ResponsePayload: `{"status":"simulated","message":"Provider stub - not sent to external API"}`,
	}
}
