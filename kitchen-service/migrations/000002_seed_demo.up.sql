-- Demo seed so the kitchen API returns data when run live (mirrors the Flutter mock data).

insert into kitchens (id, org_id, name, address, city, status)
values
  ('a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001',
   'HealthOS Cloud Kitchen - Indiranagar', '100 Feet Road, Indiranagar', 'Bengaluru', 'ACTIVE'),
  ('a0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001',
   'HealthOS Cloud Kitchen - Koramangala', '5th Block, Koramangala', 'Bengaluru', 'ACTIVE')
on conflict (id) do nothing;

insert into menu_items (id, kitchen_id, name, description, category, price_cents, veg, available)
values
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001',
   'Masala Oats Bowl', 'Steel-cut oats with veggies', 'BREAKFAST', 18000, true, true),
  ('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001',
   'Egg White Omelette', '4 egg whites, peppers, spinach', 'BREAKFAST', 22000, false, true),
  ('b0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001',
   'Grilled Paneer Salad', 'Paneer, greens, olive dressing', 'LUNCH', 28000, true, true),
  ('b0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000001',
   'Grilled Chicken Bowl', 'Chicken, quinoa, veggies', 'LUNCH', 32000, false, true),
  ('b0000000-0000-0000-0000-000000000005', 'a0000000-0000-0000-0000-000000000001',
   'Dal Khichdi', 'Comforting moong dal khichdi', 'DINNER', 20000, true, true),
  ('b0000000-0000-0000-0000-000000000006', 'a0000000-0000-0000-0000-000000000001',
   'Sprout Chaat', 'Protein-rich evening snack', 'SNACK', 12000, true, true),
  ('b0000000-0000-0000-0000-000000000007', 'a0000000-0000-0000-0000-000000000001',
   'Cold Brew Coffee', 'Sugar-free cold brew', 'BEVERAGE', 15000, true, true)
on conflict (id) do nothing;

insert into food_orders (id, kitchen_id, order_code, customer_name, customer_phone, status, total_cents)
values
  ('d0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001',
   'ORD-10001', 'Aarav Sharma', '+919000000001', 'NEW', 50000),
  ('d0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001',
   'ORD-10002', 'Diya Patel', '+919000000002', 'ACCEPTED', 28000),
  ('d0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001',
   'ORD-10003', 'Kabir Rao', '+919000000003', 'PREPARING', 32000)
on conflict (id) do nothing;

insert into order_lines (id, order_id, menu_item_id, name, quantity, price_cents)
values
  ('e0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001',
   'b0000000-0000-0000-0000-000000000002', 'Egg White Omelette', 1, 22000),
  ('e0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001',
   'b0000000-0000-0000-0000-000000000003', 'Grilled Paneer Salad', 1, 28000),
  ('e0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000002',
   'b0000000-0000-0000-0000-000000000003', 'Grilled Paneer Salad', 1, 28000),
  ('e0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000003',
   'b0000000-0000-0000-0000-000000000004', 'Grilled Chicken Bowl', 1, 32000)
on conflict (id) do nothing;
