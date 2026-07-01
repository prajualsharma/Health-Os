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

func RequireRoles(roles ...string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			p, ok := PrincipalFrom(r.Context())
			if !ok || !p.HasAnyRole(roles...) {
				httpx.WriteAPIError(w, http.StatusForbidden, "FORBIDDEN", "Access denied", r.URL.Path)
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}
