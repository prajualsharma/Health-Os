-- Seed catalog items for demo kitchen (NutriCafe + meal plan + recipes).

insert into catalog_items (
  id, kitchen_id, org_id, name, description, meal_category, price_cents, original_price_cents,
  veg, available, status, channel_cafe, channel_meal_plan, channel_recipe,
  emoji, image_url, portion, prep_time_mins, calories, protein, kitchen_name,
  is_addon, is_most_loved, is_highly_reordered, is_previously_bought, is_chefs_choice
) values
  ('c0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001',
   'c0000000-0000-0000-0000-000000000001', 'Cold Brew Coffee', 'Bold, smooth cold brew',
   'BEVERAGE', 15000, 17900, true, true, 'PUBLISHED', true, false, false,
   '☕', 'https://images.unsplash.com/photo-1517701603779-8ce7bd86a9d4?w=400&h=400&fit=crop',
   '250ml', 12, 15, 1, 'NutriCafe', true, true, true, true, false),
  ('c0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001',
   'c0000000-0000-0000-0000-000000000001', 'Cranberry Iced Coffee', 'Fruity, bold iced coffee',
   'BEVERAGE', 15900, null, true, true, 'PUBLISHED', true, false, false,
   '☕', 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400&h=400&fit=crop',
   '360ml', 12, 85, 2, 'NutriCafe', true, false, true, true, false),
  ('c0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001',
   'c0000000-0000-0000-0000-000000000001', 'Adrak Chai', 'Spiced and soothing sip',
   'BEVERAGE', 6900, 9900, true, true, 'PUBLISHED', true, false, false,
   '🍵', 'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?w=400&h=400&fit=crop',
   '2 cups', 15, 69, 2, 'NutriCafe', true, true, true, false, false),
  ('c0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000001',
   'c0000000-0000-0000-0000-000000000001', 'Crispy Peri Peri Fries', 'Spicy crispy fries',
   'SNACK', 13900, null, true, true, 'PUBLISHED', true, false, false,
   '🍟', 'https://images.unsplash.com/photo-1573080496219-b998a60c8d8a?w=400&h=400&fit=crop',
   '250g', 15, 280, 4, 'NutriCafe', true, false, true, false, false),
  ('c0000000-0000-0000-0000-000000000005', 'a0000000-0000-0000-0000-000000000001',
   'c0000000-0000-0000-0000-000000000001', 'Veg Delight Party Platter', 'Free cheese pops included',
   'PARTY', 39900, 43700, true, true, 'PUBLISHED', true, false, false,
   '🥗', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=400&fit=crop',
   'Serves 3-4', 15, 380, 14, 'NutriCafe', true, false, true, false, false),
  ('c0000000-0000-0000-0000-000000000010', 'a0000000-0000-0000-0000-000000000001',
   'c0000000-0000-0000-0000-000000000001', 'Protein Oats Bowl', 'Oats, yogurt, berries',
   'BREAKFAST', 14900, null, true, true, 'PUBLISHED', false, true, false,
   '🥣', null, '290g', 25, 380, 28, 'HealthOS Cloud Kitchen', false, false, false, false, false),
  ('c0000000-0000-0000-0000-000000000011', 'a0000000-0000-0000-0000-000000000001',
   'c0000000-0000-0000-0000-000000000001', 'Grilled Chicken Rice', 'Chicken, brown rice, broccoli',
   'LUNCH', 24900, null, false, true, 'PUBLISHED', false, true, false,
   '🍗', null, '420g', 30, 520, 45, 'FitFuel Kitchen', false, true, false, false, false),
  ('c0000000-0000-0000-0000-000000000012', 'a0000000-0000-0000-0000-000000000001',
   'c0000000-0000-0000-0000-000000000001', 'Moong Dal Chilla', 'High protein breakfast',
   'BREAKFAST', 12000, null, true, true, 'PUBLISHED', false, false, true,
   '🥞', null, '2 pcs', 20, 320, 22, 'NutriCafe', false, false, false, false, true)
on conflict (id) do nothing;

insert into cafe_sections (id, kitchen_id, section_key, title, sort_order) values
  ('s0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'ORDER_AGAIN', 'Order Again', 1),
  ('s0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'BESTSELLERS', 'Bistro Bestsellers', 2),
  ('s0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'LATE_NIGHT', 'Late Night Cravings', 3),
  ('s0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000001', 'PARTY_PACKS', 'Party Packs', 4)
on conflict (id) do nothing;

insert into cafe_section_items (id, section_id, catalog_item_id, sort_order) values
  ('si000000-0000-0000-0000-000000000001', 's0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002', 1),
  ('si000000-0000-0000-0000-000000000002', 's0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 2),
  ('si000000-0000-0000-0000-000000000003', 's0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000003', 3),
  ('si000000-0000-0000-0000-000000000004', 's0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 1),
  ('si000000-0000-0000-0000-000000000005', 's0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000003', 2),
  ('si000000-0000-0000-0000-000000000006', 's0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000004', 1),
  ('si000000-0000-0000-0000-000000000007', 's0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000005', 1)
on conflict (id) do nothing;

insert into recipes (id, catalog_item_id, slot, cook_time_mins, difficulty, fits_goal, ingredients, steps) values
  ('r0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000012', 'Breakfast', 15, 'Easy', true,
   '[{"name":"Moong dal batter","grams":120},{"name":"Onion","grams":30}]',
   '["Mix batter","Spread on pan","Cook until golden"]')
on conflict (id) do nothing;

insert into meal_system_plans (id, kitchen_id, name, tagline, price_per_month, system_type, slots, features) values
  ('ms000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001',
   '2-Meal System', 'Lunch + Dinner tailored to your macros', 4999, 'two_meal',
   '["Lunch","Dinner"]', '["Macro-adjusted portions","Free delivery"]'),
  ('ms000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001',
   '3-Meal System', 'Breakfast + Lunch + Dinner', 6999, 'three_meal',
   '["Breakfast","Lunch","Dinner"]', '["Full day coverage","Priority support"]')
on conflict (id) do nothing;
