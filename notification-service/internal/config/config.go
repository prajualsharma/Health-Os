package config

import (
	"fmt"
	"net/url"

	"github.com/healthos/pkg/healthos/config"
)

type Config struct {
	Port                 string
	MongoURI             string
	RedisAddr            string
	KafkaBrokers         string
	JWTIssuer            string
	JWTSecret            string
	MainTopic            string
	RetryTopic           string
	DLTTopic             string
	IdempotencyTTL       int
	RateLimitMax         int
	RateLimitWindow      int
	WhatsApp             WhatsAppConfig
	SMTP                 SMTPConfig
}

type WhatsAppConfig struct {
	Enabled            bool
	APIURL             string
	PhoneNumberID      string
	AccessToken        string
	OTPMessageTemplate string
}

type SMTPConfig struct {
	Enabled           bool
	Host              string
	Port              int
	Username          string
	Password          string
	From              string
	StartTLS          bool
	OTPSubjectTemplate string
	OTPBodyTemplate    string
}

func Load() Config {
	smtpUser := config.Getenv("SMTP_USERNAME", "")
	smtpFrom := config.Getenv("SMTP_FROM", smtpUser)
	return Config{
		Port:            config.Getenv("SERVER_PORT", "8082"),
		MongoURI:        config.Getenv("SPRING_DATA_MONGODB_URI", config.Getenv("MONGODB_URI", "mongodb://localhost:27017/healthos_notifications")),
		RedisAddr:       redisAddr(),
		KafkaBrokers:    config.Getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092"),
		JWTIssuer:       config.Getenv("JWT_ISSUER", "healthos"),
		JWTSecret:       config.Getenv("JWT_SECRET", "dev-only-change-me-dev-only-change-me"),
		MainTopic:       config.Getenv("NOTIFICATION_TOPIC", "notification-topic"),
		RetryTopic:      config.Getenv("NOTIFICATION_RETRY_TOPIC", "notification-retry"),
		DLTTopic:        config.Getenv("NOTIFICATION_DLT_TOPIC", "notification-dlt"),
		IdempotencyTTL:  config.GetenvInt("IDEMPOTENCY_TTL_SECONDS", 86400),
		RateLimitMax:    config.GetenvInt("RATE_LIMIT_MAX", 100),
		RateLimitWindow: config.GetenvInt("RATE_LIMIT_WINDOW_SECONDS", 60),
		WhatsApp: WhatsAppConfig{
			Enabled:            config.GetenvBool("META_WHATSAPP_ENABLED", false),
			APIURL:             config.Getenv("META_WHATSAPP_API_URL", "https://graph.facebook.com/v21.0"),
			PhoneNumberID:      config.Getenv("META_WHATSAPP_PHONE_NUMBER_ID", ""),
			AccessToken:        config.Getenv("META_WHATSAPP_TOKEN", ""),
			OTPMessageTemplate: config.Getenv("META_WHATSAPP_OTP_TEMPLATE", "Your NutriKit verification code is {{otp}}. It expires in 10 minutes."),
		},
		SMTP: SMTPConfig{
			Enabled:            config.GetenvBool("SMTP_ENABLED", true),
			Host:               config.Getenv("SMTP_HOST", "smtp.gmail.com"),
			Port:               config.GetenvInt("SMTP_PORT", 587),
			Username:           smtpUser,
			Password:           config.Getenv("SMTP_PASSWORD", ""),
			From:               smtpFrom,
			StartTLS:           config.GetenvBool("SMTP_STARTTLS", true),
			OTPSubjectTemplate: config.Getenv("SMTP_OTP_SUBJECT", "Your NutriKit verification code"),
			OTPBodyTemplate:    config.Getenv("SMTP_OTP_BODY", "Your NutriKit verification code for {{phone}} is {{otp}}. It expires in 10 minutes."),
		},
	}
}

func redisAddr() string {
	host := config.Getenv("REDIS_HOST", "localhost")
	port := config.Getenv("REDIS_PORT", "6379")
	return fmt.Sprintf("%s:%s", host, port)
}

func (c SMTPConfig) FromAddress() string {
	if c.From != "" {
		return c.From
	}
	return c.Username
}

func MongoDatabase(uri string) string {
	u, err := url.Parse(uri)
	if err != nil || u.Path == "" || u.Path == "/" {
		return "healthos_notifications"
	}
	return u.Path[1:]
}
