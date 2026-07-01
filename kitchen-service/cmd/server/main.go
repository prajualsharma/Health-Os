package main

import (
	"github.com/healthos/kitchen-service/internal/app"
	"go.uber.org/fx"
)

func main() {
	fx.New(app.Module).Run()
}
