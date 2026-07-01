package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/healthos/pkg/healthos/httpx"
	"github.com/healthos/pkg/healthos/jwt"
)

type principalKey struct{}

func WithPrincipal(ctx context.Context, p jwt.Principal) context.Context {
	return context.WithValue(ctx, principalKey{}, p)
}

func PrincipalFrom(ctx context.Context) (jwt.Principal, bool) {
	p, ok := ctx.Value(principalKey{}).(jwt.Principal)
	return p, ok
}

func JWT(parser *jwt.Parser) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			header := r.Header.Get("Authorization")
			if strings.HasPrefix(header, "Bearer ") {
				token := strings.TrimSpace(strings.TrimPrefix(header, "Bearer "))
				if principal, err := parser.Parse(token); err == nil {
					r = r.WithContext(WithPrincipal(r.Context(), principal))
				}
			}
			next.ServeHTTP(w, r)
		})
	}
}

func RequireAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if _, ok := PrincipalFrom(r.Context()); !ok {
			httpx.WriteSpringError(w, http.StatusForbidden, "Forbidden")
			return
		}
		next.ServeHTTP(w, r)
	})
}

func RequireStaff(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		p, ok := PrincipalFrom(r.Context())
		if !ok || !p.IsStaff() {
			httpx.WriteSpringError(w, http.StatusForbidden, "Staff account required")
			return
		}
		next.ServeHTTP(w, r)
	})
}

func RequirePermission(permission string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			p, ok := PrincipalFrom(r.Context())
			if !ok || !p.IsStaff() || !p.HasPermission(permission) {
				httpx.WriteSpringError(w, http.StatusForbidden, "Insufficient permissions")
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}
