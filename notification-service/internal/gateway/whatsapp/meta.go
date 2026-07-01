package whatsapp

import (
	"bytes"
	"encoding/json"
	"net/http"
	"strings"
	"time"

	"github.com/healthos/notification-service/internal/config"
	"go.uber.org/zap"
)

type Client struct {
	cfg    config.WhatsAppConfig
	client *http.Client
	logger *zap.Logger
}

func NewClient(cfg config.Config, logger *zap.Logger) *Client {
	return &Client{
		cfg:    cfg.WhatsApp,
		client: &http.Client{Timeout: 15 * time.Second},
		logger: logger,
	}
}

func (c *Client) SendText(to, message string) bool {
	if !c.cfg.Enabled || strings.TrimSpace(c.cfg.AccessToken) == "" || strings.TrimSpace(c.cfg.PhoneNumberID) == "" {
		c.logger.Info("[DEV WhatsApp]", zap.String("to", to), zap.String("message", message))
		return false
	}
	recipient := strings.TrimPrefix(to, "+")
	url := c.cfg.APIURL + "/" + c.cfg.PhoneNumberID + "/messages"
	body, _ := json.Marshal(map[string]any{
		"messaging_product": "whatsapp",
		"to":                recipient,
		"type":              "text",
		"text":              map[string]string{"body": message},
	})
	req, err := http.NewRequest(http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		c.logger.Error("whatsapp request failed", zap.Error(err))
		return false
	}
	req.Header.Set("Authorization", "Bearer "+c.cfg.AccessToken)
	req.Header.Set("Content-Type", "application/json")
	resp, err := c.client.Do(req)
	if err != nil {
		c.logger.Error("whatsapp send failed", zap.Error(err))
		return false
	}
	defer resp.Body.Close()
	if resp.StatusCode >= 300 {
		c.logger.Warn("whatsapp non-success", zap.Int("status", resp.StatusCode))
		return false
	}
	c.logger.Info("WhatsApp message sent", zap.String("to", to))
	return true
}

func RenderTemplate(template string, variables map[string]string) string {
	result := template
	for k, v := range variables {
		result = strings.ReplaceAll(result, "{{"+k+"}}", v)
	}
	return result
}
