package jwt

import (
	"fmt"
	"strings"

	jwtlib "github.com/golang-jwt/jwt/v5"
)

// Membership is a scoped portal role assignment from user-management JWT claims.
type Membership struct {
	Portal    string
	ScopeType string
	ScopeID   string
	Role      string
}

// Principal mirrors the JWT claims used across HealthOS services.
type Principal struct {
	UserID      string
	AccountType string // CONSUMER | STAFF
	Issuer      string
	Email       string
	Roles       []string
	Memberships []Membership
	PortalType  string
	ScopeType   string
	ScopeID     string
	ScopedRole  string
}

func (p Principal) HasRole(role string) bool {
	for _, r := range p.Roles {
		if strings.EqualFold(r, role) {
			return true
		}
	}
	return false
}

func (p Principal) HasAnyRole(roles ...string) bool {
	for _, want := range roles {
		if p.HasRole(want) {
			return true
		}
	}
	return false
}

func (p Principal) IsStaff() bool {
	return strings.EqualFold(p.AccountType, "STAFF")
}

func (p Principal) IsConsumer() bool {
	return strings.EqualFold(p.AccountType, "CONSUMER")
}

// Parser validates HS256 JWTs issued by user-management-service.
type Parser struct {
	secret         []byte
	allowedIssuers map[string]struct{}
}

func NewParser(secret string) *Parser {
	return &Parser{
		secret: []byte(secret),
		allowedIssuers: map[string]struct{}{
			"healthos":          {},
			"healthos-consumer": {},
			"healthos-staff":    {},
		},
	}
}

func (p *Parser) AllowIssuer(iss string) {
	if iss == "" {
		return
	}
	if p.allowedIssuers == nil {
		p.allowedIssuers = map[string]struct{}{}
	}
	p.allowedIssuers[iss] = struct{}{}
}

func (p *Parser) Parse(token string) (Principal, error) {
	claims := jwtlib.MapClaims{}
	parsed, err := jwtlib.ParseWithClaims(token, claims, func(t *jwtlib.Token) (any, error) {
		if t.Method != jwtlib.SigningMethodHS256 {
			return nil, fmt.Errorf("unexpected signing method")
		}
		return p.secret, nil
	})
	if err != nil || !parsed.Valid {
		return Principal{}, fmt.Errorf("invalid token: %w", err)
	}

	iss, _ := claims["iss"].(string)
	if iss != "" {
		if _, ok := p.allowedIssuers[iss]; !ok {
			return Principal{}, fmt.Errorf("untrusted issuer: %s", iss)
		}
	}

	sub, _ := claims["sub"].(string)
	if sub == "" {
		return Principal{}, fmt.Errorf("missing subject")
	}

	principal := Principal{UserID: sub, Issuer: iss}
	if email, ok := claims["email"].(string); ok {
		principal.Email = email
	}
	if at, ok := claims["accountType"].(string); ok {
		principal.AccountType = at
	} else if strings.Contains(iss, "staff") {
		principal.AccountType = "STAFF"
	} else {
		principal.AccountType = "CONSUMER"
	}
	principal.Roles = stringSliceClaim(claims["roles"])
	principal.Memberships = parseMemberships(claims["memberships"])

	if activeScope, ok := claims["activeScope"].(map[string]any); ok {
		if v, ok := activeScope["portal"].(string); ok {
			principal.PortalType = v
		}
		if v, ok := activeScope["scopeType"].(string); ok {
			principal.ScopeType = v
		}
		if v, ok := activeScope["scopeId"].(string); ok {
			principal.ScopeID = v
		}
	}
	principal.ScopedRole = scopedRoleForActive(principal.Memberships, principal.PortalType, principal.ScopeType, principal.ScopeID)

	return principal, nil
}

func scopedRoleForActive(memberships []Membership, portal, scopeType, scopeID string) string {
	for _, m := range memberships {
		if strings.EqualFold(m.Portal, portal) &&
			strings.EqualFold(m.ScopeType, scopeType) &&
			m.ScopeID == scopeID {
			return m.Role
		}
	}
	return ""
}

func parseMemberships(raw any) []Membership {
	list, ok := raw.([]any)
	if !ok {
		return nil
	}
	out := make([]Membership, 0, len(list))
	for _, item := range list {
		m, ok := item.(map[string]any)
		if !ok {
			continue
		}
		out = append(out, Membership{
			Portal:    fmt.Sprint(m["portal"]),
			ScopeType: fmt.Sprint(m["scopeType"]),
			ScopeID:   fmt.Sprint(m["scopeId"]),
			Role:      fmt.Sprint(m["role"]),
		})
	}
	return out
}

func stringSliceClaim(raw any) []string {
	switch v := raw.(type) {
	case []any:
		out := make([]string, 0, len(v))
		for _, item := range v {
			if s, ok := item.(string); ok && s != "" {
				out = append(out, s)
			}
		}
		return out
	case []string:
		return v
	default:
		return nil
	}
}
