-- Unified catalog for Cafe, Meal Plan, and Recipes channels.

create table if not exists catalog_items (
  id uuid primary key,
  kitchen_id uuid not null references kitchens(id) on delete cascade,
  org_id uuid not null,
  name varchar(120) not null,
  description varchar(500),
  meal_category varchar(16) not null,
  price_cents int not null,
  original_price_cents int,
  veg boolean not null default true,
  available boolean not null default true,
  status varchar(16) not null default 'DRAFT',
  channel_cafe boolean not null default false,
  channel_meal_plan boolean not null default false,
  channel_recipe boolean not null default false,
  emoji varchar(8) not null default '🍽️',
  image_url varchar(512),
  portion varchar(64) default '350g',
  prep_time_mins int not null default 15,
  calories int not null default 0,
  protein int not null default 0,
  carbs int not null default 0,
  fat int not null default 0,
  kitchen_name varchar(120),
  delivery_eta varchar(32) default '15 mins',
  is_addon boolean not null default false,
  is_most_loved boolean not null default false,
  is_highly_reordered boolean not null default false,
  is_previously_bought boolean not null default false,
  is_chefs_choice boolean not null default false,
  rating numeric(3,1) not null default 4.7,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_catalog_items_kitchen on catalog_items(kitchen_id);
create index if not exists idx_catalog_items_channels on catalog_items(kitchen_id, channel_cafe, channel_meal_plan, channel_recipe);

create table if not exists cafe_sections (
  id uuid primary key,
  kitchen_id uuid not null references kitchens(id) on delete cascade,
  section_key varchar(32) not null,
  title varchar(120) not null,
  sort_order int not null default 0,
  unique (kitchen_id, section_key)
);

create table if not exists cafe_section_items (
  id uuid primary key,
  section_id uuid not null references cafe_sections(id) on delete cascade,
  catalog_item_id uuid not null references catalog_items(id) on delete cascade,
  sort_order int not null default 0,
  unique (section_id, catalog_item_id)
);

create table if not exists recipes (
  id uuid primary key,
  catalog_item_id uuid not null unique references catalog_items(id) on delete cascade,
  slot varchar(16) not null default 'Lunch',
  cook_time_mins int not null default 15,
  difficulty varchar(16) not null default 'Easy',
  fits_goal boolean not null default true,
  ingredients jsonb not null default '[]',
  steps jsonb not null default '[]'
);

create table if not exists meal_system_plans (
  id uuid primary key,
  kitchen_id uuid references kitchens(id) on delete set null,
  name varchar(120) not null,
  tagline varchar(255),
  price_per_month int not null,
  system_type varchar(16) not null,
  slots jsonb not null default '[]',
  features jsonb not null default '[]'
);
