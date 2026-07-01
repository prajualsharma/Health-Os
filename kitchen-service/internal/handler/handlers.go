package handler

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/healthos/kitchen-service/internal/domain"
	"github.com/healthos/kitchen-service/internal/handler/middleware"
	"github.com/healthos/kitchen-service/internal/service"
	"github.com/healthos/pkg/healthos/httpx"
)

type KitchenHandler struct {
	svc *service.KitchenService
}

func NewKitchenHandler(svc *service.KitchenService) *KitchenHandler {
	return &KitchenHandler{svc: svc}
}

func (h *KitchenHandler) Routes() chi.Router {
	r := chi.NewRouter()
	r.Get("/", h.list)
	r.Get("/{id}", h.get)
	r.Post("/", h.create)
	return r
}

func (h *KitchenHandler) list(w http.ResponseWriter, r *http.Request) {
	orgID := r.URL.Query().Get("orgId")
	if orgID == "" {
		if p, ok := middleware.PrincipalFrom(r.Context()); ok && p.ScopeType == "ORGANIZATION" {
			orgID = p.ScopeID
		}
	}
	kitchens, err := h.svc.List(orgID)
	if err != nil {
		httpx.WriteSpringError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, mapKitchens(kitchens))
}

func (h *KitchenHandler) get(w http.ResponseWriter, r *http.Request) {
	k, err := h.svc.Get(chi.URLParam(r, "id"))
	if err != nil {
		writeServiceError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, mapKitchen(k))
}

func (h *KitchenHandler) create(w http.ResponseWriter, r *http.Request) {
	var req createKitchenRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpx.WriteSpringError(w, http.StatusBadRequest, "invalid json")
		return
	}
	if strings.TrimSpace(req.Name) == "" {
		httpx.WriteSpringError(w, http.StatusBadRequest, "name must not be blank")
		return
	}
	orgID := ""
	if req.OrgID != nil {
		orgID = *req.OrgID
	} else if p, ok := middleware.PrincipalFrom(r.Context()); ok && p.ScopeType == "ORGANIZATION" {
		orgID = p.ScopeID
	}
	staffID := ""
	if req.StaffUserID != nil {
		staffID = *req.StaffUserID
	}
	k, err := h.svc.Create(orgID, req.Name, deref(req.Address), deref(req.City), staffID)
	if err != nil {
		writeServiceError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, mapKitchen(k))
}

type createKitchenRequest struct {
	Name        string  `json:"name"`
	Address     *string `json:"address"`
	City        *string `json:"city"`
	OrgID       *string `json:"orgId"`
	StaffUserID *string `json:"staffUserId"`
}

type kitchenResponse struct {
	ID        string `json:"id"`
	OrgID     string `json:"orgId"`
	Name      string `json:"name"`
	Address   string `json:"address"`
	City      string `json:"city"`
	Status    string `json:"status"`
	CreatedAt string `json:"createdAt"`
}

func mapKitchen(k domain.Kitchen) kitchenResponse {
	return kitchenResponse{
		ID: k.ID, OrgID: k.OrgID, Name: k.Name, Address: k.Address, City: k.City,
		Status: string(k.Status), CreatedAt: k.CreatedAt.UTC().Format("2006-01-02T15:04:05.999999999Z"),
	}
}

func mapKitchens(items []domain.Kitchen) []kitchenResponse {
	out := make([]kitchenResponse, len(items))
	for i, k := range items {
		out[i] = mapKitchen(k)
	}
	return out
}

type MenuHandler struct {
	svc *service.MenuService
}

func NewMenuHandler(svc *service.MenuService) *MenuHandler {
	return &MenuHandler{svc: svc}
}

func (h *MenuHandler) list(w http.ResponseWriter, r *http.Request) {
	items, err := h.svc.ListForKitchen(chi.URLParam(r, "kitchenId"))
	if err != nil {
		httpx.WriteSpringError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, mapMenuItems(items))
}

