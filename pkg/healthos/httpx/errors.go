package httpx

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/google/uuid"
)

// Spring-style error body used by kitchen-service.
type SpringError struct {
	Timestamp string `json:"timestamp"`
	Status    int    `json:"status"`
	Error     string `json:"error"`
	Message   string `json:"message"`
}

// ApiError matches user-management / notification Java services.
type ApiError struct {
	TraceID   string    `json:"traceId"`
	Timestamp time.Time `json:"timestamp"`
	Status    int       `json:"status"`
	ErrorCode string    `json:"errorCode"`
	Message   string    `json:"message"`
	Path      string    `json:"path"`
}

func WriteSpringError(w http.ResponseWriter, status int, message string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(SpringError{
		Timestamp: time.Now().UTC().Format(time.RFC3339Nano),
		Status:    status,
		Error:     http.StatusText(status),
		Message:   message,
	})
}

func WriteAPIError(w http.ResponseWriter, status int, code, message, path string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(ApiError{
		TraceID:   uuid.NewString(),
		Timestamp: time.Now().UTC(),
		Status:    status,
		ErrorCode: code,
		Message:   message,
		Path:      path,
	})
}
