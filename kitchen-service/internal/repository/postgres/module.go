package postgres

import (
	"context"
	"errors"
	"fmt"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/healthos/kitchen-service/internal/config"
	"github.com/healthos/kitchen-service/internal/domain"
	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/fx"
	"go.uber.org/zap"
)

func NewPool(cfg config.Config) (*pgxpool.Pool, error) {
	pool, err := pgxpool.New(context.Background(), cfg.DatabaseURL)
	if err != nil {
		return nil, err
	}
	if err := pool.Ping(context.Background()); err != nil {
		pool.Close()
		return nil, err
	}
	return pool, nil
}

func RunMigrations(lc fx.Lifecycle, cfg config.Config, logger *zap.Logger) {
	lc.Append(fx.Hook{
		OnStart: func(ctx context.Context) error {
			m, err := migrate.New(cfg.MigrationsPath, cfg.DatabaseURL)
			if err != nil {
				return fmt.Errorf("migrate init: %w", err)
			}
			defer m.Close()
			if err := m.Up(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
				return fmt.Errorf("migrate up: %w", err)
			}
			logger.Info("database migrations applied")
			return nil
		},
	})
}

var Module = fx.Module("postgres",
	fx.Provide(NewPool),
	fx.Provide(
		fx.Annotate(NewKitchenRepo, fx.As(new(domain.KitchenRepository))),
		fx.Annotate(NewMenuRepo, fx.As(new(domain.MenuRepository))),
		fx.Annotate(NewOrderRepo, fx.As(new(domain.OrderRepository))),
		fx.Annotate(NewCatalogRepo, fx.As(new(domain.CatalogRepository))),
	),
)
