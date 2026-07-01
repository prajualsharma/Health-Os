package fxutil

import (
	"context"
	"net/http"
	"time"

	"go.uber.org/fx"
	"go.uber.org/zap"
)

type HTTPServerParams struct {
	fx.In

	Lifecycle fx.Lifecycle
	Logger    *zap.Logger
	Handler   http.Handler
	Port      string `name:"httpPort"`
}

func RunHTTPServer(p HTTPServerParams) {
	srv := &http.Server{
		Addr:              ":" + p.Port,
		Handler:           p.Handler,
		ReadHeaderTimeout: 10 * time.Second,
	}

	p.Lifecycle.Append(fx.Hook{
		OnStart: func(ctx context.Context) error {
			go func() {
				p.Logger.Info("http server listening", zap.String("addr", srv.Addr))
				if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
					p.Logger.Fatal("http server failed", zap.Error(err))
				}
			}()
			return nil
		},
		OnStop: func(ctx context.Context) error {
			shutdownCtx, cancel := context.WithTimeout(ctx, 15*time.Second)
			defer cancel()
			return srv.Shutdown(shutdownCtx)
		},
	})
}
