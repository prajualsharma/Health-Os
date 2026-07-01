package service

import (
	"fmt"
	"strings"
	"time"

	"github.com/aymerick/raymond"
	"github.com/healthos/notification-service/internal/domain"
	"github.com/healthos/notification-service/internal/gateway/provider"
	"github.com/healthos/notification-service/internal/repository/mongo"
	"github.com/healthos/notification-service/internal/repository/redis"
	"go.uber.org/zap"
)

type TemplateRenderer struct{}

func NewTemplateRenderer() *TemplateRenderer { return &TemplateRenderer{} }

func (r *TemplateRenderer) Render(template string, variables map[string]interface{}) (string, error) {
	if template == "" {
		return "", nil
	}
	out, err := raymond.Render(template, variables)
	if err != nil {
		return "", fmt.Errorf("template rendering failed: %w", err)
	}
	return out, nil
}

type TemplateService struct {
	repo *mongo.TemplateRepo
}

func NewTemplateService(repo *mongo.TemplateRepo) *TemplateService {
	return &TemplateService{repo: repo}
}

func (s *TemplateService) FindActive(tenantID, topic string, channel domain.Channel) (*domain.NotificationTemplate, error) {
	return s.repo.FindActive(tenantID, topic, channel)
}

func (s *TemplateService) Create(t domain.NotificationTemplate) (domain.NotificationTemplate, error) {
	now := time.Now().UTC()
	t.CreatedAt = now
	t.UpdatedAt = now
	if err := s.repo.Save(&t); err != nil {
		return domain.NotificationTemplate{}, err
	}
	return t, nil
}

func (s *TemplateService) Update(id string, updates domain.NotificationTemplate) (domain.NotificationTemplate, error) {
	existing, err := s.repo.FindByID(id)
	if err != nil {
		return domain.NotificationTemplate{}, mapNotFound(err)
	}
	if updates.Topic != "" {
		existing.Topic = updates.Topic
	}
	if updates.TenantID != nil {
		existing.TenantID = updates.TenantID
	}
	if updates.Channel != "" {
		existing.Channel = updates.Channel
	}
	if updates.Subject != nil {
		existing.Subject = updates.Subject
	}
	if updates.Body != "" {
		existing.Body = updates.Body
	}
	existing.Active = updates.Active
	existing.UpdatedAt = time.Now().UTC()
	if err := s.repo.Save(existing); err != nil {
		return domain.NotificationTemplate{}, err
	}
	return *existing, nil
}

func (s *TemplateService) GetByID(id string) (domain.NotificationTemplate, error) {
	t, err := s.repo.FindByID(id)
	if err != nil {
		return domain.NotificationTemplate{}, mapNotFound(err)
	}
	return *t, nil
}

func (s *TemplateService) ListAll() ([]domain.NotificationTemplate, error) {
	return s.repo.ListAll()
}

func (s *TemplateService) Delete(id string) error {
	return s.repo.Delete(id)
}

type ProviderConfigService struct {
	repo *mongo.ProviderConfigRepo
}

func NewProviderConfigService(repo *mongo.ProviderConfigRepo) *ProviderConfigService {
	return &ProviderConfigService{repo: repo}
}

func (s *ProviderConfigService) FindActive(tenantID string, providerType domain.ProviderType) (*domain.ProviderConfig, error) {
	return s.repo.FindActive(tenantID, providerType)
}

func (s *ProviderConfigService) Create(pc domain.ProviderConfig) (domain.ProviderConfig, error) {
	now := time.Now().UTC()
	pc.CreatedAt = now
	pc.UpdatedAt = now
	if err := s.repo.Save(&pc); err != nil {
		return domain.ProviderConfig{}, err
	}
	return pc, nil
}

func (s *ProviderConfigService) Update(id string, updates domain.ProviderConfig) (domain.ProviderConfig, error) {
	existing, err := s.repo.FindByID(id)
	if err != nil {
		return domain.ProviderConfig{}, mapNotFound(err)
	}
	if updates.TenantID != nil {
		existing.TenantID = updates.TenantID
	}
	if updates.ProviderType != "" {
		existing.ProviderType = updates.ProviderType
	}
	if updates.Provider != "" {
		existing.Provider = updates.Provider
	}
	if updates.Config != nil {
		existing.Config = updates.Config
	}
	existing.Active = updates.Active
	existing.UpdatedAt = time.Now().UTC()
	if err := s.repo.Save(existing); err != nil {
		return domain.ProviderConfig{}, err
	}
	return *existing, nil
}

