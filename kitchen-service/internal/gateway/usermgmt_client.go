package gateway

import (
	"bytes"
	"encoding/json"
	"net/http"
	"time"

	"github.com/healthos/kitchen-service/internal/config"
	"go.uber.org/zap"
)

type UserManagementClient struct {
	baseURL string
	client  *http.Client
	logger  *zap.Logger
}

func NewUserManagementClient(cfg config.Config, logger *zap.Logger) *UserManagementClient {
	return &UserManagementClient{
		baseURL: cfg.UserMgmtBaseURL,
		client:  &http.Client{Timeout: 10 * time.Second},
		logger:  logger,
	}
}

func (c *UserManagementClient) GrantKitchenStaff(userID, kitchenID string) {
	c.grant(userID, "LOCATION", kitchenID, "KITCHEN_STAFF")
}

func (c *UserManagementClient) grant(userID, scopeType, scopeID, roleName string) {
	body, _ := json.Marshal(map[string]string{
		"userId":     userID,
		"portalType": "KITCHEN",
		"scopeType":  scopeType,
		"scopeId":    scopeID,
		"roleName":   roleName,
	})
	req, err := http.NewRequest(http.MethodPost, c.baseURL+"/internal/staff/scoped-memberships", bytes.NewReader(body))
	if err != nil {
		c.logger.Warn("grant membership request failed", zap.Error(err))
		return
	}
	req.Header.Set("Content-Type", "application/json")
	resp, err := c.client.Do(req)
	if err != nil {
		c.logger.Warn("failed to grant membership", zap.String("role", roleName), zap.Error(err))
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode >= 300 {
		c.logger.Warn("grant membership non-success", zap.String("role", roleName), zap.Int("status", resp.StatusCode))
		return
	}
	c.logger.Info("granted membership", zap.String("role", roleName), zap.String("userId", userID),
		zap.String("scopeType", scopeType), zap.String("scopeId", scopeID))
}
