package bootstrap

import (
	"context"
	"strconv"
	"time"

	"github.com/healthos/notification-service/internal/config"
	"github.com/healthos/notification-service/internal/domain"
	mongorepo "github.com/healthos/notification-service/internal/repository/mongo"
	"go.uber.org/fx"
	"go.uber.org/zap"
)

const healthosTenant = "healthos"

func SeedDefaults(
	lc fx.Lifecycle,
	cfg config.Config,
	topics *mongorepo.TopicRepo,
	templates *mongorepo.TemplateRepo,
	providers *mongorepo.ProviderConfigRepo,
	logger *zap.Logger,
) {
	lc.Append(fx.Hook{
		OnStart: func(ctx context.Context) error {
			seedTopic(topics, "nutrikit.onboarding.abandoned", "NutriKit abandoned onboarding reminder")
			seedTemplate(templates, healthosTenant, "nutrikit.onboarding.abandoned", domain.ChannelWhatsApp,
				nil, `Hi {{firstName}}, you left off at "{{stepLabel}}". Finish your NutriKit setup: {{resumeUrl}}`)
			seedTemplate(templates, healthosTenant, "nutrikit.onboarding.abandoned", domain.ChannelEmail,
				strPtr("Finish your NutriKit setup"),
				`Hi {{firstName}},\n\nYou paused at "{{stepLabel}}". Pick up where you left off:\n{{resumeUrl}}`)
			seedTemplate(templates, healthosTenant, "nutrikit.onboarding.abandoned", domain.ChannelSMS,
				nil, `NutriKit: finish "{{stepLabel}}" — {{resumeUrl}}`)
			seedSMTPProvider(cfg, providers)
			seedWhatsAppProvider(providers)
			seedSMSProvider(providers)
			logger.Info("notification defaults seeded", zap.String("tenant", healthosTenant))
			return nil
		},
	})
}

func seedTopic(repo *mongorepo.TopicRepo, topic, description string) {
	existing, _ := repo.FindByTopic(topic)
	if existing != nil {
		return
	}
	now := time.Now().UTC()
	_ = repo.Save(&domain.NotificationTopic{
		Topic: topic, Description: description, CreatedAt: now,
	})
}

func seedTemplate(repo *mongorepo.TemplateRepo, tenantID, topic string, channel domain.Channel, subject *string, body string) {
	existing, _ := repo.FindActive(tenantID, topic, channel)
	if existing != nil {
		return
	}
	now := time.Now().UTC()
	tid := tenantID
	_ = repo.Save(&domain.NotificationTemplate{
		TenantID: &tid, Topic: topic, Channel: channel, Subject: subject, Body: body,
		Active: true, CreatedAt: now, UpdatedAt: now,
	})
}

func seedSMTPProvider(cfg config.Config, repo *mongorepo.ProviderConfigRepo) {
	existing, _ := repo.FindActive(healthosTenant, domain.ProviderTypeEmail)
	if existing != nil {
		return
	}
	now := time.Now().UTC()
	tid := healthosTenant
	_ = repo.Save(&domain.ProviderConfig{
		TenantID: &tid, ProviderType: domain.ProviderTypeEmail, Provider: domain.ProviderSMTP,
		Active: cfg.SMTP.Enabled,
		Config: map[string]string{
			"host":      cfg.SMTP.Host,
			"port":      strconv.Itoa(cfg.SMTP.Port),
			"username":  cfg.SMTP.Username,
			"password":  cfg.SMTP.Password,
			"from":      cfg.SMTP.FromAddress(),
			"starttls":  boolString(cfg.SMTP.StartTLS),
		},
		CreatedAt: now, UpdatedAt: now,
	})
}

func seedWhatsAppProvider(repo *mongorepo.ProviderConfigRepo) {
	existing, _ := repo.FindActive(healthosTenant, domain.ProviderTypeWhatsApp)
	if existing != nil {
		return
	}
	now := time.Now().UTC()
	tid := healthosTenant
	_ = repo.Save(&domain.ProviderConfig{
		TenantID: &tid, ProviderType: domain.ProviderTypeWhatsApp, Provider: domain.ProviderMetaWhatsApp,
		Active: true, Config: map[string]string{}, CreatedAt: now, UpdatedAt: now,
	})
}

func seedSMSProvider(repo *mongorepo.ProviderConfigRepo) {
	existing, _ := repo.FindActive(healthosTenant, domain.ProviderTypeSMS)
	if existing != nil {
		return
	}
	now := time.Now().UTC()
	tid := healthosTenant
	_ = repo.Save(&domain.ProviderConfig{
		TenantID: &tid, ProviderType: domain.ProviderTypeSMS, Provider: domain.ProviderTwilio,
		Active: true, Config: map[string]string{}, CreatedAt: now, UpdatedAt: now,
	})
}

func strPtr(s string) *string { return &s }

func boolString(v bool) string {
	if v {
		return "true"
	}
	return "false"
}
