package domain

import "time"

type Channel string

const (
	ChannelEmail    Channel = "EMAIL"
	ChannelSMS      Channel = "SMS"
	ChannelWhatsApp Channel = "WHATSAPP"
	ChannelPush     Channel = "PUSH"
)

type ProviderType string

const (
	ProviderTypeEmail    ProviderType = "EMAIL"
	ProviderTypeSMS      ProviderType = "SMS"
	ProviderTypeWhatsApp ProviderType = "WHATSAPP"
)

type Provider string

const (
	ProviderSMTP          Provider = "SMTP"
	ProviderAWSSES        Provider = "AWS_SES"
	ProviderTwilio        Provider = "TWILIO"
	ProviderMSG91         Provider = "MSG91"
	ProviderMetaWhatsApp  Provider = "META_WHATSAPP"
	ProviderGupshup       Provider = "GUPSHUP"
)

type NotificationStatus string

const (
	StatusSent        NotificationStatus = "SENT"
	StatusFailed      NotificationStatus = "FAILED"
	StatusDuplicate   NotificationStatus = "DUPLICATE"
	StatusRateLimited NotificationStatus = "RATE_LIMITED"
)

type Recipient struct {
	UserID string `json:"userId,omitempty" bson:"userId,omitempty"`
	Email  string `json:"email,omitempty" bson:"email,omitempty"`
	Mobile string `json:"mobile,omitempty" bson:"mobile,omitempty"`
}

type NotificationEvent struct {
	EventID   string                 `json:"eventId" bson:"eventId"`
	TenantID  string                 `json:"tenantId" bson:"tenantId"`
	Topic     string                 `json:"topic" bson:"topic"`
	Channels  []Channel              `json:"channels" bson:"channels"`
	Recipient Recipient              `json:"recipient" bson:"recipient"`
	Variables map[string]interface{} `json:"variables" bson:"variables"`
}

type NotificationTemplate struct {
	ID        string    `json:"id" bson:"_id,omitempty"`
	TenantID  *string   `json:"tenantId,omitempty" bson:"tenantId,omitempty"`
	Topic     string    `json:"topic" bson:"topic"`
	Channel   Channel   `json:"channel" bson:"channel"`
	Subject   *string   `json:"subject,omitempty" bson:"subject,omitempty"`
	Body      string    `json:"body" bson:"body"`
	Active    bool      `json:"active" bson:"active"`
	CreatedAt time.Time `json:"createdAt" bson:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt" bson:"updatedAt"`
}

type ProviderConfig struct {
	ID           string            `json:"id" bson:"_id,omitempty"`
	TenantID     *string           `json:"tenantId,omitempty" bson:"tenantId,omitempty"`
	ProviderType ProviderType      `json:"providerType" bson:"providerType"`
	Provider     Provider          `json:"provider" bson:"provider"`
	Active       bool              `json:"active" bson:"active"`
	Config       map[string]string `json:"config" bson:"config"`
	CreatedAt    time.Time         `json:"createdAt" bson:"createdAt"`
	UpdatedAt    time.Time         `json:"updatedAt" bson:"updatedAt"`
}

type NotificationTopic struct {
	ID          string    `json:"id" bson:"_id,omitempty"`
	Topic       string    `json:"topic" bson:"topic"`
	Description string    `json:"description,omitempty" bson:"description,omitempty"`
	CreatedAt   time.Time `json:"createdAt" bson:"createdAt"`
}

type NotificationLog struct {
	ID              string             `json:"id" bson:"_id,omitempty"`
	EventID         string             `json:"eventId" bson:"eventId"`
	TenantID        string             `json:"tenantId" bson:"tenantId"`
	Topic           string             `json:"topic" bson:"topic"`
	Channel         Channel            `json:"channel" bson:"channel"`
	Recipient       string             `json:"recipient" bson:"recipient"`
	RenderedMessage string             `json:"renderedMessage,omitempty" bson:"renderedMessage,omitempty"`
	Provider        string             `json:"provider,omitempty" bson:"provider,omitempty"`
	Status          NotificationStatus `json:"status" bson:"status"`
	RetryCount      int                `json:"retryCount" bson:"retryCount"`
	RequestPayload  string             `json:"requestPayload,omitempty" bson:"requestPayload,omitempty"`
	ResponsePayload string             `json:"responsePayload,omitempty" bson:"responsePayload,omitempty"`
	ErrorMessage    string             `json:"errorMessage,omitempty" bson:"errorMessage,omitempty"`
	CreatedAt       time.Time          `json:"createdAt" bson:"createdAt"`
}

type NotificationContext struct {
	EventID         string
	TenantID        string
	Topic           string
	Channel         Channel
	Recipient       Recipient
	Variables       map[string]interface{}
	RenderedSubject string
	RenderedBody    string
	ProviderConfig  ProviderConfig
}

type ProviderResponse struct {
	Success         bool
	RequestPayload  string
	ResponsePayload string
	ErrorMessage    string
}

type NotificationResult struct {
	Status          NotificationStatus
	Provider        string
	RenderedMessage string
	RequestPayload  string
	ResponsePayload string
	ErrorMessage    string
	RetryCount      int
}

func ResultSent(provider, rendered, req, res string) NotificationResult {
	return NotificationResult{
		Status: StatusSent, Provider: provider,
		RenderedMessage: rendered, RequestPayload: req, ResponsePayload: res,
	}
}

func ResultFailed(provider, errMsg, req string) NotificationResult {
	return NotificationResult{
		Status: StatusFailed, Provider: provider,
		ErrorMessage: errMsg, RequestPayload: req,
	}
}
