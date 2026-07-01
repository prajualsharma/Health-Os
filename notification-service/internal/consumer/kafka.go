package consumer

import (
	"context"
	"encoding/json"
	"strings"
	"time"

	"github.com/healthos/notification-service/internal/config"
	"github.com/healthos/notification-service/internal/domain"
	"github.com/healthos/notification-service/internal/service"
	envconfig "github.com/healthos/pkg/healthos/config"
	"github.com/twmb/franz-go/pkg/kgo"
	"go.uber.org/fx"
	"go.uber.org/zap"
)

type KafkaConsumer struct {
	cfg       config.Config
	processor *service.NotificationProcessor
	logger    *zap.Logger
	client    *kgo.Client
}

func NewKafkaConsumer(lc fx.Lifecycle, cfg config.Config, processor *service.NotificationProcessor, logger *zap.Logger) (*KafkaConsumer, error) {
	if !envconfig.GetenvBool("KAFKA_LISTENER_AUTO_STARTUP", true) {
		logger.Info("kafka listener disabled")
		return &KafkaConsumer{cfg: cfg, processor: processor, logger: logger}, nil
	}
	brokers := strings.Split(cfg.KafkaBrokers, ",")
	client, err := kgo.NewClient(
		kgo.SeedBrokers(brokers...),
		kgo.ConsumerGroup("notification-service"),
		kgo.ConsumeTopics(cfg.MainTopic, cfg.DLTTopic),
	)
	if err != nil {
		return nil, err
	}
	c := &KafkaConsumer{cfg: cfg, processor: processor, logger: logger, client: client}
	lc.Append(fx.Hook{
		OnStart: func(ctx context.Context) error {
			go c.run(ctx)
			return nil
		},
		OnStop: func(ctx context.Context) error {
			client.Close()
			return nil
		},
	})
	return c, nil
}

func (c *KafkaConsumer) run(ctx context.Context) {
	if c.client == nil {
		return
	}
	for {
		select {
		case <-ctx.Done():
			return
		default:
		}
		fetches := c.client.PollFetches(ctx)
		if errs := fetches.Errors(); len(errs) > 0 {
			for _, e := range errs {
				c.logger.Warn("kafka fetch error", zap.Error(e.Err))
			}
		}
		fetches.EachRecord(func(rec *kgo.Record) {
			switch rec.Topic {
			case c.cfg.MainTopic:
				c.handleMain(ctx, rec)
			case c.cfg.DLTTopic:
				c.handleDLT(rec)
			}
		})
	}
}

func (c *KafkaConsumer) handleDLT(rec *kgo.Record) {
	var event domain.NotificationEvent
	if err := json.Unmarshal(rec.Value, &event); err != nil {
		return
	}
	c.logger.Error("message in DLT — manual replay required",
		zap.String("eventId", event.EventID),
		zap.String("tenantId", event.TenantID),
	)
}

func (c *KafkaConsumer) handleMain(ctx context.Context, rec *kgo.Record) {
	var event domain.NotificationEvent
	if err := json.Unmarshal(rec.Value, &event); err != nil {
		c.logger.Error("invalid kafka payload", zap.Error(err))
		return
	}
	c.logger.Info("consuming notification event",
		zap.String("eventId", event.EventID),
		zap.String("tenantId", event.TenantID),
		zap.String("topic", event.Topic),
	)
	var lastErr error
	for attempt := 0; attempt < 4; attempt++ {
		if attempt > 0 {
			delay := time.Duration(1<<uint(attempt-1)) * time.Second
			if delay > 10*time.Second {
				delay = 10 * time.Second
			}
			time.Sleep(delay)
		}
		lastErr = c.processor.Process(event)
		if lastErr == nil {
			return
		}
		c.logger.Warn("notification processing failed, will retry",
			zap.String("eventId", event.EventID),
			zap.Int("attempt", attempt+1),
			zap.Error(lastErr),
		)
	}
	payload, _ := json.Marshal(event)
	dlt := &kgo.Record{Topic: c.cfg.DLTTopic, Key: []byte(event.EventID), Value: payload}
	if err := c.client.ProduceSync(ctx, dlt).FirstErr(); err != nil {
		c.logger.Error("failed to publish to DLT", zap.Error(err), zap.Error(lastErr))
	}
}

var Module = fx.Module("consumer", fx.Provide(NewKafkaConsumer))
