package redis

import (
	"context"
	"fmt"
	"time"

	"github.com/healthos/notification-service/internal/config"
	"github.com/healthos/notification-service/internal/domain"
	"github.com/redis/go-redis/v9"
	"go.uber.org/fx"
)

type Store struct {
	client *redis.Client
	cfg    config.Config
}

func NewStore(lc fx.Lifecycle, cfg config.Config) (*Store, error) {
	client := redis.NewClient(&redis.Options{Addr: cfg.RedisAddr})
	if err := client.Ping(context.Background()).Err(); err != nil {
		return nil, err
	}
	s := &Store{client: client, cfg: cfg}
	lc.Append(fx.Hook{
		OnStop: func(ctx context.Context) error { return client.Close() },
	})
	return s, nil
}

func (s *Store) TryAcquire(tenantID, eventID string, channel domain.Channel) (bool, error) {
	key := fmt.Sprintf("notif:idem:%s:%s:%s", tenantID, eventID, channel)
	return s.client.SetNX(context.Background(), key, "1", time.Duration(s.cfg.IdempotencyTTL)*time.Second).Result()
}

func (s *Store) Allow(tenantID string) (bool, error) {
	key := "notif:rate:" + tenantID
	count, err := s.client.Incr(context.Background(), key).Result()
	if err != nil {
		return false, err
	}
	if count == 1 {
		_ = s.client.Expire(context.Background(), key, time.Duration(s.cfg.RateLimitWindow)*time.Second).Err()
	}
	return count <= int64(s.cfg.RateLimitMax), nil
}

var Module = fx.Module("redis", fx.Provide(NewStore))
