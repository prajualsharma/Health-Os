package service

import (
	"fmt"
	"math/rand"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/healthos/kitchen-service/internal/domain"
	"github.com/healthos/kitchen-service/internal/gateway"
)

type NotFoundError struct {
	Message string
}

func (e NotFoundError) Error() string { return e.Message }

type KitchenService struct {
	repo   domain.KitchenRepository
	users  *gateway.UserManagementClient
}

func NewKitchenService(repo domain.KitchenRepository, users *gateway.UserManagementClient) *KitchenService {
	return &KitchenService{repo: repo, users: users}
}

func (s *KitchenService) List(orgID string) ([]domain.Kitchen, error) {
	if orgID != "" {
		return s.repo.ListByOrg(orgID)
	}
	return s.repo.ListAll()
}

func (s *KitchenService) Get(id string) (domain.Kitchen, error) {
	k, err := s.repo.GetByID(id)
	if err != nil {
		if strings.Contains(err.Error(), "not found") {
			return domain.Kitchen{}, NotFoundError{Message: err.Error()}
		}
		return domain.Kitchen{}, err
	}
	return k, nil
}

func (s *KitchenService) Create(orgID, name, address, city, staffUserID string) (domain.Kitchen, error) {
	if orgID == "" {
		orgID = uuid.NewString()
	}
	k := domain.Kitchen{
		ID:        uuid.NewString(),
		OrgID:     orgID,
		Name:      name,
		Address:   address,
		City:      city,
		Status:    domain.KitchenStatusActive,
		CreatedAt: time.Now().UTC(),
	}
	saved, err := s.repo.Create(k)
	if err != nil {
		return domain.Kitchen{}, err
	}
	if staffUserID != "" {
		s.users.GrantKitchenStaff(staffUserID, saved.ID)
	}
	return saved, nil
}

type MenuService struct {
	repo domain.MenuRepository
}

func NewMenuService(repo domain.MenuRepository) *MenuService {
	return &MenuService{repo: repo}
}

func (s *MenuService) ListForKitchen(kitchenID string) ([]domain.MenuItem, error) {
	return s.repo.ListByKitchen(kitchenID)
}

func (s *MenuService) Create(kitchenID string, req CreateMenuItemInput) (domain.MenuItem, error) {
	available := true
	if req.Available != nil {
		available = *req.Available
	}
	item := domain.MenuItem{
		ID:          uuid.NewString(),
		KitchenID:   kitchenID,
		Name:        req.Name,
		Description: req.Description,
		Category:    req.Category,
		PriceCents:  req.PriceCents,
		Veg:         req.Veg,
		Available:   available,
		CreatedAt:   time.Now().UTC(),
	}
	return s.repo.Create(item)
}

func (s *MenuService) Update(itemID string, req UpdateMenuItemInput) (domain.MenuItem, error) {
	item, err := s.repo.GetByID(itemID)
	if err != nil {
		if strings.Contains(err.Error(), "not found") {
			return domain.MenuItem{}, NotFoundError{Message: err.Error()}
		}
		return domain.MenuItem{}, err
	}
	if req.Name != nil {
		item.Name = *req.Name
	}
	if req.Description != nil {
		item.Description = *req.Description
	}
	if req.Category != nil {
		item.Category = *req.Category
	}
	if req.PriceCents != nil {
		item.PriceCents = *req.PriceCents
	}
	if req.Veg != nil {
		item.Veg = *req.Veg
	}
	if req.Available != nil {
		item.Available = *req.Available
	}
	return s.repo.Update(item)
}

type CreateMenuItemInput struct {
	Name        string
	Description string
	Category    domain.MealCategory
	PriceCents  int
	Veg         bool
	Available   *bool
}

type UpdateMenuItemInput struct {
	Name        *string
	Description *string
	Category    *domain.MealCategory
	PriceCents  *int
	Veg         *bool
	Available   *bool
}

type OrderService struct {
	repo domain.OrderRepository
}

func NewOrderService(repo domain.OrderRepository) *OrderService {
	return &OrderService{repo: repo}
}

func (s *OrderService) ListForKitchen(kitchenID string, activeOnly bool) ([]domain.FoodOrder, error) {
	return s.repo.ListByKitchen(kitchenID, activeOnly)
}

func (s *OrderService) Create(kitchenID string, req CreateOrderInput) (domain.FoodOrder, error) {
	now := time.Now().UTC()
	order := domain.FoodOrder{
		ID:            uuid.NewString(),
		KitchenID:     kitchenID,
		OrderCode:     generateOrderCode(),
		CustomerName:  req.CustomerName,
		CustomerPhone: req.CustomerPhone,
		Status:        domain.OrderStatusNew,
		CreatedAt:     now,
		UpdatedAt:     now,
	}
	total := 0
	for _, line := range req.Items {
		var menuItemID *string
		if line.MenuItemID != "" {
			menuItemID = &line.MenuItemID
		}
		order.Items = append(order.Items, domain.OrderLine{
			ID:         uuid.NewString(),
			MenuItemID: menuItemID,
			Name:       line.Name,
			Quantity:   line.Quantity,
			PriceCents: line.PriceCents,
			CreatedAt:  now,
		})
		total += line.PriceCents * line.Quantity
	}
	order.TotalCents = total
	return s.repo.Create(order)
}

func (s *OrderService) UpdateStatus(orderID string, next domain.OrderStatus) (domain.FoodOrder, error) {
	order, err := s.repo.GetByID(orderID)
	if err != nil {
		if strings.Contains(err.Error(), "not found") {
			return domain.FoodOrder{}, NotFoundError{Message: err.Error()}
		}
		return domain.FoodOrder{}, err
	}
	if order.Status == next {
		return order, nil
	}
	if !order.Status.CanTransitionTo(next) {
		return domain.FoodOrder{}, fmt.Errorf("cannot transition order from %s to %s", order.Status, next)
	}
	order.Status = next
	order.UpdatedAt = time.Now().UTC()
	return s.repo.Update(order)
}

type CreateOrderInput struct {
	CustomerName  string
	CustomerPhone string
	Items         []OrderLineInput
}

type OrderLineInput struct {
	MenuItemID string
	Name       string
	Quantity   int
	PriceCents int
}

func generateOrderCode() string {
	return fmt.Sprintf("ORD-%05d", rand.Intn(100000))
}
