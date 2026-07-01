package mongo

import (
	"context"
	"time"

	"github.com/healthos/notification-service/internal/config"
	"github.com/healthos/notification-service/internal/domain"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.uber.org/fx"
	"go.uber.org/zap"
)

type Client struct {
	DB *mongo.Database
}

func NewClient(lc fx.Lifecycle, cfg config.Config, logger *zap.Logger) (*Client, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	client, err := mongo.Connect(ctx, options.Client().ApplyURI(cfg.MongoURI))
	if err != nil {
		return nil, err
	}
	if err := client.Ping(ctx, nil); err != nil {
		return nil, err
	}
	db := client.Database(config.MongoDatabase(cfg.MongoURI))
	c := &Client{DB: db}
	lc.Append(fx.Hook{
		OnStop: func(ctx context.Context) error {
			return client.Disconnect(ctx)
		},
	})
	ensureIndexes(ctx, db, logger)
	return c, nil
}

func ensureIndexes(ctx context.Context, db *mongo.Database, logger *zap.Logger) {
	logs := db.Collection("notification_logs")
	_, _ = logs.Indexes().CreateOne(ctx, mongo.IndexModel{
		Keys:    bson.D{{Key: "createdAt", Value: -1}},
		Options: options.Index().SetExpireAfterSeconds(90 * 24 * 3600),
	})
	topics := db.Collection("notification_topics")
	_, _ = topics.Indexes().CreateOne(ctx, mongo.IndexModel{
		Keys:    bson.D{{Key: "topic", Value: 1}},
		Options: options.Index().SetUnique(true),
	})
	logger.Info("mongo indexes ensured")
}

type TemplateRepo struct {
	col *mongo.Collection
}

func NewTemplateRepo(c *Client) *TemplateRepo {
	return &TemplateRepo{col: c.DB.Collection("notification_templates")}
}

func (r *TemplateRepo) FindActive(tenantID, topic string, channel domain.Channel) (*domain.NotificationTemplate, error) {
	ctx := context.Background()
	filter := bson.M{"topic": topic, "channel": channel, "active": true, "tenantId": tenantID}
	var t domain.NotificationTemplate
	err := r.col.FindOne(ctx, filter).Decode(&t)
	if err == nil {
		return &t, nil
	}
	if err != mongo.ErrNoDocuments {
		return nil, err
	}
	filter = bson.M{"topic": topic, "channel": channel, "active": true, "tenantId": bson.M{"$exists": false}}
	err = r.col.FindOne(ctx, filter).Decode(&t)
	if err == mongo.ErrNoDocuments {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &t, nil
}

func (r *TemplateRepo) Save(t *domain.NotificationTemplate) error {
	ctx := context.Background()
	if t.ID == "" {
		t.ID = primitive.NewObjectID().Hex()
		_, err := r.col.InsertOne(ctx, t)
		return err
	}
	oid, err := primitive.ObjectIDFromHex(t.ID)
	if err != nil {
		return err
	}
	_, err = r.col.ReplaceOne(ctx, bson.M{"_id": oid}, t)
	return err
}

func (r *TemplateRepo) FindByID(id string) (*domain.NotificationTemplate, error) {
	oid, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return nil, err
	}
	var t domain.NotificationTemplate
	err = r.col.FindOne(context.Background(), bson.M{"_id": oid}).Decode(&t)
	if err == mongo.ErrNoDocuments {
		return nil, errNotFound("template")
	}
	return &t, err
}

func (r *TemplateRepo) ListAll() ([]domain.NotificationTemplate, error) {
	cur, err := r.col.Find(context.Background(), bson.M{})
	if err != nil {
		return nil, err
	}
	defer cur.Close(context.Background())
	var out []domain.NotificationTemplate
	for cur.Next(context.Background()) {
		var t domain.NotificationTemplate
		if err := cur.Decode(&t); err != nil {
			return nil, err
		}
		out = append(out, t)
	}
	return out, cur.Err()
}

func (r *TemplateRepo) Delete(id string) error {
	oid, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return err
	}
	_, err = r.col.DeleteOne(context.Background(), bson.M{"_id": oid})
	return err
}

type ProviderConfigRepo struct {
	col *mongo.Collection
}

func NewProviderConfigRepo(c *Client) *ProviderConfigRepo {
	return &ProviderConfigRepo{col: c.DB.Collection("notification_provider_configs")}
}