func (s *ProviderConfigService) GetByID(id string) (domain.ProviderConfig, error) {
	pc, err := s.repo.FindByID(id)
	if err != nil {
		return domain.ProviderConfig{}, mapNotFound(err)
	}
	return *pc, nil
}

func (s *ProviderConfigService) ListAll() ([]domain.ProviderConfig, error) {
	return s.repo.ListAll()
}

type TopicService struct {
	repo *mongo.TopicRepo
}

func NewTopicService(repo *mongo.TopicRepo) *TopicService {
	return &TopicService{repo: repo}
}

func (s *TopicService) Create(t domain.NotificationTopic) (domain.NotificationTopic, error) {
	if existing, _ := s.repo.FindByTopic(t.Topic); existing != nil {
		return domain.NotificationTopic{}, fmt.Errorf("topic already exists: %s", t.Topic)
	}
	t.CreatedAt = time.Now().UTC()
	if err := s.repo.Save(&t); err != nil {
		return domain.NotificationTopic{}, err
	}
	return t, nil
}

func (s *TopicService) ListAll() ([]domain.NotificationTopic, error) {
	return s.repo.ListAll()
}

type LogService struct {
	repo *mongo.LogRepo
}

func NewLogService(repo *mongo.LogRepo) *LogService {
	return &LogService{repo: repo}
}

func (s *LogService) Save(event domain.NotificationEvent, channel domain.Channel, recipient domain.Recipient, result domain.NotificationResult) error {
	log := domain.NotificationLog{
		EventID: event.EventID, TenantID: event.TenantID, Topic: event.Topic,
		Channel: channel, Recipient: formatRecipient(recipient, channel),
		RenderedMessage: result.RenderedMessage, Provider: result.Provider,
		Status: result.Status, RetryCount: result.RetryCount,
		RequestPayload: result.RequestPayload, ResponsePayload: result.ResponsePayload,
		ErrorMessage: result.ErrorMessage, CreatedAt: time.Now().UTC(),
	}
	return s.repo.Save(&log)
}

func (s *LogService) SaveStatus(event domain.NotificationEvent, channel domain.Channel, recipient domain.Recipient, status domain.NotificationStatus) error {
	return s.Save(event, channel, recipient, domain.NotificationResult{Status: status})
}

func (s *LogService) GetByID(id string) (domain.NotificationLog, error) {
	log, err := s.repo.FindByID(id)
	if err != nil {
		return domain.NotificationLog{}, mapNotFound(err)
	}
	return *log, nil
}

func (s *LogService) ListAll() ([]domain.NotificationLog, error) {
	return s.repo.ListAll()
}

type Metrics struct {
	logger *zap.Logger
}

func NewMetrics(logger *zap.Logger) *Metrics { return &Metrics{logger: logger} }

func (m *Metrics) RecordSent(channel domain.Channel, provider *string, status domain.NotificationStatus) {
	p := "unknown"
	if provider != nil {
		p = *provider
	}
	m.logger.Debug("notification metric",
		zap.String("channel", string(channel)),
		zap.String("provider", p),
		zap.String("status", string(status)),
	)
}

type NotificationProcessor struct {
	redis      *redis.Store
	templates  *TemplateService
	providers  *ProviderConfigService
	renderer   *TemplateRenderer
	factory    *provider.Factory
	logs       *LogService
	metrics    *Metrics
	logger     *zap.Logger
}

func NewNotificationProcessor(
	redis *redis.Store,
	templates *TemplateService,
	providers *ProviderConfigService,
	renderer *TemplateRenderer,
	factory *provider.Factory,
	logs *LogService,
	metrics *Metrics,
	logger *zap.Logger,
) *NotificationProcessor {
	return &NotificationProcessor{
		redis: redis, templates: templates, providers: providers, renderer: renderer,
		factory: factory, logs: logs, metrics: metrics, logger: logger,
	}
}

