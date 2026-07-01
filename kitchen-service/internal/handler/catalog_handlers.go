package handler

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/healthos/kitchen-service/internal/domain"
	"github.com/healthos/kitchen-service/internal/handler/middleware"
	"github.com/healthos/kitchen-service/internal/service"
	"github.com/healthos/pkg/healthos/httpx"
)

const defaultKitchenID = "a0000000-0000-0000-0000-000000000001"

type CatalogHandler struct {
	svc *service.CatalogService
}

func NewCatalogHandler(svc *service.CatalogService) *CatalogHandler {
	return &CatalogHandler{svc: svc}
}

func (h *CatalogHandler) AdminRoutes() chi.Router {
	r := chi.NewRouter()
	r.Get("/kitchens/{kitchenId}/items", h.adminList)
	r.Post("/kitchens/{kitchenId}/items", h.adminCreate)
	r.Get("/items/{itemId}", h.adminGet)
	r.Patch("/items/{itemId}", h.adminUpdate)
	r.Delete("/items/{itemId}", h.adminDelete)
	r.Patch("/items/{itemId}/available", h.adminSetAvailable)
	r.Get("/kitchens/{kitchenId}/sections", h.adminListSections)
	r.Put("/sections/{sectionId}/items", h.adminSetSectionItems)
	r.Put("/items/{itemId}/recipe", h.adminUpsertRecipe)
	return r
}

func (h *CatalogHandler) ConsumerRoutes() chi.Router {
	r := chi.NewRouter()
	r.Get("/cafe/menu", h.cafeMenu)
	r.Get("/cafe/sections", h.cafeSections)
	r.Get("/meal-systems", h.mealSystems)
	r.Get("/meal-plan/tomorrow", h.tomorrowOptions)
	r.Get("/recipes", h.recipes)
	return r
}

func (h *CatalogHandler) adminList(w http.ResponseWriter, r *http.Request) {
	kitchenID := chi.URLParam(r, "kitchenId")
	channel := r.URL.Query().Get("channel")
	filters := domain.CatalogFilters{}
	switch strings.ToUpper(channel) {
	case "CAFE":
		v := true
		filters.ChannelCafe = &v
	case "MEAL_PLAN":
		v := true
		filters.ChannelMealPlan = &v
	case "RECIPE":
		v := true
		filters.ChannelRecipe = &v
	}
	if status := r.URL.Query().Get("status"); status != "" {
		s := domain.CatalogStatus(strings.ToUpper(status))
		filters.Status = &s
	}
	items, err := h.svc.ListAdmin(kitchenID, filters)
	if err != nil {
		httpx.WriteSpringError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, mapCatalogItemsAdmin(items))
}

func (h *CatalogHandler) adminGet(w http.ResponseWriter, r *http.Request) {
	item, err := h.svc.Get(chi.URLParam(r, "itemId"))
	if err != nil {
		writeServiceError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, mapCatalogItemAdmin(item))
}

func (h *CatalogHandler) adminCreate(w http.ResponseWriter, r *http.Request) {
	var req catalogItemRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpx.WriteSpringError(w, http.StatusBadRequest, "invalid json")
		return
	}
	if strings.TrimSpace(req.Name) == "" || req.PriceCents <= 0 {
		httpx.WriteSpringError(w, http.StatusBadRequest, "name and priceCents required")
		return
	}
	orgID := deref(req.OrgID)
	if orgID == "" {
		if p, ok := middleware.PrincipalFrom(r.Context()); ok && p.ScopeType == "ORGANIZATION" {
			orgID = p.ScopeID
		}
	}
	if orgID == "" {
		orgID = defaultKitchenID
	}
	item, err := h.svc.Create(chi.URLParam(r, "kitchenId"), orgID, req.toInput())
	if err != nil {
		writeServiceError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, mapCatalogItemAdmin(item))
}

