package handler

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/healthos/notification-service/internal/config"
	"github.com/healthos/notification-service/internal/domain"
	"github.com/healthos/notification-service/internal/gateway/smtp"
	"github.com/healthos/notification-service/internal/gateway/whatsapp"
	"github.com/healthos/notification-service/internal/handler/middleware"
	"github.com/healthos/notification-service/internal/service"
	"github.com/healthos/pkg/healthos/fxutil"
	"github.com/healthos/pkg/healthos/httpx"
	"github.com/healthos/pkg/healthos/jwt"
	"github.com/healthos/pkg/healthos/observability"
	"go.uber.org/fx"
)

type RouterParams struct {
	fx.In

	Config       config.Config
	Templates    *service.TemplateService
	Providers    *service.ProviderConfigService
	Topics       *service.TopicService
	Logs         *service.LogService
	OTPMailer    *smtp.OTPMailer
	WhatsApp     *whatsapp.Client
}

func NewRouter(p RouterParams) http.Handler {
	parser := jwt.NewParser(p.Config.JWTSecret)
	r := chi.NewRouter()
	r.Use(fxutil.CorrelationID)
	r.Use(middleware.JWT(parser))

	r.Get("/health", healthHandler)
	r.Get("/actuator/health", observability.ActuatorHealth)
	r.Handle("/actuator/prometheus", observability.MetricsHandler())

	r.Route("/internal/notifications", func(r chi.Router) {
		r.Post("/whatsapp", p.sendWhatsapp)
		r.Post("/email", p.sendEmail)
	})

	admin := func(h http.Handler) http.Handler {
		return middleware.RequireRoles("SUPER_ADMIN", "NOTIFICATION_ADMIN", "READ_ONLY")(h)
	}
	writeAdmin := func(h http.Handler) http.Handler {
		return middleware.RequireRoles("SUPER_ADMIN", "NOTIFICATION_ADMIN")(h)
	}

	r.With(writeAdmin).Post("/templates", p.createTemplate)
	r.With(writeAdmin).Put("/templates/{id}", p.updateTemplate)
	r.With(writeAdmin).Delete("/templates/{id}", p.deleteTemplate)
	r.With(admin).Get("/templates", p.listTemplates)
	r.With(admin).Get("/templates/{id}", p.getTemplate)

	r.With(writeAdmin).Post("/provider-configs", p.createProviderConfig)
	r.With(writeAdmin).Put("/provider-configs/{id}", p.updateProviderConfig)
	r.With(admin).Get("/provider-configs", p.listProviderConfigs)
	r.With(admin).Get("/provider-configs/{id}", p.getProviderConfig)

	r.With(writeAdmin).Post("/topics", p.createTopic)
	r.With(admin).Get("/topics", p.listTopics)

	r.With(admin).Get("/logs", p.listLogs)
	r.With(admin).Get("/logs/{id}", p.getLog)

	return r
}

func healthHandler(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{
		"status": "UP", "service": "notification-service", "timestamp": time.Now().UTC(),
	})
}

func (p RouterParams) sendWhatsapp(w http.ResponseWriter, r *http.Request) {
	var req whatsappSendRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || strings.TrimSpace(req.To) == "" {
		httpx.WriteAPIError(w, http.StatusBadRequest, "BAD_REQUEST", "invalid request", r.URL.Path)
		return
	}
	vars := req.Variables
	if vars == nil {
		vars = map[string]string{}
	}
	msg := whatsapp.RenderTemplate(p.Config.WhatsApp.OTPMessageTemplate, vars)
	delivered := p.WhatsApp.SendText(req.To, msg)
	writeJSON(w, http.StatusOK, sendResult{Delivered: delivered})
}