func (r *ProviderConfigRepo) FindActive(tenantID string, providerType domain.ProviderType) (*domain.ProviderConfig, error) {
	ctx := context.Background()
	filter := bson.M{"providerType": providerType, "active": true, "tenantId": tenantID}
	var pc domain.ProviderConfig
	err := r.col.FindOne(ctx, filter).Decode(&pc)
	if err == nil {
		return &pc, nil
	}
	if err != mongo.ErrNoDocuments {
		return nil, err
	}
	filter = bson.M{"providerType": providerType, "active": true, "tenantId": bson.M{"$exists": false}}
	err = r.col.FindOne(ctx, filter).Decode(&pc)
	if err == mongo.ErrNoDocuments {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &pc, nil
}

func (r *ProviderConfigRepo) Save(pc *domain.ProviderConfig) error {
	ctx := context.Background()
	if pc.ID == "" {
		pc.ID = primitive.NewObjectID().Hex()
		_, err := r.col.InsertOne(ctx, pc)
		return err
	}
	oid, err := primitive.ObjectIDFromHex(pc.ID)
	if err != nil {
		return err
	}
	_, err = r.col.ReplaceOne(ctx, bson.M{"_id": oid}, pc)
	return err
}

func (r *ProviderConfigRepo) FindByID(id string) (*domain.ProviderConfig, error) {
	oid, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return nil, err
	}
	var pc domain.ProviderConfig
	err = r.col.FindOne(context.Background(), bson.M{"_id": oid}).Decode(&pc)
	if err == mongo.ErrNoDocuments {
		return nil, errNotFound("provider config")
	}
	return &pc, err
}

func (r *ProviderConfigRepo) ListAll() ([]domain.ProviderConfig, error) {
	cur, err := r.col.Find(context.Background(), bson.M{})
	if err != nil {
		return nil, err
	}
	defer cur.Close(context.Background())
	var out []domain.ProviderConfig
	for cur.Next(context.Background()) {
		var pc domain.ProviderConfig
		if err := cur.Decode(&pc); err != nil {
			return nil, err
		}
		out = append(out, pc)
	}
	return out, cur.Err()
}

type TopicRepo struct {
	col *mongo.Collection
}

func NewTopicRepo(c *Client) *TopicRepo {
	return &TopicRepo{col: c.DB.Collection("notification_topics")}
}

func (r *TopicRepo) FindByTopic(topic string) (*domain.NotificationTopic, error) {
	var t domain.NotificationTopic
	err := r.col.FindOne(context.Background(), bson.M{"topic": topic}).Decode(&t)
	if err == mongo.ErrNoDocuments {
		return nil, nil
	}
	return &t, err
}

func (r *TopicRepo) Save(t *domain.NotificationTopic) error {
	if t.ID == "" {
		t.ID = primitive.NewObjectID().Hex()
		_, err := r.col.InsertOne(context.Background(), t)
		return err
	}
	oid, err := primitive.ObjectIDFromHex(t.ID)
	if err != nil {
		return err
	}
	_, err = r.col.ReplaceOne(context.Background(), bson.M{"_id": oid}, t)
	return err
}

func (r *TopicRepo) ListAll() ([]domain.NotificationTopic, error) {
	cur, err := r.col.Find(context.Background(), bson.M{})
	if err != nil {
		return nil, err
	}
	defer cur.Close(context.Background())
	var out []domain.NotificationTopic
	for cur.Next(context.Background()) {
		var t domain.NotificationTopic
		if err := cur.Decode(&t); err != nil {
			return nil, err
		}
		out = append(out, t)
	}
	return out, cur.Err()
}

type LogRepo struct {
	col *mongo.Collection
}

func NewLogRepo(c *Client) *LogRepo {
	return &LogRepo{col: c.DB.Collection("notification_logs")}
}

func (r *LogRepo) Save(log *domain.NotificationLog) error {
	if log.ID == "" {
		log.ID = primitive.NewObjectID().Hex()
		_, err := r.col.InsertOne(context.Background(), log)
		return err
	}
	oid, err := primitive.ObjectIDFromHex(log.ID)
	if err != nil {
		return err
	}
	_, err = r.col.ReplaceOne(context.Background(), bson.M{"_id": oid}, log)
	return err
}

func (r *LogRepo) FindByID(id string) (*domain.NotificationLog, error) {
	oid, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return nil, err
	}
	var log domain.NotificationLog
	err = r.col.FindOne(context.Background(), bson.M{"_id": oid}).Decode(&log)
	if err == mongo.ErrNoDocuments {
		return nil, errNotFound("log")
	}
	return &log, err
}

func (r *LogRepo) ListAll() ([]domain.NotificationLog, error) {
	opts := options.Find().SetSort(bson.D{{Key: "createdAt", Value: -1}})
	cur, err := r.col.Find(context.Background(), bson.M{}, opts)
	if err != nil {
		return nil, err
	}
	defer cur.Close(context.Background())
	var out []domain.NotificationLog
	for cur.Next(context.Background()) {
		var log domain.NotificationLog
		if err := cur.Decode(&log); err != nil {
			return nil, err
		}
		out = append(out, log)
	}
	return out, cur.Err()
}

type notFoundError struct{ what string }

func errNotFound(what string) error { return notFoundError{what: what} }
func (e notFoundError) Error() string {
	return e.what + " not found"
}

var Module = fx.Module("mongo",
	fx.Provide(NewClient),
	fx.Provide(NewTemplateRepo, NewProviderConfigRepo, NewTopicRepo, NewLogRepo),
)
