package main

import (
	"github.com/healthos/notification-service/internal/app"
	"go.uber.org/fx"
)

func main() {
	fx.New(app.Module).Run()
}
