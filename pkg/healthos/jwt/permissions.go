package jwt

import "strings"

// Kitchen role -> permission mapping (mirrors user-mgmt V4 seeds).
var kitchenRolePermissions = map[string][]string{
	"CORPORATE": {
		"kitchen:manage",
		"kitchen:menu:write",
		"kitchen:order:read",
		"kitchen:order:write",
	},
	"KITCHEN_STAFF": {
		"kitchen:menu:write",
		"kitchen:order:read",
		"kitchen:order:write",
	},
	"SUPER_ADMIN": {"kitchen:manage", "kitchen:menu:write", "kitchen:order:read", "kitchen:order:write"},
	"ADMIN":       {"kitchen:manage", "kitchen:menu:write", "kitchen:order:read", "kitchen:order:write"},
}

func (p Principal) HasPermission(permission string) bool {
	if !p.IsStaff() {
		return false
	}
	for _, role := range p.Roles {
		if permissionsForRole(role, permission) {
			return true
		}
	}
	if p.ScopedRole != "" && permissionsForRole(p.ScopedRole, permission) {
		return true
	}
	for _, m := range p.Memberships {
		if permissionsForRole(m.Role, permission) {
			return true
		}
	}
	return false
}

func permissionsForRole(role, permission string) bool {
	perms, ok := kitchenRolePermissions[strings.ToUpper(role)]
	if !ok {
		return false
	}
	for _, p := range perms {
		if p == permission {
			return true
		}
	}
	return false
}
