package service

import (
	"strings"

	"github.com/google/uuid"
	"github.com/healthos/kitchen-service/internal/domain"
)

type CatalogService struct {
	repo domain.CatalogRepository
}

func NewCatalogService(repo domain.CatalogRepository) *CatalogService {
	return &CatalogService{repo: repo}
}

func (s *CatalogService) ListAdmin(kitchenID string, filters domain.CatalogFilters) ([]domain.CatalogItem, error) {
	return s.repo.ListByKitchen(kitchenID, filters)
}

func (s *CatalogService) Get(id string) (domain.CatalogItem, error) {
	item, err := s.repo.GetByID(id)
	if err != nil {
		if strings.Contains(err.Error(), "not found") {
			return domain.CatalogItem{}, NotFoundError{Message: err.Error()}
		}
		return domain.CatalogItem{}, err
	}
	return item, nil
}

func (s *CatalogService) Create(kitchenID, orgID string, req CatalogItemInput) (domain.CatalogItem, error) {
	status := domain.CatalogDraft
	if req.Status != nil {
		status = *req.Status
	}
	item := domain.CatalogItem{
		ID:                 uuid.NewString(),
		KitchenID:          kitchenID,
		OrgID:              orgID,
		Name:               req.Name,
		Description:        derefStr(req.Description),
		MealCategory:       req.MealCategory,
		PriceCents:         req.PriceCents,
		OriginalPriceCents: req.OriginalPriceCents,
		Veg:                req.Veg,
		Available:          boolOr(req.Available, true),
		Status:             status,
		ChannelCafe:        boolOr(req.ChannelCafe, false),
		ChannelMealPlan:    boolOr(req.ChannelMealPlan, false),
		ChannelRecipe:      boolOr(req.ChannelRecipe, false),
		Emoji:              derefStrDefault(req.Emoji, "🍽️"),
		ImageURL:           derefStr(req.ImageURL),
		Portion:            derefStrDefault(req.Portion, "350g"),
		PrepTimeMins:       intOr(req.PrepTimeMins, 15),
		Calories:           intOr(req.Calories, 0),
		Protein:            intOr(req.Protein, 0),
		Carbs:              intOr(req.Carbs, 0),
		Fat:                intOr(req.Fat, 0),
		KitchenName:        derefStr(req.KitchenName),
		DeliveryEta:        derefStrDefault(req.DeliveryEta, "15 mins"),
		IsAddOn:            boolOr(req.IsAddOn, false),
		IsMostLoved:        boolOr(req.IsMostLoved, false),
		IsHighlyReordered:  boolOr(req.IsHighlyReordered, false),
		IsPreviouslyBought: boolOr(req.IsPreviouslyBought, false),
		IsChefsChoice:      boolOr(req.IsChefsChoice, false),
		Rating:             floatOr(req.Rating, 4.7),
	}
	return s.repo.Create(item)
}

func (s *CatalogService) Update(id string, req CatalogItemInput) (domain.CatalogItem, error) {
	item, err := s.Get(id)
	if err != nil {
		return domain.CatalogItem{}, err
	}
	if req.Name != "" {
		item.Name = req.Name
	}
	if req.Description != nil {
		item.Description = *req.Description
	}
	if req.MealCategory != "" {
		item.MealCategory = req.MealCategory
	}
	if req.PriceCents > 0 {
		item.PriceCents = req.PriceCents
	}
	if req.OriginalPriceCents != nil {
		item.OriginalPriceCents = req.OriginalPriceCents
	}
	if req.Veg != nil {
		item.Veg = *req.Veg
	}
	if req.Available != nil {
		item.Available = *req.Available
	}
	if req.Status != nil {
		item.Status = *req.Status
	}
	if req.ChannelCafe != nil {
		item.ChannelCafe = *req.ChannelCafe
	}
	if req.ChannelMealPlan != nil {
		item.ChannelMealPlan = *req.ChannelMealPlan
	}
	if req.ChannelRecipe != nil {
		item.ChannelRecipe = *req.ChannelRecipe
	}
	if req.Emoji != nil {
		item.Emoji = *req.Emoji
	}
	if req.ImageURL != nil {
		item.ImageURL = *req.ImageURL
	}
	if req.Portion != nil {
		item.Portion = *req.Portion
	}
	if req.PrepTimeMins != nil {
		item.PrepTimeMins = *req.PrepTimeMins
	}
	if req.Calories != nil {
		item.Calories = *req.Calories
	}
	if req.Protein != nil {
		item.Protein = *req.Protein
	}
	if req.Carbs != nil {
		item.Carbs = *req.Carbs
	}
	if req.Fat != nil {
		item.Fat = *req.Fat
	}
	if req.KitchenName != nil {
		item.KitchenName = *req.KitchenName
	}
	if req.DeliveryEta != nil {
		item.DeliveryEta = *req.DeliveryEta
	}
	if req.IsAddOn != nil {
		item.IsAddOn = *req.IsAddOn
	}
	if req.IsMostLoved != nil {
		item.IsMostLoved = *req.IsMostLoved
	}
	if req.IsHighlyReordered != nil {
		item.IsHighlyReordered = *req.IsHighlyReordered
	}
	if req.IsPreviouslyBought != nil {
		item.IsPreviouslyBought = *req.IsPreviouslyBought
	}
	if req.IsChefsChoice != nil {
		item.IsChefsChoice = *req.IsChefsChoice
	}
	if req.Rating != nil {
		item.Rating = *req.Rating
	}
	return s.repo.Update(item)
}