func (h *CatalogHandler) adminUpdate(w http.ResponseWriter, r *http.Request) {
	var req catalogItemRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpx.WriteSpringError(w, http.StatusBadRequest, "invalid json")
		return
	}
	item, err := h.svc.Update(chi.URLParam(r, "itemId"), req.toInput())
	if err != nil {
		writeServiceError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, mapCatalogItemAdmin(item))
}

func (h *CatalogHandler) adminDelete(w http.ResponseWriter, r *http.Request) {
	if err := h.svc.Delete(chi.URLParam(r, "itemId")); err != nil {
		httpx.WriteSpringError(w, http.StatusInternalServerError, err.Error())
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *CatalogHandler) adminSetAvailable(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Available bool `json:"available"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpx.WriteSpringError(w, http.StatusBadRequest, "invalid json")
		return
	}
	item, err := h.svc.SetAvailability(chi.URLParam(r, "itemId"), req.Available)
	if err != nil {
		writeServiceError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, mapCatalogItemAdmin(item))
}

func (h *CatalogHandler) adminListSections(w http.ResponseWriter, r *http.Request) {
	sections, err := h.svc.ListSections(chi.URLParam(r, "kitchenId"))
	if err != nil {
		httpx.WriteSpringError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, mapSectionsAdmin(sections))
}

func (h *CatalogHandler) adminSetSectionItems(w http.ResponseWriter, r *http.Request) {
	var req struct {
		ItemIDs []string `json:"itemIds"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpx.WriteSpringError(w, http.StatusBadRequest, "invalid json")
		return
	}
	if err := h.svc.SetSectionItems(chi.URLParam(r, "sectionId"), req.ItemIDs); err != nil {
		httpx.WriteSpringError(w, http.StatusInternalServerError, err.Error())
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *CatalogHandler) adminUpsertRecipe(w http.ResponseWriter, r *http.Request) {
	var req recipeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		httpx.WriteSpringError(w, http.StatusBadRequest, "invalid json")
		return
	}
	recipe := domain.RecipeDetail{
		CatalogItemID: chi.URLParam(r, "itemId"),
		Slot:          derefStrDefault(&req.Slot, "Lunch"),
		CookTimeMins:  intOr(req.CookTimeMins, 15),
		Difficulty:    derefStrDefault(req.Difficulty, "Easy"),
		FitsGoal:      boolOr(req.FitsGoal, true),
		Ingredients:   req.Ingredients,
		Steps:         req.Steps,
	}
	saved, err := h.svc.UpsertRecipe(recipe)
	if err != nil {
		httpx.WriteSpringError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, mapRecipe(saved))
}

func (h *CatalogHandler) cafeMenu(w http.ResponseWriter, r *http.Request) {
	kitchenID := kitchenIDFromQuery(r)
	addOnsOnly := r.URL.Query().Get("addOnsOnly") == "true"
	items, err := h.svc.CafeMenu(kitchenID, addOnsOnly)
	if err != nil {
		httpx.WriteSpringError(w, http.StatusInternalServerError, err.Error())
		return
	}
	out := make([]dishResponse, len(items))
	for i, item := range items {
		out[i] = mapDish(item)
	}
	writeJSON(w, http.StatusOK, out)
}

func (h *CatalogHandler) cafeSections(w http.ResponseWriter, r *http.Request) {
	kitchenID := kitchenIDFromQuery(r)
	sections, err := h.svc.CafeSections(kitchenID)
	if err != nil {
		httpx.WriteSpringError(w, http.StatusInternalServerError, err.Error())
		return
	}
	menu, _ := h.svc.CafeMenu(kitchenID, true)
	writeJSON(w, http.StatusOK, mapCafeSections(sections, menu))
}

func (h *CatalogHandler) mealSystems(w http.ResponseWriter, r *http.Request) {
	kitchenID := kitchenIDFromQuery(r)
	plans, err := h.svc.MealSystems(kitchenID)
	if err != nil {
		httpx.WriteSpringError(w, http.StatusInternalServerError, err.Error())
		return
	}
	out := make([]mealSystemResponse, len(plans))
	for i, p := range plans {
		out[i] = mealSystemResponse{
			ID: p.ID, Name: p.Name, Tagline: p.Tagline,
			PricePerMonth: p.PricePerMonth, SystemType: p.SystemType,
			Slots: p.Slots, Features: p.Features,
		}
	}
	writeJSON(w, http.StatusOK, out)
}

