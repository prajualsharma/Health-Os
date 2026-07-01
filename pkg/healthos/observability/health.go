package observability

import (
	"encoding/json"
	"net/http"
)

// ActuatorHealth mirrors Spring Boot /actuator/health JSON.
func ActuatorHealth(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(map[string]any{
		"status": "UP",
	})
}
