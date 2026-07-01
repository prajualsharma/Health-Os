package postgres

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/healthos/kitchen-service/internal/domain"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type CatalogRepo struct {
	pool *pgxpool.Pool
}

func NewCatalogRepo(pool *pgxpool.Pool) *CatalogRepo {
	return &CatalogRepo{pool: pool}
}

func (r *CatalogRepo) ListByKitchen(kitchenID string, filters domain.CatalogFilters) ([]domain.CatalogItem, error) {
	q := `SELECT id, kitchen_id, org_id, name, description, meal_category, price_cents, original_price_cents,
		veg, available, status, channel_cafe, channel_meal_plan, channel_recipe, emoji, image_url, portion,
		prep_time_mins, calories, protein, carbs, fat, kitchen_name, delivery_eta, is_addon,
		is_most_loved, is_highly_reordered, is_previously_bought, is_chefs_choice, rating, created_at, updated_at
		FROM catalog_items WHERE kitchen_id = $1`
	args := []any{kitchenID}
	n := 2
	if filters.ChannelCafe != nil {
		q += fmt.Sprintf(" AND channel_cafe = $%d", n)
		args = append(args, *filters.ChannelCafe)
		n++
	}
	if filters.ChannelMealPlan != nil {
		q += fmt.Sprintf(" AND channel_meal_plan = $%d", n)
		args = append(args, *filters.ChannelMealPlan)
		n++
	}
	if filters.ChannelRecipe != nil {
		q += fmt.Sprintf(" AND channel_recipe = $%d", n)
		args = append(args, *filters.ChannelRecipe)
		n++
	}
	if filters.Status != nil {
		q += fmt.Sprintf(" AND status = $%d", n)
		args = append(args, string(*filters.Status))
		n++
	}
	if filters.PublishedOnly {
		q += " AND status = 'PUBLISHED'"
	}
	if filters.AvailableOnly {
		q += " AND available = true"
	}
	q += " ORDER BY name ASC"
	rows, err := r.pool.Query(context.Background(), q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanCatalogItems(rows)
}

func (r *CatalogRepo) GetByID(id string) (domain.CatalogItem, error) {
	row := r.pool.QueryRow(context.Background(), catalogSelectSQL+` FROM catalog_items c WHERE c.id = $1`, id)
	item, err := scanCatalogItem(row)
	if err == pgx.ErrNoRows {
		return domain.CatalogItem{}, fmt.Errorf("catalog item not found: %s", id)
	}
	return item, err
}

func (r *CatalogRepo) Create(item domain.CatalogItem) (domain.CatalogItem, error) {
	if item.ID == "" {
		item.ID = uuid.NewString()
	}
	now := time.Now().UTC()
	if item.CreatedAt.IsZero() {
		item.CreatedAt = now
	}
	item.UpdatedAt = now
	_, err := r.pool.Exec(context.Background(), catalogInsertSQL,
		item.ID, item.KitchenID, item.OrgID, item.Name, item.Description, string(item.MealCategory),
		item.PriceCents, item.OriginalPriceCents, item.Veg, item.Available, string(item.Status),
		item.ChannelCafe, item.ChannelMealPlan, item.ChannelRecipe, item.Emoji, item.ImageURL,
		item.Portion, item.PrepTimeMins, item.Calories, item.Protein, item.Carbs, item.Fat,
		item.KitchenName, item.DeliveryEta, item.IsAddOn, item.IsMostLoved, item.IsHighlyReordered,
		item.IsPreviouslyBought, item.IsChefsChoice, item.Rating, item.CreatedAt, item.UpdatedAt)
	return item, err
}

func (r *CatalogRepo) Update(item domain.CatalogItem) (domain.CatalogItem, error) {
	item.UpdatedAt = time.Now().UTC()
	_, err := r.pool.Exec(context.Background(), `
		UPDATE catalog_items SET name=$2, description=$3, meal_category=$4, price_cents=$5, original_price_cents=$6,
		veg=$7, available=$8, status=$9, channel_cafe=$10, channel_meal_plan=$11, channel_recipe=$12,
		emoji=$13, image_url=$14, portion=$15, prep_time_mins=$16, calories=$17, protein=$18, carbs=$19, fat=$20,
		kitchen_name=$21, delivery_eta=$22, is_addon=$23, is_most_loved=$24, is_highly_reordered=$25,
		is_previously_bought=$26, is_chefs_choice=$27, rating=$28, updated_at=$29 WHERE id=$1`,
		item.ID, item.Name, item.Description, string(item.MealCategory), item.PriceCents, item.OriginalPriceCents,
		item.Veg, item.Available, string(item.Status), item.ChannelCafe, item.ChannelMealPlan, item.ChannelRecipe,
		item.Emoji, item.ImageURL, item.Portion, item.PrepTimeMins, item.Calories, item.Protein, item.Carbs, item.Fat,
		item.KitchenName, item.DeliveryEta, item.IsAddOn, item.IsMostLoved, item.IsHighlyReordered,
		item.IsPreviouslyBought, item.IsChefsChoice, item.Rating, item.UpdatedAt)
	return item, err
}

func (r *CatalogRepo) Delete(id string) error {
	_, err := r.pool.Exec(context.Background(), `DELETE FROM catalog_items WHERE id = $1`, id)
	return err
}

func (r *CatalogRepo) ListCafeSections(kitchenID string, publishedOnly bool) ([]domain.CafeSection, error) {
	rows, err := r.pool.Query(context.Background(), `
		SELECT id, kitchen_id, section_key, title, sort_order FROM cafe_sections
		WHERE kitchen_id = $1 ORDER BY sort_order ASC`, kitchenID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var sections []domain.CafeSection
	for rows.Next() {
		var s domain.CafeSection
		if err := rows.Scan(&s.ID, &s.KitchenID, &s.SectionKey, &s.Title, &s.SortOrder); err != nil {
			return nil, err
		}
		sections = append(sections, s)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	for i := range sections {
		items, err := r.sectionItems(sections[i].ID, publishedOnly)
		if err != nil {
			return nil, err
		}
		sections[i].Items = items
	}
	return sections, nil
}

func (r *CatalogRepo) sectionItems(sectionID string, publishedOnly bool) ([]domain.CatalogItem, error) {
	q := catalogSelectSQL + `
		FROM catalog_items c
		INNER JOIN cafe_section_items si ON si.catalog_item_id = c.id
		WHERE si.section_id = $1`
	if publishedOnly {
		q += " AND c.status = 'PUBLISHED' AND c.available = true"
	}
	q += " ORDER BY si.sort_order ASC"
	rows, err := r.pool.Query(context.Background(), q, sectionID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanCatalogItems(rows)
}

func (r *CatalogRepo) SetSectionItems(sectionID string, itemIDs []string) error {
	tx, err := r.pool.Begin(context.Background())
	if err != nil {
		return err
	}
	defer tx.Rollback(context.Background())
	if _, err := tx.Exec(context.Background(), `DELETE FROM cafe_section_items WHERE section_id = $1`, sectionID); err != nil {
		return err
	}
	for i, itemID := range itemIDs {
		_, err := tx.Exec(context.Background(), `
			INSERT INTO cafe_section_items (id, section_id, catalog_item_id, sort_order)
			VALUES ($1, $2, $3, $4)`,
			uuid.NewString(), sectionID, itemID, i)
		if err != nil {
			return err
		}
	}
	return tx.Commit(context.Background())
}

func (r *CatalogRepo) UpsertSection(section domain.CafeSection) (domain.CafeSection, error) {
	if section.ID == "" {
		section.ID = uuid.NewString()
	}
	_, err := r.pool.Exec(context.Background(), `
		INSERT INTO cafe_sections (id, kitchen_id, section_key, title, sort_order)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (kitchen_id, section_key) DO UPDATE SET title = EXCLUDED.title, sort_order = EXCLUDED.sort_order
		RETURNING id`,
		section.ID, section.KitchenID, section.SectionKey, section.Title, section.SortOrder)
	return section, err
}

func (r *CatalogRepo) ListRecipes(kitchenID string, publishedOnly bool) ([]domain.RecipeDetail, error) {
	q := `SELECT r.id, r.catalog_item_id, r.slot, r.cook_time_mins, r.difficulty, r.fits_goal, r.ingredients, r.steps, ` +
		strings.TrimPrefix(catalogSelectSQL, "SELECT ") + `
		FROM recipes r
		INNER JOIN catalog_items c ON c.id = r.catalog_item_id
		WHERE c.kitchen_id = $1 AND c.channel_recipe = true`
	if publishedOnly {
		q += " AND c.status = 'PUBLISHED' AND c.available = true"
	}
	rows, err := r.pool.Query(context.Background(), q, kitchenID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanRecipeRows(rows)
}

func (r *CatalogRepo) GetRecipeByCatalogID(catalogItemID string) (domain.RecipeDetail, error) {
	row := r.pool.QueryRow(context.Background(),
		`SELECT r.id, r.catalog_item_id, r.slot, r.cook_time_mins, r.difficulty, r.fits_goal, r.ingredients, r.steps, `+
			strings.TrimPrefix(catalogSelectSQL, "SELECT ")+`
		FROM recipes r INNER JOIN catalog_items c ON c.id = r.catalog_item_id WHERE r.catalog_item_id = $1`, catalogItemID)
	return scanRecipeRow(row)
}

func (r *CatalogRepo) UpsertRecipe(recipe domain.RecipeDetail) (domain.RecipeDetail, error) {
	ingJSON, _ := json.Marshal(recipe.Ingredients)
	stepsJSON, _ := json.Marshal(recipe.Steps)
	if recipe.ID == "" {
		recipe.ID = uuid.NewString()
	}
	_, err := r.pool.Exec(context.Background(), `
		INSERT INTO recipes (id, catalog_item_id, slot, cook_time_mins, difficulty, fits_goal, ingredients, steps)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		ON CONFLICT (catalog_item_id) DO UPDATE SET
			slot = EXCLUDED.slot, cook_time_mins = EXCLUDED.cook_time_mins, difficulty = EXCLUDED.difficulty,
			fits_goal = EXCLUDED.fits_goal, ingredients = EXCLUDED.ingredients, steps = EXCLUDED.steps`,
		recipe.ID, recipe.CatalogItemID, recipe.Slot, recipe.CookTimeMins, recipe.Difficulty,
		recipe.FitsGoal, ingJSON, stepsJSON)
	return recipe, err
}

func (r *CatalogRepo) ListMealSystems(kitchenID string) ([]domain.MealSystemPlan, error) {
	rows, err := r.pool.Query(context.Background(), `
		SELECT id, coalesce(kitchen_id::text,''), name, coalesce(tagline,''), price_per_month, system_type, slots, features
		FROM meal_system_plans WHERE kitchen_id = $1 OR kitchen_id IS NULL`, kitchenID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.MealSystemPlan
	for rows.Next() {
		var p domain.MealSystemPlan
		var slotsJSON, featuresJSON []byte
		if err := rows.Scan(&p.ID, &p.KitchenID, &p.Name, &p.Tagline, &p.PricePerMonth, &p.SystemType, &slotsJSON, &featuresJSON); err != nil {
			return nil, err
		}
		_ = json.Unmarshal(slotsJSON, &p.Slots)
		_ = json.Unmarshal(featuresJSON, &p.Features)
		out = append(out, p)
	}
	return out, rows.Err()
}

func (r *CatalogRepo) ListMealPlanBySlot(kitchenID, slot string, publishedOnly bool) ([]domain.CatalogItem, error) {
	cafe := false
	meal := true
	filters := domain.CatalogFilters{ChannelCafe: &cafe, ChannelMealPlan: &meal, PublishedOnly: publishedOnly, AvailableOnly: publishedOnly}
	items, err := r.ListByKitchen(kitchenID, filters)
	if err != nil {
		return nil, err
	}
	slotUpper := strings.ToUpper(slot)
	var filtered []domain.CatalogItem
	for _, item := range items {
		if string(item.MealCategory) == slotUpper || strings.EqualFold(slot, string(item.MealCategory)) {
			filtered = append(filtered, item)
		}
	}
	return filtered, nil
}

const catalogSelectSQL = `SELECT c.id, c.kitchen_id, c.org_id, c.name, c.description, c.meal_category, c.price_cents, c.original_price_cents,
	c.veg, c.available, c.status, c.channel_cafe, c.channel_meal_plan, c.channel_recipe, c.emoji, c.image_url, c.portion,
	c.prep_time_mins, c.calories, c.protein, c.carbs, c.fat, c.kitchen_name, c.delivery_eta, c.is_addon,
	c.is_most_loved, c.is_highly_reordered, c.is_previously_bought, c.is_chefs_choice, c.rating, c.created_at, c.updated_at`

const catalogInsertSQL = `INSERT INTO catalog_items (
	id, kitchen_id, org_id, name, description, meal_category, price_cents, original_price_cents,
	veg, available, status, channel_cafe, channel_meal_plan, channel_recipe, emoji, image_url, portion,
	prep_time_mins, calories, protein, carbs, fat, kitchen_name, delivery_eta, is_addon,
	is_most_loved, is_highly_reordered, is_previously_bought, is_chefs_choice, rating, created_at, updated_at
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31)`

func scanCatalogItems(rows pgx.Rows) ([]domain.CatalogItem, error) {
	var out []domain.CatalogItem
	for rows.Next() {
		item, err := scanCatalogItem(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, item)
	}
	return out, rows.Err()
}

func scanCatalogItem(row pgx.Row) (domain.CatalogItem, error) {
	var item domain.CatalogItem
	var desc, img, portion, kitchenName, deliveryEta *string
	var origPrice *int
	var category, status string
	err := row.Scan(
		&item.ID, &item.KitchenID, &item.OrgID, &item.Name, &desc, &category, &item.PriceCents, &origPrice,
		&item.Veg, &item.Available, &status, &item.ChannelCafe, &item.ChannelMealPlan, &item.ChannelRecipe,
		&item.Emoji, &img, &portion, &item.PrepTimeMins, &item.Calories, &item.Protein, &item.Carbs, &item.Fat,
		&kitchenName, &deliveryEta, &item.IsAddOn, &item.IsMostLoved, &item.IsHighlyReordered,
		&item.IsPreviouslyBought, &item.IsChefsChoice, &item.Rating, &item.CreatedAt, &item.UpdatedAt)
	if err != nil {
		return item, err
	}
	if desc != nil {
		item.Description = *desc
	}
	if origPrice != nil {
		item.OriginalPriceCents = origPrice
	}
	if img != nil {
		item.ImageURL = *img
	}
	if portion != nil {
		item.Portion = *portion
	}
	if kitchenName != nil {
		item.KitchenName = *kitchenName
	}
	if deliveryEta != nil {
		item.DeliveryEta = *deliveryEta
	}
	item.MealCategory = domain.MealCategory(category)
	item.Status = domain.CatalogStatus(status)
	return item, nil
}

func scanRecipeRows(rows pgx.Rows) ([]domain.RecipeDetail, error) {
	var out []domain.RecipeDetail
	for rows.Next() {
		r, err := scanRecipeRow(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, r)
	}
	return out, rows.Err()
}

func scanRecipeRow(row pgx.Row) (domain.RecipeDetail, error) {
	var r domain.RecipeDetail
	var ingJSON, stepsJSON []byte
	item, err := scanCatalogItemFromRecipeScan(row, &r, &ingJSON, &stepsJSON)
	if err != nil {
		return r, err
	}
	r.Item = item
	_ = json.Unmarshal(ingJSON, &r.Ingredients)
	_ = json.Unmarshal(stepsJSON, &r.Steps)
	return r, nil
}

func scanCatalogItemFromRecipeScan(row pgx.Row, r *domain.RecipeDetail, ingJSON, stepsJSON *[]byte) (domain.CatalogItem, error) {
	var item domain.CatalogItem
	var desc, img, portion, kitchenName, deliveryEta *string
	var origPrice *int
	var category, status string
	err := row.Scan(
		&r.ID, &r.CatalogItemID, &r.Slot, &r.CookTimeMins, &r.Difficulty, &r.FitsGoal, ingJSON, stepsJSON,
		&item.ID, &item.KitchenID, &item.OrgID, &item.Name, &desc, &category, &item.PriceCents, &origPrice,
		&item.Veg, &item.Available, &status, &item.ChannelCafe, &item.ChannelMealPlan, &item.ChannelRecipe,
		&item.Emoji, &img, &portion, &item.PrepTimeMins, &item.Calories, &item.Protein, &item.Carbs, &item.Fat,
		&kitchenName, &deliveryEta, &item.IsAddOn, &item.IsMostLoved, &item.IsHighlyReordered,
		&item.IsPreviouslyBought, &item.IsChefsChoice, &item.Rating, &item.CreatedAt, &item.UpdatedAt)
	if err != nil {
		return item, err
	}
	if desc != nil {
		item.Description = *desc
	}
	if origPrice != nil {
		item.OriginalPriceCents = origPrice
	}
	if img != nil {
		item.ImageURL = *img
	}
	if portion != nil {
		item.Portion = *portion
	}
	if kitchenName != nil {
		item.KitchenName = *kitchenName
	}
	if deliveryEta != nil {
		item.DeliveryEta = *deliveryEta
	}
	item.MealCategory = domain.MealCategory(category)
	item.Status = domain.CatalogStatus(status)
	return item, nil
}