func (h *CatalogHandler) tomorrowOptions(w http.ResponseWriter, r *http.Request) {
	kitchenID := kitchenIDFromQuery(r)
	slotsParam := r.URL.Query().Get("slots")
	var slots []string
	for _, s := range strings.Split(slotsParam, ",") {
		if t := strings.TrimSpace(s); t != "" {
			slots = append(slots, t)
		}
	}
	if len(slots) == 0 {
		slots = []string{"Breakfast", "Lunch", "Dinner"}
	}
	options, err := h.svc.TomorrowOptions(kitchenID, slots)
	if err != nil {
		httpx.WriteSpringError(w, http.StatusInternalServerError, err.Error())
		return
	}
	out := make(map[string][]dishResponse)
	for slot, items := range options {
		dishes := make([]dishResponse, len(items))
		for i, item := range items {
			dishes[i] = mapDish(item)
		}
		out[slot] = dishes
	}
	writeJSON(w, http.StatusOK, out)
}

func (h *CatalogHandler) recipes(w http.ResponseWriter, r *http.Request) {
	kitchenID := kitchenIDFromQuery(r)
	calories := queryInt(r, "calories")
	protein := queryInt(r, "protein")
	recipes, err := h.svc.Recipes(kitchenID, calories, protein)
	if err != nil {
		httpx.WriteSpringError(w, http.StatusInternalServerError, err.Error())
		return
	}
	out := make([]recipeResponse, len(recipes))
	for i, rec := range recipes {
		out[i] = mapRecipe(rec)
	}
	writeJSON(w, http.StatusOK, out)
}

func kitchenIDFromQuery(r *http.Request) string {
	if id := r.URL.Query().Get("kitchenId"); id != "" {
		return id
	}
	return defaultKitchenID
}

func queryInt(r *http.Request, key string) int {
	v := r.URL.Query().Get(key)
	if v == "" {
		return 0
	}
	var n int
	_, _ = fmt.Sscanf(v, "%d", &n)
	return n
}

type catalogItemRequest struct {
	Name               string  `json:"name"`
	Description        *string `json:"description"`
	MealCategory       string  `json:"mealCategory"`
	PriceCents         int     `json:"priceCents"`
	OriginalPriceCents *int    `json:"originalPriceCents"`
	Veg                *bool   `json:"veg"`
	Available          *bool   `json:"available"`
	Status             *string `json:"status"`
	ChannelCafe        *bool   `json:"channelCafe"`
	ChannelMealPlan    *bool   `json:"channelMealPlan"`
	ChannelRecipe      *bool   `json:"channelRecipe"`
	OrgID              *string `json:"orgId"`
	Emoji              *string `json:"emoji"`
	ImageURL           *string `json:"imageUrl"`
	Portion            *string `json:"portion"`
	PrepTimeMins       *int    `json:"prepTimeMins"`
	Calories           *int    `json:"calories"`
	Protein            *int    `json:"protein"`
	Carbs              *int    `json:"carbs"`
	Fat                *int    `json:"fat"`
	KitchenName        *string `json:"kitchenName"`
	DeliveryEta        *string `json:"deliveryEta"`
	IsAddOn            *bool   `json:"isAddOn"`
	IsMostLoved        *bool   `json:"isMostLoved"`
	IsHighlyReordered  *bool   `json:"isHighlyReordered"`
	IsPreviouslyBought *bool   `json:"isPreviouslyBought"`
	IsChefsChoice      *bool   `json:"isChefsChoice"`
	Rating             *float64 `json:"rating"`
}

