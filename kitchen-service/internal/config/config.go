package config

import (
	"fmt"
	"net/url"
	"strings"

	"github.com/healthos/pkg/healthos/config"
)

type Config struct {
	Port                 string
	DatabaseURL          string
	JWTIssuer            string
	JWTSecret            string
	UserMgmtBaseURL      string
	MigrationsPath       string
	// NotificationTenantID should match the org scopeId when publishing notification events.
	NotificationTenantID string
}

func Load() Config {
	user := firstNonEmpty(
		config.Getenv("SPRING_DATASOURCE_USERNAME", ""),
		config.Getenv("POSTGRES_USER", "healthos"),
	)
	pass := firstNonEmpty(
		config.Getenv("SPRING_DATASOURCE_PASSWORD", ""),
		config.Getenv("POSTGRES_PASSWORD", "healthos"),
	)

	dbURL := config.Getenv("DATABASE_URL", "")
	if dbURL == "" {
		if jdbc := config.Getenv("SPRING_DATASOURCE_URL", ""); jdbc != "" {
			dbURL = springJDBCtoPGX(jdbc, user, pass)
		} else {
			host := config.Getenv("POSTGRES_HOST", "localhost")
			port := config.Getenv("POSTGRES_PORT", "5432")
			db := config.Getenv("POSTGRES_DB", "healthos")
			dbURL = fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable",
				url.QueryEscape(user), url.QueryEscape(pass), host, port, db)
		}
	}

	return Config{
		Port:                 config.Getenv("SERVER_PORT", "8083"),
		DatabaseURL:          dbURL,
		JWTIssuer:            config.Getenv("JWT_ISSUER", "healthos"),
		JWTSecret:            config.Getenv("JWT_SECRET", "dev-only-change-me-dev-only-change-me"),
		UserMgmtBaseURL:      config.Getenv("USER_MGMT_BASE_URL", "http://localhost:8081"),
		MigrationsPath:       config.Getenv("MIGRATIONS_PATH", "file://migrations"),
		NotificationTenantID: config.Getenv("NOTIFICATION_TENANT_ID", ""),
	}
}

func springJDBCtoPGX(jdbcURL, user, pass string) string {
	const prefix = "jdbc:postgresql://"
	if strings.HasPrefix(jdbcURL, prefix) {
		rest := strings.TrimPrefix(jdbcURL, prefix)
		return fmt.Sprintf("postgres://%s:%s@%s?sslmode=disable",
			url.QueryEscape(user), url.QueryEscape(pass), rest)
	}
	return jdbcURL
}

func firstNonEmpty(values ...string) string {
	for _, v := range values {
		if v != "" {
			return v
		}
	}
	return ""
}