func (h *MenuHandler) create(w http.ResponseWriter, r *http.Request) {
	var req createMenuItemRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpx.WriteSpringError(w, http.StatusBadRequest, "invalid json")
		return
	}
	if strings.TrimSpace(req.Name) == "" {
		httpx.WriteSpringError(w, http.StatusBadRequest, "name must not be blank")
		return
	}
	item, err := h.svc.Create(chi.URLParam(r, "kitchenId"), service.CreateMenuItemInput{
		Name: req.Name, Description: deref(req.Description), Category: domain.MealCategory(req.Category),
		PriceCents: req.PriceCents, Veg: req.Veg, Available: req.Available,
	})
	if err != nil {
		writeServiceError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, mapMenuItem(item))
}

func (h *MenuHandler) update(w http.ResponseWriter, r *http.Request) {
	var req updateMenuItemRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpx.WriteSpringError(w, http.StatusBadRequest, "invalid json")
		return
	}
	var category *domain.MealCategory
	if req.Category != nil {
		c := domain.MealCategory(*req.Category)
		category = &c
	}
	item, err := h.svc.Update(chi.URLParam(r, "itemId"), service.UpdateMenuItemInput{
		Name: req.Name, Description: req.Description, Category: category,
		PriceCents: req.PriceCents, Veg: req.Veg, Available: req.Available,
	})
	if err != nil {
		writeServiceError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, mapMenuItem(item))
}

type createMenuItemRequest struct {
	Name        string  `json:"name"`
	Description *string `json:"description"`
	Category    string  `json:"category"`
	PriceCents  int     `json:"priceCents"`
	Veg         bool    `json:"veg"`
	Available   *bool   `json:"available"`
}

type updateMenuItemRequest struct {
	Name        *string `json:"name"`
	Description *string `json:"description"`
	Category    *string `json:"category"`
	PriceCents  *int    `json:"priceCents"`
	Veg         *bool   `json:"veg"`
	Available   *bool   `json:"available"`
}

type menuItemResponse struct {
	ID          string `json:"id"`
	KitchenID   string `json:"kitchenId"`
	Name        string `json:"name"`
	Description string `json:"description"`
	Category    string `json:"category"`
	PriceCents  int    `json:"priceCents"`
	Veg         bool   `json:"veg"`
	Available   bool   `json:"available"`
}

func mapMenuItem(m domain.MenuItem) menuItemResponse {
	return menuItemResponse{
		ID: m.ID, KitchenID: m.KitchenID, Name: m.Name, Description: m.Description,
		Category: string(m.Category), PriceCents: m.PriceCents, Veg: m.Veg, Available: m.Available,
	}
}

func mapMenuItems(items []domain.MenuItem) []menuItemResponse {
	out := make([]menuItemResponse, len(items))
	for i, m := range items {
		out[i] = mapMenuItem(m)
	}
	return out
}

type OrderHandler struct {
	svc *service.OrderService
}

func NewOrderHandler(svc *service.OrderService) *OrderHandler {
	return &OrderHandler{svc: svc}
}

func (h *OrderHandler) list(w http.ResponseWriter, r *http.Request) {
	activeOnly := r.URL.Query().Get("activeOnly") == "true"
	orders, err := h.svc.ListForKitchen(chi.URLParam(r, "kitchenId"), activeOnly)
	if err != nil {
		httpx.WriteSpringError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, mapOrders(orders))
}

func (h *OrderHandler) create(w http.ResponseWriter, r *http.Request) {
	var req createOrderRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpx.WriteSpringError(w, http.StatusBadRequest, "invalid json")
		return
	}
	if strings.TrimSpace(req.CustomerName) == "" || len(req.Items) == 0 {
		httpx.WriteSpringError(w, http.StatusBadRequest, "validation failed")
		return
	}
	items := make([]service.OrderLineInput, len(req.Items))
	for i, line := range req.Items {
		if strings.TrimSpace(line.Name) == "" || line.Quantity <= 0 {
			httpx.WriteSpringError(w, http.StatusBadRequest, "validation failed")
			return
		}
		items[i] = service.OrderLineInput{
			MenuItemID: deref(line.MenuItemID), Name: line.Name,
			Quantity: line.Quantity, PriceCents: line.PriceCents,
		}
	}
	order, err := h.svc.Create(chi.URLParam(r, "kitchenId"), service.CreateOrderInput{
		CustomerName: req.CustomerName, CustomerPhone: deref(req.CustomerPhone), Items: items,
	})
	if err != nil {
		writeServiceError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, mapOrder(order))
}

