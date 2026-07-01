package domain

import "time"

type CatalogStatus string

const (
	CatalogDraft     CatalogStatus = "DRAFT"
	CatalogPublished CatalogStatus = "PUBLISHED"
)

type CatalogItem struct {
	ID                  string
	KitchenID           string
	OrgID               string
	Name                string
	Description         string
	MealCategory        MealCategory
	PriceCents          int
	OriginalPriceCents  *int
	Veg                 bool
	Available           bool
	Status              CatalogStatus
	ChannelCafe         bool
	ChannelMealPlan     bool
	ChannelRecipe       bool
	Emoji               string
	ImageURL            string
	Portion             string
	PrepTimeMins        int
	Calories            int
	Protein             int
	Carbs               int
	Fat                 int
	KitchenName         string
	DeliveryEta         string
	IsAddOn             bool
	IsMostLoved         bool
	IsHighlyReordered   bool
	IsPreviouslyBought  bool
	IsChefsChoice       bool
	Rating              float64
	CreatedAt           time.Time
	UpdatedAt           time.Time
}

type CafeSection struct {
	ID         string
	KitchenID  string
	SectionKey string
	Title      string
	SortOrder  int
	Items      []CatalogItem
}

type RecipeDetail struct {
	ID            string
	CatalogItemID string
	Slot          string
	CookTimeMins  int
	Difficulty    string
	FitsGoal      bool
	Ingredients   []RecipeIngredient
	Steps         []string
	Item          CatalogItem
}

type RecipeIngredient struct {
	Name  string `json:"name"`
	Grams int    `json:"grams"`
}

type MealSystemPlan struct {
	ID            string
	KitchenID     string
	Name          string
	Tagline       string
	PricePerMonth int
	SystemType    string
	Slots         []string
	Features      []string
}

type CatalogRepository interface {
	ListByKitchen(kitchenID string, filters CatalogFilters) ([]CatalogItem, error)
	GetByID(id string) (CatalogItem, error)
	Create(item CatalogItem) (CatalogItem, error)
	Update(item CatalogItem) (CatalogItem, error)
	Delete(id string) error
	ListCafeSections(kitchenID string, publishedOnly bool) ([]CafeSection, error)
	SetSectionItems(sectionID string, itemIDs []string) error
	UpsertSection(section CafeSection) (CafeSection, error)
	ListRecipes(kitchenID string, publishedOnly bool) ([]RecipeDetail, error)
	GetRecipeByCatalogID(catalogItemID string) (RecipeDetail, error)
	UpsertRecipe(recipe RecipeDetail) (RecipeDetail, error)
	ListMealSystems(kitchenID string) ([]MealSystemPlan, error)
	ListMealPlanBySlot(kitchenID, slot string, publishedOnly bool) ([]CatalogItem, error)
}

type CatalogFilters struct {
	ChannelCafe     *bool
	ChannelMealPlan *bool
	ChannelRecipe   *bool
	Status          *CatalogStatus
	PublishedOnly   bool
	AvailableOnly   bool
}
