package app

import (
	"github.com/healthos/kitchen-service/internal/config"
	"github.com/healthos/kitchen-service/internal/gateway"
	"github.com/healthos/kitchen-service/internal/handler"
	"github.com/healthos/kitchen-service/internal/repository/postgres"
	"github.com/healthos/kitchen-service/internal/service"
	"github.com/healthos/pkg/healthos/fxutil"
	"github.com/healthos/pkg/healthos/observability"
	"go.uber.org/fx"
)

func provideHTTPPort(cfg config.Config) string {
	return cfg.Port
}

var Module = fx.Options(
	fx.Provide(config.Load),
	fx.Provide(observability.NewLogger),
	fx.Invoke(observability.RegisterLogger),
	fx.Provide(
		fx.Annotate(provideHTTPPort, fx.ResultTags(`name:"httpPort"`)),
	),
	postgres.Module,
	fx.Provide(gateway.NewUserManagementClient),
	fx.Provide(service.NewKitchenService, service.NewMenuService, service.NewOrderService),
	handler.Module,
	fx.Invoke(postgres.RunMigrations),
	fx.Invoke(fxutil.RunHTTPServer),
)
