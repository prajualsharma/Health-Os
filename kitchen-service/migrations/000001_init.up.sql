-- Cloud Kitchen schema (PostgreSQL). Shares the healthos database; tables are kitchen-owned.

create table if not exists kitchens (
  id uuid primary key,
  org_id uuid not null,
  name varchar(120) not null,
  address varchar(255),
  city varchar(80),
  status varchar(16) not null default 'ACTIVE',
  created_at timestamptz not null default now()
);
create index if not exists idx_kitchens_org on kitchens(org_id);

create table if not exists menu_items (
  id uuid primary key,
  kitchen_id uuid not null references kitchens(id) on delete cascade,
  name varchar(120) not null,
  description varchar(255),
  category varchar(16) not null,
  price_cents int not null,
  veg boolean not null default true,
  available boolean not null default true,
  created_at timestamptz not null default now()
);
create index if not exists idx_menu_items_kitchen on menu_items(kitchen_id);

create table if not exists food_orders (
  id uuid primary key,
  kitchen_id uuid not null references kitchens(id) on delete cascade,
  order_code varchar(16) not null,
  customer_name varchar(120) not null,
  customer_phone varchar(32),
  status varchar(16) not null default 'NEW',
  total_cents int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_food_orders_kitchen on food_orders(kitchen_id);
create index if not exists idx_food_orders_status on food_orders(kitchen_id, status);

create table if not exists order_lines (
  id uuid primary key,
  order_id uuid not null references food_orders(id) on delete cascade,
  menu_item_id uuid,
  name varchar(120) not null,
  quantity int not null,
  price_cents int not null,
  created_at timestamptz not null default now()
);
create index if not exists idx_order_lines_order on order_lines(order_id);