func (p *NotificationProcessor) Process(event domain.NotificationEvent) error {
	allowed, err := p.redis.Allow(event.TenantID)
	if err != nil {
		return err
	}
	if !allowed {
		p.logger.Warn("rate limit exceeded", zap.String("tenantId", event.TenantID))
		for _, ch := range event.Channels {
			_ = p.logs.SaveStatus(event, ch, event.Recipient, domain.StatusRateLimited)
			p.metrics.RecordSent(ch, nil, domain.StatusRateLimited)
		}
		return nil
	}
	for _, ch := range event.Channels {
		if err := p.processChannel(event, ch); err != nil {
			return err
		}
	}
	return nil
}

func (p *NotificationProcessor) processChannel(event domain.NotificationEvent, channel domain.Channel) error {
	if channel == domain.ChannelPush {
		p.logger.Info("PUSH channel not implemented", zap.String("eventId", event.EventID))
		return nil
	}
	acquired, err := p.redis.TryAcquire(event.TenantID, event.EventID, channel)
	if err != nil {
		return err
	}
	if !acquired {
		_ = p.logs.SaveStatus(event, channel, event.Recipient, domain.StatusDuplicate)
		p.metrics.RecordSent(channel, nil, domain.StatusDuplicate)
		return nil
	}
	template, err := p.templates.FindActive(event.TenantID, event.Topic, channel)
	if err != nil {
		return err
	}
	if template == nil {
		return fmt.Errorf("no active template for topic=%s channel=%s", event.Topic, channel)
	}
	var renderedSubject string
	if template.Subject != nil {
		renderedSubject, err = p.renderer.Render(*template.Subject, event.Variables)
		if err != nil {
			return err
		}
	}
	renderedBody, err := p.renderer.Render(template.Body, event.Variables)
	if err != nil {
		return err
	}
	providerType := mapChannelToProviderType(channel)
	pc, err := p.providers.FindActive(event.TenantID, providerType)
	if err != nil {
		return err
	}
	if pc == nil {
		return fmt.Errorf("no active provider config for type=%s", providerType)
	}
	ctx := domain.NotificationContext{
		EventID: event.EventID, TenantID: event.TenantID, Topic: event.Topic,
		Channel: channel, Recipient: event.Recipient, Variables: event.Variables,
		RenderedSubject: renderedSubject, RenderedBody: renderedBody, ProviderConfig: *pc,
	}
	result := p.dispatch(ctx)
	_ = p.logs.Save(event, channel, event.Recipient, result)
	prov := result.Provider
	p.metrics.RecordSent(channel, &prov, result.Status)
	p.logger.Info("notification processed",
		zap.String("eventId", event.EventID),
		zap.String("channel", string(channel)),
		zap.String("status", string(result.Status)),
	)
	return nil
}

func (p *NotificationProcessor) dispatch(ctx domain.NotificationContext) domain.NotificationResult {
	cfg := ctx.ProviderConfig
	if !cfg.Active {
		return domain.ResultFailed("", "No active provider configuration", "")
	}
	sender, err := p.factory.Resolve(cfg.Provider)
	if err != nil {
		return domain.ResultFailed("", err.Error(), "")
	}
	resp := sender.Send(cfg, ctx.Recipient, ctx.RenderedSubject, ctx.RenderedBody)
	rendered := ctx.RenderedBody
	if ctx.RenderedSubject != "" {
		rendered = ctx.RenderedSubject + " | " + ctx.RenderedBody
	}
	if resp.Success {
		return domain.ResultSent(string(cfg.Provider), rendered, resp.RequestPayload, resp.ResponsePayload)
	}
	return domain.ResultFailed(string(cfg.Provider), resp.ErrorMessage, resp.RequestPayload)
}

func mapChannelToProviderType(channel domain.Channel) domain.ProviderType {
	switch channel {
	case domain.ChannelEmail:
		return domain.ProviderTypeEmail
	case domain.ChannelSMS:
		return domain.ProviderTypeSMS
	case domain.ChannelWhatsApp:
		return domain.ProviderTypeWhatsApp
	default:
		return ""
	}
}

func formatRecipient(r domain.Recipient, channel domain.Channel) string {
	switch channel {
	case domain.ChannelEmail:
		return r.Email
	case domain.ChannelSMS, domain.ChannelWhatsApp:
		return r.Mobile
	default:
		return r.UserID
	}
}

func mapNotFound(err error) error {
	if err != nil && strings.Contains(err.Error(), "not found") {
		return err
	}
	return err
}
