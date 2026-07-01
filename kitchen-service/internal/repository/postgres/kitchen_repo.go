package postgres

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/healthos/kitchen-service/internal/domain"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type KitchenRepo struct {
	pool *pgxpool.Pool
}

func NewKitchenRepo(pool *pgxpool.Pool) *KitchenRepo {
	return &KitchenRepo{pool: pool}
}

func (r *KitchenRepo) ListByOrg(orgID string) ([]domain.Kitchen, error) {
	rows, err := r.pool.Query(context.Background(), `
		SELECT id, org_id, name, address, city, status, created_at
		FROM kitchens WHERE org_id = $1 ORDER BY created_at DESC`, orgID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanKitchens(rows)
}

func (r *KitchenRepo) ListAll() ([]domain.Kitchen, error) {
	rows, err := r.pool.Query(context.Background(), `
		SELECT id, org_id, name, address, city, status, created_at
		FROM kitchens ORDER BY created_at DESC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanKitchens(rows)
}

func (r *KitchenRepo) GetByID(id string) (domain.Kitchen, error) {
	row := r.pool.QueryRow(context.Background(), `
		SELECT id, org_id, name, address, city, status, created_at
		FROM kitchens WHERE id = $1`, id)
	k, err := scanKitchen(row)
	if err == pgx.ErrNoRows {
		return domain.Kitchen{}, fmt.Errorf("kitchen not found: %s", id)
	}
	return k, err
}

func (r *KitchenRepo) Create(k domain.Kitchen) (domain.Kitchen, error) {
	if k.ID == "" {
		k.ID = uuid.NewString()
	}
	if k.CreatedAt.IsZero() {
		k.CreatedAt = time.Now().UTC()
	}
	_, err := r.pool.Exec(context.Background(), `
		INSERT INTO kitchens (id, org_id, name, address, city, status, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)`,
		k.ID, k.OrgID, k.Name, k.Address, k.City, string(k.Status), k.CreatedAt)
	return k, err
}

func scanKitchens(rows pgx.Rows) ([]domain.Kitchen, error) {
	var out []domain.Kitchen
	for rows.Next() {
		k, err := scanKitchen(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, k)
	}
	return out, rows.Err()
}

func scanKitchen(row pgx.Row) (domain.Kitchen, error) {
	var k domain.Kitchen
	var address, city *string
	err := row.Scan(&k.ID, &k.OrgID, &k.Name, &address, &city, &k.Status, &k.CreatedAt)
	if address != nil {
		k.Address = *address
	}
	if city != nil {
		k.City = *city
	}
	return k, err
}
