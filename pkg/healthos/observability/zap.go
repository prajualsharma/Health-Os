package observability

import (
	"context"

	"go.uber.org/fx"
	"go.uber.org/zap"
)

func NewLogger() (*zap.Logger, error) {
	return zap.NewProduction()
}

func RegisterLogger(lc fx.Lifecycle, logger *zap.Logger) {
	lc.Append(fx.Hook{
		OnStop: func(context.Context) error {
			return logger.Sync()
		},
	})
}