func (p RouterParams) sendEmail(w http.ResponseWriter, r *http.Request) {
	var req emailSendRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || strings.TrimSpace(req.To) == "" {
		httpx.WriteAPIError(w, http.StatusBadRequest, "BAD_REQUEST", "invalid request", r.URL.Path)
		return
	}
	vars := req.Variables
	if vars == nil {
		vars = map[string]string{}
	}
	if req.Phone != "" {
		if _, ok := vars["phone"]; !ok {
			vars["phone"] = req.Phone
		}
	}
	delivered := p.OTPMailer.Send(req.To, req.Phone, vars)
	writeJSON(w, http.StatusOK, sendResult{Delivered: delivered})
}

func (p RouterParams) createTemplate(w http.ResponseWriter, r *http.Request) {
	var req templateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.Topic == "" || req.Body == "" || req.Channel == "" {
		httpx.WriteAPIError(w, http.StatusBadRequest, "VALIDATION_ERROR", "Validation failed", r.URL.Path)
		return
	}
	t := domain.NotificationTemplate{
		TenantID: req.TenantID, Topic: req.Topic, Channel: domain.Channel(req.Channel),
		Subject: req.Subject, Body: req.Body, Active: req.Active,
	}
	saved, err := p.Templates.Create(t)
	if err != nil {
		writeErr(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, mapTemplate(saved))
}

func (p RouterParams) updateTemplate(w http.ResponseWriter, r *http.Request) {
	var req templateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpx.WriteAPIError(w, http.StatusBadRequest, "VALIDATION_ERROR", "Validation failed", r.URL.Path)
		return
	}
	updates := domain.NotificationTemplate{
		TenantID: req.TenantID, Topic: req.Topic, Channel: domain.Channel(req.Channel),
		Subject: req.Subject, Body: req.Body, Active: req.Active,
	}
	saved, err := p.Templates.Update(chi.URLParam(r, "id"), updates)
	if err != nil {
		writeErr(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, mapTemplate(saved))
}

func (p RouterParams) listTemplates(w http.ResponseWriter, r *http.Request) {
	items, err := p.Templates.ListAll()
	if err != nil {
		httpx.WriteAPIError(w, http.StatusInternalServerError, "INTERNAL_ERROR", "Unexpected error", r.URL.Path)
		return
	}
	out := make([]templateResponse, len(items))
	for i, t := range items {
		out[i] = mapTemplate(t)
	}
	writeJSON(w, http.StatusOK, out)
}

func (p RouterParams) getTemplate(w http.ResponseWriter, r *http.Request) {
	t, err := p.Templates.GetByID(chi.URLParam(r, "id"))
	if err != nil {
		writeErr(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, mapTemplate(t))
}

func (p RouterParams) deleteTemplate(w http.ResponseWriter, r *http.Request) {
	if err := p.Templates.Delete(chi.URLParam(r, "id")); err != nil {
		writeErr(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (p RouterParams) createProviderConfig(w http.ResponseWriter, r *http.Request) {
	var req providerConfigRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.ProviderType == "" || req.Provider == "" {
		httpx.WriteAPIError(w, http.StatusBadRequest, "VALIDATION_ERROR", "Validation failed", r.URL.Path)
		return
	}
	pc := domain.ProviderConfig{
		TenantID: req.TenantID, ProviderType: domain.ProviderType(req.ProviderType),
		Provider: domain.Provider(req.Provider), Active: req.Active, Config: req.Config,
	}
	saved, err := p.Providers.Create(pc)
	if err != nil {
		writeErr(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, mapProviderConfig(saved))
}

func (p RouterParams) updateProviderConfig(w http.ResponseWriter, r *http.Request) {
	var req providerConfigRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpx.WriteAPIError(w, http.StatusBadRequest, "VALIDATION_ERROR", "Validation failed", r.URL.Path)
		return
	}
	updates := domain.ProviderConfig{
		TenantID: req.TenantID, ProviderType: domain.ProviderType(req.ProviderType),
		Provider: domain.Provider(req.Provider), Active: req.Active, Config: req.Config,
	}
	saved, err := p.Providers.Update(chi.URLParam(r, "id"), updates)
	if err != nil {
		writeErr(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, mapProviderConfig(saved))
}

func (p RouterParams) listProviderConfigs(w http.ResponseWriter, r *http.Request) {
	items, err := p.Providers.ListAll()
	if err != nil {
		httpx.WriteAPIError(w, http.StatusInternalServerError, "INTERNAL_ERROR", "Unexpected error", r.URL.Path)
		return
	}
	out := make([]providerConfigResponse, len(items))
	for i, pc := range items {
		out[i] = mapProviderConfig(pc)
	}
	writeJSON(w, http.StatusOK, out)
}

func (p RouterParams) getProviderConfig(w http.ResponseWriter, r *http.Request) {
	pc, err := p.Providers.GetByID(chi.URLParam(r, "id"))
	if err != nil {
		writeErr(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, mapProviderConfig(pc))
}

func (p RouterParams) createTopic(w http.ResponseWriter, r *http.Request) {
	var req topicRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || strings.TrimSpace(req.Topic) == "" {
		httpx.WriteAPIError(w, http.StatusBadRequest, "VALIDATION_ERROR", "Validation failed", r.URL.Path)
		return
	}
	saved, err := p.Topics.Create(domain.NotificationTopic{Topic: req.Topic, Description: req.Description})
	if err != nil {
		if strings.Contains(err.Error(), "already exists") {
			httpx.WriteAPIError(w, http.StatusConflict, "CONFLICT", err.Error(), r.URL.Path)
			return
		}
		writeErr(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, mapTopic(saved))
}

func (p RouterParams) listTopics(w http.ResponseWriter, r *http.Request) {
	items, err := p.Topics.ListAll()
	if err != nil {
		httpx.WriteAPIError(w, http.StatusInternalServerError, "INTERNAL_ERROR", "Unexpected error", r.URL.Path)
		return
	}
	out := make([]topicResponse, len(items))
	for i, t := range items {
		out[i] = mapTopic(t)
	}
	writeJSON(w, http.StatusOK, out)
}

func (p RouterParams) listLogs(w http.ResponseWriter, r *http.Request) {
	items, err := p.Logs.ListAll()
	if err != nil {
		httpx.WriteAPIError(w, http.StatusInternalServerError, "INTERNAL_ERROR", "Unexpected error", r.URL.Path)
		return
	}
	out := make([]logResponse, len(items))
	for i, l := range items {
		out[i] = mapLog(l)
	}
	writeJSON(w, http.StatusOK, out)
}

func (p RouterParams) getLog(w http.ResponseWriter, r *http.Request) {
	log, err := p.Logs.GetByID(chi.URLParam(r, "id"))
	if err != nil {
		writeErr(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, mapLog(log))
}

type whatsappSendRequest struct {
	TenantID  string            `json:"tenantId"`
	To        string            `json:"to"`
	Topic     string            `json:"topic"`
	Variables map[string]string `json:"variables"`
}

type emailSendRequest struct {
	TenantID  string            `json:"tenantId"`
	To        string            `json:"to"`
	Phone     string            `json:"phone"`
	Topic     string            `json:"topic"`
	Variables map[string]string `json:"variables"`
}

type sendResult struct {
	Delivered bool `json:"delivered"`
}

type templateRequest struct {
	TenantID *string `json:"tenantId"`
	Topic    string  `json:"topic"`
	Channel  string  `json:"channel"`
	Subject  *string `json:"subject"`
	Body     string  `json:"body"`
	Active   bool    `json:"active"`
}

type templateResponse struct {
	ID        string  `json:"id"`
	TenantID  *string `json:"tenantId"`
	Topic     string  `json:"topic"`
	Channel   string  `json:"channel"`
	Subject   *string `json:"subject"`
	Body      string  `json:"body"`
	Active    bool    `json:"active"`
	CreatedAt string  `json:"createdAt"`
	UpdatedAt string  `json:"updatedAt"`
}

type providerConfigRequest struct {
	TenantID     *string           `json:"tenantId"`
	ProviderType string            `json:"providerType"`
	Provider     string            `json:"provider"`
	Active       bool              `json:"active"`
	Config       map[string]string `json:"config"`
}

type providerConfigResponse struct {
	ID           string            `json:"id"`
	TenantID     *string           `json:"tenantId"`
	ProviderType string            `json:"providerType"`
	Provider     string            `json:"provider"`
	Active       bool              `json:"active"`
	Config       map[string]string `json:"config"`
	CreatedAt    string            `json:"createdAt"`
	UpdatedAt    string            `json:"updatedAt"`
}

type topicRequest struct {
	Topic       string `json:"topic"`
	Description string `json:"description"`
}

type topicResponse struct {
	ID          string `json:"id"`
	Topic       string `json:"topic"`
	Description string `json:"description"`
	CreatedAt   string `json:"createdAt"`
}

type logResponse struct {
	ID              string `json:"id"`
	EventID         string `json:"eventId"`
	TenantID        string `json:"tenantId"`
	Topic           string `json:"topic"`
	Channel         string `json:"channel"`
	Recipient       string `json:"recipient"`
	RenderedMessage string `json:"renderedMessage"`
	Provider        string `json:"provider"`
	Status          string `json:"status"`
	RetryCount      int    `json:"retryCount"`
	RequestPayload  string `json:"requestPayload"`
	ResponsePayload string `json:"responsePayload"`
	ErrorMessage    string `json:"errorMessage"`
	CreatedAt       string `json:"createdAt"`
}

func mapTemplate(t domain.NotificationTemplate) templateResponse {
	return templateResponse{
		ID: t.ID, TenantID: t.TenantID, Topic: t.Topic, Channel: string(t.Channel),
		Subject: t.Subject, Body: t.Body, Active: t.Active,
		CreatedAt: t.CreatedAt.UTC().Format(time.RFC3339Nano),
		UpdatedAt: t.UpdatedAt.UTC().Format(time.RFC3339Nano),
	}
}

func mapProviderConfig(pc domain.ProviderConfig) providerConfigResponse {
	return providerConfigResponse{
		ID: pc.ID, TenantID: pc.TenantID, ProviderType: string(pc.ProviderType),
		Provider: string(pc.Provider), Active: pc.Active, Config: pc.Config,
		CreatedAt: pc.CreatedAt.UTC().Format(time.RFC3339Nano),
		UpdatedAt: pc.UpdatedAt.UTC().Format(time.RFC3339Nano),
	}
}

func mapTopic(t domain.NotificationTopic) topicResponse {
	return topicResponse{
		ID: t.ID, Topic: t.Topic, Description: t.Description,
		CreatedAt: t.CreatedAt.UTC().Format(time.RFC3339Nano),
	}
}

func mapLog(l domain.NotificationLog) logResponse {
	return logResponse{
		ID: l.ID, EventID: l.EventID, TenantID: l.TenantID, Topic: l.Topic,
		Channel: string(l.Channel), Recipient: l.Recipient, RenderedMessage: l.RenderedMessage,
		Provider: l.Provider, Status: string(l.Status), RetryCount: l.RetryCount,
		RequestPayload: l.RequestPayload, ResponsePayload: l.ResponsePayload,
		ErrorMessage: l.ErrorMessage, CreatedAt: l.CreatedAt.UTC().Format(time.RFC3339Nano),
	}
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeErr(w http.ResponseWriter, r *http.Request, err error) {
	if errors.Is(err, errNotFound{}) || strings.Contains(err.Error(), "not found") {
		httpx.WriteAPIError(w, http.StatusBadRequest, "BAD_REQUEST", err.Error(), r.URL.Path)
		return
	}
	httpx.WriteAPIError(w, http.StatusInternalServerError, "INTERNAL_ERROR", "Unexpected error", r.URL.Path)
}

type errNotFound struct{}

func (errNotFound) Error() string { return "not found" }
