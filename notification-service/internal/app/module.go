package app

import (
	"github.com/healthos/notification-service/internal/bootstrap"
	"github.com/healthos/notification-service/internal/config"
	"github.com/healthos/notification-service/internal/consumer"
	"github.com/healthos/notification-service/internal/domain"
	"github.com/healthos/notification-service/internal/gateway/provider"
	"github.com/healthos/notification-service/internal/gateway/smtp"
	"github.com/healthos/notification-service/internal/gateway/whatsapp"
	"github.com/healthos/notification-service/internal/handler"
	mongorepo "github.com/healthos/notification-service/internal/repository/mongo"
	redisrepo "github.com/healthos/notification-service/internal/repository/redis"
	"github.com/healthos/notification-service/internal/service"
	"github.com/healthos/pkg/healthos/fxutil"
	"github.com/healthos/pkg/healthos/observability"
	"go.uber.org/fx"
	"go.uber.org/zap"
)

func provideHTTPPort(cfg config.Config) string {
	return cfg.Port
}

func provideSenders(logger *zap.Logger, smtpSender *smtp.EmailSender, whatsappSender *whatsapp.Sender) []provider.Sender {
	return []provider.Sender{
		smtpSender,
		whatsappSender,
		provider.NewStub(domain.ProviderAWSSES, logger),
		provider.NewStub(domain.ProviderTwilio, logger),
		provider.NewStub(domain.ProviderMSG91, logger),
		provider.NewStub(domain.ProviderGupshup, logger),
	}
}

var Module = fx.Options(
	fx.Provide(config.Load),
	fx.Provide(observability.NewLogger),
	fx.Invoke(observability.RegisterLogger),
	fx.Provide(
		fx.Annotate(provideHTTPPort, fx.ResultTags(`name:"httpPort"`)),
	),
	mongorepo.Module,
	redisrepo.Module,
	fx.Provide(smtp.NewEmailSender, smtp.NewOTPMailer, whatsapp.NewClient, whatsapp.NewSender),
	fx.Provide(provideSenders, provider.NewFactory),
	fx.Provide(
		service.NewTemplateRenderer,
		service.NewTemplateService,
		service.NewProviderConfigService,
		service.NewTopicService,
		service.NewLogService,
		service.NewMetrics,
		service.NewNotificationProcessor,
	),
	fx.Provide(handler.NewRouter),
	consumer.Module,
	fx.Invoke(bootstrap.SeedDefaults),
	fx.Invoke(fxutil.RunHTTPServer),
)
