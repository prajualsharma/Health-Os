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

type MenuRepo struct {
	pool *pgxpool.Pool
}

func NewMenuRepo(pool *pgxpool.Pool) *MenuRepo {
	return &MenuRepo{pool: pool}
}

func (r *MenuRepo) ListByKitchen(kitchenID string) ([]domain.MenuItem, error) {
	rows, err := r.pool.Query(context.Background(), `
		SELECT id, kitchen_id, name, description, category, price_cents, veg, available, created_at
		FROM menu_items WHERE kitchen_id = $1 ORDER BY category ASC, name ASC`, kitchenID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanMenuItems(rows)
}

func (r *MenuRepo) GetByID(id string) (domain.MenuItem, error) {
	row := r.pool.QueryRow(context.Background(), `
		SELECT id, kitchen_id, name, description, category, price_cents, veg, available, created_at
		FROM menu_items WHERE id = $1`, id)
	item, err := scanMenuItem(row)
	if err == pgx.ErrNoRows {
		return domain.MenuItem{}, fmt.Errorf("menu item not found: %s", id)
	}
	return item, err
}

func (r *MenuRepo) Create(item domain.MenuItem) (domain.MenuItem, error) {
	if item.ID == "" {
		item.ID = uuid.NewString()
	}
	if item.CreatedAt.IsZero() {
		item.CreatedAt = time.Now().UTC()
	}
	_, err := r.pool.Exec(context.Background(), `
		INSERT INTO menu_items (id, kitchen_id, name, description, category, price_cents, veg, available, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
		item.ID, item.KitchenID, item.Name, item.Description, string(item.Category),
		item.PriceCents, item.Veg, item.Available, item.CreatedAt)
	return item, err
}

func (r *MenuRepo) Update(item domain.MenuItem) (domain.MenuItem, error) {
	_, err := r.pool.Exec(context.Background(), `
		UPDATE menu_items SET name=$2, description=$3, category=$4, price_cents=$5, veg=$6, available=$7
		WHERE id=$1`,
		item.ID, item.Name, item.Description, string(item.Category), item.PriceCents, item.Veg, item.Available)
	return item, err
}

func scanMenuItems(rows pgx.Rows) ([]domain.MenuItem, error) {
	var out []domain.MenuItem
	for rows.Next() {
		item, err := scanMenuItem(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, item)
	}
	return out, rows.Err()
}

func scanMenuItem(row pgx.Row) (domain.MenuItem, error) {
	var item domain.MenuItem
	var desc *string
	err := row.Scan(&item.ID, &item.KitchenID, &item.Name, &desc, &item.Category,
		&item.PriceCents, &item.Veg, &item.Available, &item.CreatedAt)
	if desc != nil {
		item.Description = *desc
	}
	return item, err
}