func (req catalogItemRequest) toInput() service.CatalogItemInput {
	var status *domain.CatalogStatus
	if req.Status != nil {
		s := domain.CatalogStatus(strings.ToUpper(*req.Status))
		status = &s
	}
	return service.CatalogItemInput{
		Name: req.Name, Description: req.Description,
		MealCategory: domain.MealCategory(strings.ToUpper(req.MealCategory)),
		PriceCents: req.PriceCents, OriginalPriceCents: req.OriginalPriceCents,
		Veg: req.Veg, Available: req.Available, Status: status,
		ChannelCafe: req.ChannelCafe, ChannelMealPlan: req.ChannelMealPlan, ChannelRecipe: req.ChannelRecipe,
		Emoji: req.Emoji, ImageURL: req.ImageURL, Portion: req.Portion,
		PrepTimeMins: req.PrepTimeMins, Calories: req.Calories, Protein: req.Protein,
		Carbs: req.Carbs, Fat: req.Fat, KitchenName: req.KitchenName, DeliveryEta: req.DeliveryEta,
		IsAddOn: req.IsAddOn, IsMostLoved: req.IsMostLoved, IsHighlyReordered: req.IsHighlyReordered,
		IsPreviouslyBought: req.IsPreviouslyBought, IsChefsChoice: req.IsChefsChoice, Rating: req.Rating,
	}
}

type recipeRequest struct {
	Slot         string                      `json:"slot"`
	CookTimeMins *int                        `json:"cookTimeMins"`
	Difficulty   *string                     `json:"difficulty"`
	FitsGoal     *bool                       `json:"fitsGoal"`
	Ingredients  []domain.RecipeIngredient   `json:"ingredients"`
	Steps        []string                    `json:"steps"`
}

type dishResponse struct {
	ID                 string  `json:"id"`
	Name               string  `json:"name"`
	Emoji              string  `json:"emoji"`
	Category           string  `json:"category"`
	Calories           int     `json:"calories"`
	Protein            int     `json:"protein"`
	IsVeg              bool    `json:"isVeg"`
	Price              float64 `json:"price"`
	Portion            string  `json:"portion"`
	KitchenName        string  `json:"kitchenName"`
	Rating             float64 `json:"rating"`
	DeliveryEta        string  `json:"deliveryEta"`
	IsAddOn            bool    `json:"isAddOn"`
	Description        string  `json:"description"`
	OriginalPrice      float64 `json:"originalPrice"`
	PrepTimeMins       int     `json:"prepTimeMins"`
	ImageURL           string  `json:"imageUrl"`
	IsHighlyReordered  bool    `json:"isHighlyReordered"`
	IsMostLoved        bool    `json:"isMostLoved"`
	IsPreviouslyBought bool    `json:"isPreviouslyBought"`
	IsChefsChoice      bool    `json:"isChefsChoice"`
}

func mapDish(item domain.CatalogItem) dishResponse {
	orig := 0.0
	if item.OriginalPriceCents != nil {
		orig = float64(*item.OriginalPriceCents) / 100.0
	}
	kitchen := item.KitchenName
	if kitchen == "" {
		kitchen = "NutriCafe"
	}
	return dishResponse{
		ID: item.ID, Name: item.Name, Emoji: item.Emoji,
		Category: displayCategory(item.MealCategory),
		Calories: item.Calories, Protein: item.Protein, IsVeg: item.Veg,
		Price: float64(item.PriceCents) / 100.0, Portion: item.Portion,
		KitchenName: kitchen, Rating: item.Rating, DeliveryEta: item.DeliveryEta,
		IsAddOn: item.IsAddOn, Description: item.Description, OriginalPrice: orig,
		PrepTimeMins: item.PrepTimeMins, ImageURL: item.ImageURL,
		IsHighlyReordered: item.IsHighlyReordered, IsMostLoved: item.IsMostLoved,
		IsPreviouslyBought: item.IsPreviouslyBought, IsChefsChoice: item.IsChefsChoice,
	}
}

