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

type OrderRepo struct {
	pool *pgxpool.Pool
}

func NewOrderRepo(pool *pgxpool.Pool) *OrderRepo {
	return &OrderRepo{pool: pool}
}

func (r *OrderRepo) ListByKitchen(kitchenID string, activeOnly bool) ([]domain.FoodOrder, error) {
	var rows pgx.Rows
	var err error
	if activeOnly {
		rows, err = r.pool.Query(context.Background(), `
			SELECT id, kitchen_id, order_code, customer_name, customer_phone, status, total_cents, created_at, updated_at
			FROM food_orders
			WHERE kitchen_id = $1 AND status = ANY($2)
			ORDER BY created_at ASC`,
			kitchenID, []string{"NEW", "ACCEPTED", "PREPARING", "READY"})
	} else {
		rows, err = r.pool.Query(context.Background(), `
			SELECT id, kitchen_id, order_code, customer_name, customer_phone, status, total_cents, created_at, updated_at
			FROM food_orders WHERE kitchen_id = $1 ORDER BY created_at DESC`, kitchenID)
	}
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var orders []domain.FoodOrder
	for rows.Next() {
		order, err := scanOrderHeader(rows)
		if err != nil {
			return nil, err
		}
		items, err := r.loadLines(order.ID)
		if err != nil {
			return nil, err
		}
		order.Items = items
		orders = append(orders, order)
	}
	return orders, rows.Err()
}

func (r *OrderRepo) GetByID(id string) (domain.FoodOrder, error) {
	row := r.pool.QueryRow(context.Background(), `
		SELECT id, kitchen_id, order_code, customer_name, customer_phone, status, total_cents, created_at, updated_at
		FROM food_orders WHERE id = $1`, id)
	order, err := scanOrderHeader(row)
	if err == pgx.ErrNoRows {
		return domain.FoodOrder{}, fmt.Errorf("order not found: %s", id)
	}
	if err != nil {
		return domain.FoodOrder{}, err
	}
	order.Items, err = r.loadLines(order.ID)
	return order, err
}

func (r *OrderRepo) Create(order domain.FoodOrder) (domain.FoodOrder, error) {
	ctx := context.Background()
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return domain.FoodOrder{}, err
	}
	defer tx.Rollback(ctx)

	if order.ID == "" {
		order.ID = uuid.NewString()
	}
	now := time.Now().UTC()
	if order.CreatedAt.IsZero() {
		order.CreatedAt = now
	}
	order.UpdatedAt = now

	_, err = tx.Exec(ctx, `
		INSERT INTO food_orders (id, kitchen_id, order_code, customer_name, customer_phone, status, total_cents, created_at, updated_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
		order.ID, order.KitchenID, order.OrderCode, order.CustomerName, order.CustomerPhone,
		string(order.Status), order.TotalCents, order.CreatedAt, order.UpdatedAt)
	if err != nil {
		return domain.FoodOrder{}, err
	}

	for i := range order.Items {
		line := order.Items[i]
		if line.ID == "" {
			line.ID = uuid.NewString()
		}
		if line.CreatedAt.IsZero() {
			line.CreatedAt = now
		}
		_, err = tx.Exec(ctx, `
			INSERT INTO order_lines (id, order_id, menu_item_id, name, quantity, price_cents, created_at)
			VALUES ($1,$2,$3,$4,$5,$6,$7)`,
			line.ID, order.ID, line.MenuItemID, line.Name, line.Quantity, line.PriceCents, line.CreatedAt)
		if err != nil {
			return domain.FoodOrder{}, err
		}
		order.Items[i] = line
	}

	if err := tx.Commit(ctx); err != nil {
		return domain.FoodOrder{}, err
	}
	return order, nil
}

func (r *OrderRepo) Update(order domain.FoodOrder) (domain.FoodOrder, error) {
	_, err := r.pool.Exec(context.Background(), `
		UPDATE food_orders SET status=$2, updated_at=$3 WHERE id=$1`,
		order.ID, string(order.Status), order.UpdatedAt)
	return order, err
}

func (r *OrderRepo) loadLines(orderID string) ([]domain.OrderLine, error) {
	rows, err := r.pool.Query(context.Background(), `
		SELECT id, menu_item_id, name, quantity, price_cents, created_at
		FROM order_lines WHERE order_id = $1 ORDER BY created_at ASC`, orderID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var lines []domain.OrderLine
	for rows.Next() {
		var line domain.OrderLine
		var menuItemID *string
		if err := rows.Scan(&line.ID, &menuItemID, &line.Name, &line.Quantity, &line.PriceCents, &line.CreatedAt); err != nil {
			return nil, err
		}
		line.MenuItemID = menuItemID
		lines = append(lines, line)
	}
	return lines, rows.Err()
}

func scanOrderHeader(row pgx.Row) (domain.FoodOrder, error) {
	var order domain.FoodOrder
	var phone *string
	err := row.Scan(&order.ID, &order.KitchenID, &order.OrderCode, &order.CustomerName, &phone,
		&order.Status, &order.TotalCents, &order.CreatedAt, &order.UpdatedAt)
	if phone != nil {
		order.CustomerPhone = *phone
	}
	return order, err
}