func (h *OrderHandler) updateStatus(w http.ResponseWriter, r *http.Request) {
	var req updateOrderStatusRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpx.WriteSpringError(w, http.StatusBadRequest, "invalid json")
		return
	}
	if req.Status == "" {
		httpx.WriteSpringError(w, http.StatusBadRequest, "status must not be null")
		return
	}
	order, err := h.svc.UpdateStatus(chi.URLParam(r, "orderId"), domain.OrderStatus(req.Status))
	if err != nil {
		writeServiceError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, mapOrder(order))
}

type createOrderRequest struct {
	CustomerName  string             `json:"customerName"`
	CustomerPhone *string            `json:"customerPhone"`
	Items         []orderLineRequest `json:"items"`
}

type orderLineRequest struct {
	MenuItemID *string `json:"menuItemId"`
	Name       string  `json:"name"`
	Quantity   int     `json:"quantity"`
	PriceCents int     `json:"priceCents"`
}

type updateOrderStatusRequest struct {
	Status string `json:"status"`
}

type orderLineResponse struct {
	ID         string  `json:"id"`
	MenuItemID *string `json:"menuItemId"`
	Name       string  `json:"name"`
	Quantity   int     `json:"quantity"`
	PriceCents int     `json:"priceCents"`
}

type orderResponse struct {
	ID            string              `json:"id"`
	KitchenID     string              `json:"kitchenId"`
	OrderCode     string              `json:"orderCode"`
	CustomerName  string              `json:"customerName"`
	CustomerPhone string              `json:"customerPhone"`
	Status        string              `json:"status"`
	TotalCents    int                 `json:"totalCents"`
	Items         []orderLineResponse `json:"items"`
	CreatedAt     string              `json:"createdAt"`
	UpdatedAt     string              `json:"updatedAt"`
}

func mapOrder(o domain.FoodOrder) orderResponse {
	lines := make([]orderLineResponse, len(o.Items))
	for i, l := range o.Items {
		lines[i] = orderLineResponse{
			ID: l.ID, MenuItemID: l.MenuItemID, Name: l.Name,
			Quantity: l.Quantity, PriceCents: l.PriceCents,
		}
	}
	return orderResponse{
		ID: o.ID, KitchenID: o.KitchenID, OrderCode: o.OrderCode,
		CustomerName: o.CustomerName, CustomerPhone: o.CustomerPhone,
		Status: string(o.Status), TotalCents: o.TotalCents, Items: lines,
		CreatedAt: o.CreatedAt.UTC().Format("2006-01-02T15:04:05.999999999Z"),
		UpdatedAt: o.UpdatedAt.UTC().Format("2006-01-02T15:04:05.999999999Z"),
	}
}

func mapOrders(orders []domain.FoodOrder) []orderResponse {
	out := make([]orderResponse, len(orders))
	for i, o := range orders {
		out[i] = mapOrder(o)
	}
	return out
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeServiceError(w http.ResponseWriter, err error) {
	var nf service.NotFoundError
	if errors.As(err, &nf) {
		httpx.WriteSpringError(w, http.StatusNotFound, nf.Message)
		return
	}
	if strings.Contains(err.Error(), "cannot transition") {
		httpx.WriteSpringError(w, http.StatusBadRequest, err.Error())
		return
	}
	httpx.WriteSpringError(w, http.StatusInternalServerError, err.Error())
}

func deref[T any](v *T) T {
	if v == nil {
		var zero T
		return zero
	}
	return *v
}
