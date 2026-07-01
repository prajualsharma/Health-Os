package fxutil

import (
	"net/http"

	"github.com/google/uuid"
)

const CorrelationHeader = "X-Correlation-Id"

func CorrelationID(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		cid := r.Header.Get(CorrelationHeader)
		if cid == "" {
			cid = uuid.NewString()
		}
		w.Header().Set(CorrelationHeader, cid)
		next.ServeHTTP(w, r.WithContext(r.Context()))
	})
}