func displayCategory(c domain.MealCategory) string {
	switch c {
	case domain.MealBreakfast:
		return "Breakfast"
	case domain.MealLunch:
		return "Lunch"
	case domain.MealDinner:
		return "Dinner"
	case domain.MealSnack:
		return "Snack"
	case domain.MealBeverage:
		return "Beverage"
	case domain.MealMeals:
		return "Meals"
	case domain.MealParty:
		return "Party"
	default:
		return string(c)
	}
}

type catalogItemAdminResponse struct {
	ID                 string  `json:"id"`
	KitchenID          string  `json:"kitchenId"`
	OrgID              string  `json:"orgId"`
	Name               string  `json:"name"`
	Description        string  `json:"description"`
	MealCategory       string  `json:"mealCategory"`
	PriceCents         int     `json:"priceCents"`
	OriginalPriceCents *int    `json:"originalPriceCents"`
	Veg                bool    `json:"veg"`
	Available          bool    `json:"available"`
	Status             string  `json:"status"`
	ChannelCafe        bool    `json:"channelCafe"`
	ChannelMealPlan    bool    `json:"channelMealPlan"`
	ChannelRecipe      bool    `json:"channelRecipe"`
	Emoji              string  `json:"emoji"`
	ImageURL           string  `json:"imageUrl"`
	Portion            string  `json:"portion"`
	PrepTimeMins       int     `json:"prepTimeMins"`
	Calories           int     `json:"calories"`
	Protein            int     `json:"protein"`
	Carbs              int     `json:"carbs"`
	Fat                int     `json:"fat"`
	KitchenName        string  `json:"kitchenName"`
	DeliveryEta        string  `json:"deliveryEta"`
	IsAddOn            bool    `json:"isAddOn"`
	IsMostLoved        bool    `json:"isMostLoved"`
	IsHighlyReordered  bool    `json:"isHighlyReordered"`
	IsPreviouslyBought bool    `json:"isPreviouslyBought"`
	IsChefsChoice      bool    `json:"isChefsChoice"`
	Rating             float64 `json:"rating"`
}

func mapCatalogItemAdmin(item domain.CatalogItem) catalogItemAdminResponse {
	return catalogItemAdminResponse{
		ID: item.ID, KitchenID: item.KitchenID, OrgID: item.OrgID,
		Name: item.Name, Description: item.Description,
		MealCategory: string(item.MealCategory), PriceCents: item.PriceCents,
		OriginalPriceCents: item.OriginalPriceCents, Veg: item.Veg, Available: item.Available,
		Status: string(item.Status), ChannelCafe: item.ChannelCafe,
		ChannelMealPlan: item.ChannelMealPlan, ChannelRecipe: item.ChannelRecipe,
		Emoji: item.Emoji, ImageURL: item.ImageURL, Portion: item.Portion,
		PrepTimeMins: item.PrepTimeMins, Calories: item.Calories, Protein: item.Protein,
		Carbs: item.Carbs, Fat: item.Fat, KitchenName: item.KitchenName,
		DeliveryEta: item.DeliveryEta, IsAddOn: item.IsAddOn,
		IsMostLoved: item.IsMostLoved, IsHighlyReordered: item.IsHighlyReordered,
		IsPreviouslyBought: item.IsPreviouslyBought, IsChefsChoice: item.IsChefsChoice,
		Rating: item.Rating,
	}
}

func mapCatalogItemsAdmin(items []domain.CatalogItem) []catalogItemAdminResponse {
	out := make([]catalogItemAdminResponse, len(items))
	for i, item := range items {
		out[i] = mapCatalogItemAdmin(item)
	}
	return out
}

type sectionAdminResponse struct {
	ID         string                    `json:"id"`
	SectionKey string                    `json:"sectionKey"`
	Title      string                    `json:"title"`
	SortOrder  int                       `json:"sortOrder"`
	ItemIDs    []string                  `json:"itemIds"`
	Items      []catalogItemAdminResponse `json:"items"`
}