func (s *CatalogService) Delete(id string) error {
	return s.repo.Delete(id)
}

func (s *CatalogService) SetAvailability(id string, available bool) (domain.CatalogItem, error) {
	item, err := s.Get(id)
	if err != nil {
		return domain.CatalogItem{}, err
	}
	item.Available = available
	return s.repo.Update(item)
}

func (s *CatalogService) CafeMenu(kitchenID string, addOnsOnly bool) ([]domain.CatalogItem, error) {
	cafe := true
	filters := domain.CatalogFilters{
		ChannelCafe:   &cafe,
		PublishedOnly: true,
		AvailableOnly: true,
	}
	items, err := s.repo.ListByKitchen(kitchenID, filters)
	if err != nil {
		return nil, err
	}
	if addOnsOnly {
		var filtered []domain.CatalogItem
		for _, item := range items {
			if item.IsAddOn {
				filtered = append(filtered, item)
			}
		}
		return filtered, nil
	}
	return items, nil
}

func (s *CatalogService) CafeSections(kitchenID string) ([]domain.CafeSection, error) {
	return s.repo.ListCafeSections(kitchenID, true)
}

func (s *CatalogService) SetSectionItems(sectionID string, itemIDs []string) error {
	return s.repo.SetSectionItems(sectionID, itemIDs)
}

func (s *CatalogService) ListSections(kitchenID string) ([]domain.CafeSection, error) {
	return s.repo.ListCafeSections(kitchenID, false)
}

func (s *CatalogService) MealSystems(kitchenID string) ([]domain.MealSystemPlan, error) {
	return s.repo.ListMealSystems(kitchenID)
}

func (s *CatalogService) TomorrowOptions(kitchenID string, slots []string) (map[string][]domain.CatalogItem, error) {
	out := make(map[string][]domain.CatalogItem)
	for _, slot := range slots {
		items, err := s.repo.ListMealPlanBySlot(kitchenID, slot, true)
		if err != nil {
			return nil, err
		}
		out[slot] = items
	}
	return out, nil
}

func (s *CatalogService) Recipes(kitchenID string, calorieTarget, proteinTarget int) ([]domain.RecipeDetail, error) {
	recipes, err := s.repo.ListRecipes(kitchenID, true)
	if err != nil {
		return nil, err
	}
	if calorieTarget <= 0 && proteinTarget <= 0 {
		return recipes, nil
	}
	var filtered []domain.RecipeDetail
	for _, r := range recipes {
		if calorieTarget > 0 && r.Item.Calories > calorieTarget+100 {
			continue
		}
		if proteinTarget > 0 && r.Item.Protein < proteinTarget-10 {
			continue
		}
		filtered = append(filtered, r)
	}
	return filtered, nil
}

func (s *CatalogService) UpsertRecipe(recipe domain.RecipeDetail) (domain.RecipeDetail, error) {
	return s.repo.UpsertRecipe(recipe)
}

type CatalogItemInput struct {
	Name               string
	Description        *string
	MealCategory       domain.MealCategory
	PriceCents         int
	OriginalPriceCents *int
	Veg                *bool
	Available          *bool
	Status             *domain.CatalogStatus
	ChannelCafe        *bool
	ChannelMealPlan    *bool
	ChannelRecipe      *bool
	Emoji              *string
	ImageURL           *string
	Portion            *string
	PrepTimeMins       *int
	Calories           *int
	Protein            *int
	Carbs              *int
	Fat                *int
	KitchenName        *string
	DeliveryEta        *string
	IsAddOn            *bool
	IsMostLoved        *bool
	IsHighlyReordered  *bool
	IsPreviouslyBought *bool
	IsChefsChoice      *bool
	Rating             *float64
}

func derefStr(v *string) string {
	if v == nil {
		return ""
	}
	return *v
}

func derefStrDefault(v *string, def string) string {
	if v == nil || *v == "" {
		return def
	}
	return *v
}

func boolOr(v *bool, def bool) bool {
	if v == nil {
		return def
	}
	return *v
}

func intOr(v *int, def int) int {
	if v == nil {
		return def
	}
	return *v
}

func floatOr(v *float64, def float64) float64 {
	if v == nil {
		return def
	}
	return *v
}
