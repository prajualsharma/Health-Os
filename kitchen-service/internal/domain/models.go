package domain

import "time"

type KitchenStatus string

const KitchenStatusActive KitchenStatus = "ACTIVE"

type Kitchen struct {
	ID        string
	OrgID     string
	Name      string
	Address   string
	City      string
	Status    KitchenStatus
	CreatedAt time.Time
}

type MealCategory string

const (
	MealBreakfast MealCategory = "BREAKFAST"
	MealLunch     MealCategory = "LUNCH"
	MealDinner    MealCategory = "DINNER"
	MealSnack     MealCategory = "SNACK"
	MealBeverage  MealCategory = "BEVERAGE"
	MealMeals     MealCategory = "MEALS"
	MealParty     MealCategory = "PARTY"
)

type MenuItem struct {
	ID          string
	KitchenID   string
	Name        string
	Description string
	Category    MealCategory
	PriceCents  int
	Veg         bool
	Available   bool
	CreatedAt   time.Time
}

type OrderStatus string

const (
	OrderStatusNew      OrderStatus = "NEW"
	OrderStatusAccepted OrderStatus = "ACCEPTED"
	OrderStatusPreparing OrderStatus = "PREPARING"
	OrderStatusReady    OrderStatus = "READY"
	OrderStatusPickedUp OrderStatus = "PICKED_UP"
	OrderStatusCancelled OrderStatus = "CANCELLED"
)

func (s OrderStatus) CanTransitionTo(next OrderStatus) bool {
	switch s {
	case OrderStatusNew:
		return next == OrderStatusAccepted || next == OrderStatusCancelled
	case OrderStatusAccepted:
		return next == OrderStatusPreparing || next == OrderStatusCancelled
	case OrderStatusPreparing:
		return next == OrderStatusReady || next == OrderStatusCancelled
	case OrderStatusReady:
		return next == OrderStatusPickedUp
	default:
		return false
	}
}

type OrderLine struct {
	ID         string
	MenuItemID *string
	Name       string
	Quantity   int
	PriceCents int
	CreatedAt  time.Time
}

type FoodOrder struct {
	ID            string
	KitchenID     string
	OrderCode     string
	CustomerName  string
	CustomerPhone string
	Status        OrderStatus
	TotalCents    int
	Items         []OrderLine
	CreatedAt     time.Time
	UpdatedAt     time.Time
}

type KitchenRepository interface {
	ListByOrg(orgID string) ([]Kitchen, error)
	ListAll() ([]Kitchen, error)
	GetByID(id string) (Kitchen, error)
	Create(k Kitchen) (Kitchen, error)
}

type MenuRepository interface {
	ListByKitchen(kitchenID string) ([]MenuItem, error)
	GetByID(id string) (MenuItem, error)
	Create(item MenuItem) (MenuItem, error)
	Update(item MenuItem) (MenuItem, error)
}

type OrderRepository interface {
	ListByKitchen(kitchenID string, activeOnly bool) ([]FoodOrder, error)
	GetByID(id string) (FoodOrder, error)
	Create(order FoodOrder) (FoodOrder, error)
	Update(order FoodOrder) (FoodOrder, error)
}