func mapSectionsAdmin(sections []domain.CafeSection) []sectionAdminResponse {
	out := make([]sectionAdminResponse, len(sections))
	for i, s := range sections {
		ids := make([]string, len(s.Items))
		items := make([]catalogItemAdminResponse, len(s.Items))
		for j, item := range s.Items {
			ids[j] = item.ID
			items[j] = mapCatalogItemAdmin(item)
		}
		out[i] = sectionAdminResponse{
			ID: s.ID, SectionKey: s.SectionKey, Title: s.Title,
			SortOrder: s.SortOrder, ItemIDs: ids, Items: items,
		}
	}
	return out
}

type cafeCategoryResponse struct {
	Label    string `json:"label"`
	Emoji    string `json:"emoji"`
	ImageURL string `json:"imageUrl"`
}

type cafeSectionsResponse struct {
	OrderAgain  []dishResponse         `json:"orderAgain"`
	Categories  []cafeCategoryResponse `json:"categories"`
	Bestsellers []dishResponse         `json:"bestsellers"`
	LateNight   []dishResponse         `json:"lateNight"`
	PartyPacks  []dishResponse         `json:"partyPacks"`
	AllItems    []dishResponse         `json:"allItems"`
}

func mapCafeSections(sections []domain.CafeSection, allMenu []domain.CatalogItem) cafeSectionsResponse {
	resp := cafeSectionsResponse{
		Categories: defaultCafeCategories(),
		AllItems:   mapDishes(allMenu),
	}
	for _, s := range sections {
		dishes := mapDishes(s.Items)
		switch s.SectionKey {
		case "ORDER_AGAIN":
			resp.OrderAgain = dishes
		case "BESTSELLERS":
			resp.Bestsellers = dishes
		case "LATE_NIGHT":
			resp.LateNight = dishes
		case "PARTY_PACKS":
			resp.PartyPacks = dishes
		}
	}
	return resp
}

func mapDishes(items []domain.CatalogItem) []dishResponse {
	out := make([]dishResponse, len(items))
	for i, item := range items {
		out[i] = mapDish(item)
	}
	return out
}

func defaultCafeCategories() []cafeCategoryResponse {
	return []cafeCategoryResponse{
		{Label: "Coffee", Emoji: "☕"},
		{Label: "Tea & Sides", Emoji: "🍵"},
		{Label: "Snacks", Emoji: "🍟"},
		{Label: "Meals", Emoji: "🍛"},
		{Label: "Protein Rich", Emoji: "💪"},
		{Label: "Under ₹99", Emoji: "💰"},
	}
}

type mealSystemResponse struct {
	ID            string   `json:"id"`
	Name          string   `json:"name"`
	Tagline       string   `json:"tagline"`
	PricePerMonth int      `json:"pricePerMonth"`
	SystemType    string   `json:"systemType"`
	Slots         []string `json:"slots"`
	Features      []string `json:"features"`
}

type recipeResponse struct {
	ID          string                    `json:"id"`
	Name        string                    `json:"name"`
	Slot        string                    `json:"slot"`
	Emoji       string                    `json:"emoji"`
	Calories    int                       `json:"calories"`
	Protein     int                       `json:"protein"`
	Carbs       int                       `json:"carbs"`
	Fat         int                       `json:"fat"`
	FitsGoal    bool                      `json:"fitsGoal"`
	Ingredients []domain.RecipeIngredient `json:"ingredients"`
	Steps       []string                  `json:"steps"`
}

func mapRecipe(r domain.RecipeDetail) recipeResponse {
	name := r.Item.Name
	emoji := r.Item.Emoji
	if emoji == "" {
		emoji = "🍽️"
	}
	return recipeResponse{
		ID: r.CatalogItemID, Name: name, Slot: r.Slot, Emoji: emoji,
		Calories: r.Item.Calories, Protein: r.Item.Protein,
		Carbs: r.Item.Carbs, Fat: r.Item.Fat, FitsGoal: r.FitsGoal,
		Ingredients: r.Ingredients, Steps: r.Steps,
	}
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
