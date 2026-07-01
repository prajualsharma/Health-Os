package handler

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/healthos/kitchen-service/internal/config"
	"github.com/healthos/kitchen-service/internal/handler/middleware"
	"github.com/healthos/pkg/healthos/fxutil"
	"github.com/healthos/pkg/healthos/jwt"
	"github.com/healthos/pkg/healthos/observability"
	"go.uber.org/fx"
)

type RouterParams struct {
	fx.In

	Config          config.Config
	KitchenHandler  *KitchenHandler
	MenuHandler     *MenuHandler
	OrderHandler    *OrderHandler
	CatalogHandler  *CatalogHandler
}

func NewRouter(p RouterParams) http.Handler {
	parser := jwt.NewParser(p.Config.JWTSecret)
	r := chi.NewRouter()
	r.Use(fxutil.CorrelationID)
	r.Use(middleware.JWT(parser))

	r.Get("/actuator/health", observability.ActuatorHealth)
	r.Get("/health", observability.ActuatorHealth)
	r.Handle("/actuator/prometheus", observability.MetricsHandler())

	r.Route("/kitchen", func(r chi.Router) {
		r.Use(middleware.RequireAuth)
		r.Use(middleware.RequireStaff)
		r.With(middleware.RequirePermission("kitchen:manage")).Mount("/kitchens", p.KitchenHandler.Routes())
		r.With(middleware.RequirePermission("kitchen:menu:write")).Get("/kitchens/{kitchenId}/menu", p.MenuHandler.list)
		r.With(middleware.RequirePermission("kitchen:menu:write")).Post("/kitchens/{kitchenId}/menu", p.MenuHandler.create)
		r.With(middleware.RequirePermission("kitchen:menu:write")).Patch("/menu/{itemId}", p.MenuHandler.update)
		r.With(middleware.RequirePermission("kitchen:order:read")).Get("/kitchens/{kitchenId}/orders", p.OrderHandler.list)
		r.With(middleware.RequirePermission("kitchen:order:write")).Post("/kitchens/{kitchenId}/orders", p.OrderHandler.create)
		r.With(middleware.RequirePermission("kitchen:order:write")).Patch("/orders/{orderId}/status", p.OrderHandler.updateStatus)
		r.Route("/catalog", func(r chi.Router) {
			r.Use(middleware.RequirePermission("kitchen:menu:write"))
			r.Mount("/", p.CatalogHandler.AdminRoutes())
		})
	})

	r.Mount("/v1", p.CatalogHandler.ConsumerRoutes())

	return r
}

var Module = fx.Module("handler",
	fx.Provide(NewKitchenHandler, NewMenuHandler, NewOrderHandler, NewCatalogHandler, NewRouter),
)
