import '../models/models.dart';

/// In-app dummy data so the kitchen app runs end-to-end with no backend.
class MockData {
  MockData._();

  static const orgId = 'c0000000-0000-0000-0000-000000000001';

  static List<Kitchen> kitchens() => [
        Kitchen(
          id: 'a0000000-0000-0000-0000-000000000001',
          orgId: orgId,
          name: 'HealthOS Cloud Kitchen - Indiranagar',
          address: '100 Feet Road, Indiranagar',
          city: 'Bengaluru',
        ),
        Kitchen(
          id: 'a0000000-0000-0000-0000-000000000002',
          orgId: orgId,
          name: 'HealthOS Cloud Kitchen - Koramangala',
          address: '5th Block, Koramangala',
          city: 'Bengaluru',
        ),
      ];

  static List<MenuItem> menu(String kitchenId) => [
        MenuItem(
          id: 'b1',
          kitchenId: kitchenId,
          name: 'Masala Oats Bowl',
          description: 'Steel-cut oats with veggies',
          category: MealCategory.breakfast,
          priceCents: 18000,
          veg: true,
        ),
        MenuItem(
          id: 'b2',
          kitchenId: kitchenId,
          name: 'Egg White Omelette',
          description: '4 egg whites, peppers, spinach',
          category: MealCategory.breakfast,
          priceCents: 22000,
          veg: false,
        ),
        MenuItem(
          id: 'l1',
          kitchenId: kitchenId,
          name: 'Grilled Paneer Salad',
          description: 'Paneer, greens, olive dressing',
          category: MealCategory.lunch,
          priceCents: 28000,
          veg: true,
        ),
        MenuItem(
          id: 'l2',
          kitchenId: kitchenId,
          name: 'Grilled Chicken Bowl',
          description: 'Chicken, quinoa, veggies',
          category: MealCategory.lunch,
          priceCents: 32000,
          veg: false,
        ),
        MenuItem(
          id: 'd1',
          kitchenId: kitchenId,
          name: 'Dal Khichdi',
          description: 'Comforting moong dal khichdi',
          category: MealCategory.dinner,
          priceCents: 20000,
          veg: true,
        ),
        MenuItem(
          id: 's1',
          kitchenId: kitchenId,
          name: 'Sprout Chaat',
          description: 'Protein-rich evening snack',
          category: MealCategory.snack,
          priceCents: 12000,
          veg: true,
        ),
        MenuItem(
          id: 'bv1',
          kitchenId: kitchenId,
          name: 'Cold Brew Coffee',
          description: 'Sugar-free cold brew',
          category: MealCategory.beverage,
          priceCents: 15000,
          veg: true,
        ),
      ];

  static List<FoodOrder> orders(String kitchenId) {
    final now = DateTime.now();
    return [
      FoodOrder(
        id: 'o1',
        kitchenId: kitchenId,
        orderCode: 'ORD-10001',
        customerName: 'Aarav Sharma',
        customerPhone: '+919000000001',
        status: OrderStatus.newOrder,
        totalCents: 50000,
        createdAt: now.subtract(const Duration(minutes: 2)),
        items: [
          OrderLine(name: 'Egg White Omelette', quantity: 1, priceCents: 22000),
          OrderLine(name: 'Grilled Paneer Salad', quantity: 1, priceCents: 28000),
        ],
      ),
      FoodOrder(
        id: 'o2',
        kitchenId: kitchenId,
        orderCode: 'ORD-10002',
        customerName: 'Diya Patel',
        customerPhone: '+919000000002',
        status: OrderStatus.accepted,
        totalCents: 28000,
        createdAt: now.subtract(const Duration(minutes: 6)),
        items: [
          OrderLine(name: 'Grilled Paneer Salad', quantity: 1, priceCents: 28000),
        ],
      ),
      FoodOrder(
        id: 'o3',
        kitchenId: kitchenId,
        orderCode: 'ORD-10003',
        customerName: 'Kabir Rao',
        customerPhone: '+919000000003',
        status: OrderStatus.preparing,
        totalCents: 32000,
        createdAt: now.subtract(const Duration(minutes: 11)),
        items: [
          OrderLine(name: 'Grilled Chicken Bowl', quantity: 1, priceCents: 32000),
        ],
      ),
      FoodOrder(
        id: 'o4',
        kitchenId: kitchenId,
        orderCode: 'ORD-10004',
        customerName: 'Meera Nair',
        customerPhone: '+919000000004',
        status: OrderStatus.ready,
        totalCents: 20000,
        createdAt: now.subtract(const Duration(minutes: 14)),
        items: [
          OrderLine(name: 'Dal Khichdi', quantity: 1, priceCents: 20000),
        ],
      ),
    ];
  }

  static const _names = [
    'Rohan Gupta',
    'Ananya Iyer',
    'Vikram Singh',
    'Sara Khan',
    'Aditya Menon',
    'Ishita Bose',
  ];

  static const _dishes = [
    ['Masala Oats Bowl', 18000],
    ['Grilled Chicken Bowl', 32000],
    ['Grilled Paneer Salad', 28000],
    ['Sprout Chaat', 12000],
    ['Cold Brew Coffee', 15000],
  ];

  /// Generates a fresh incoming order to simulate a live order feed.
  static FoodOrder incomingOrder(String kitchenId, int seq) {
    final name = _names[seq % _names.length];
    final dish = _dishes[seq % _dishes.length];
    final price = dish[1] as int;
    return FoodOrder(
      id: 'sim-$seq-${DateTime.now().millisecondsSinceEpoch}',
      kitchenId: kitchenId,
      orderCode: 'ORD-${20001 + seq}',
      customerName: name,
      customerPhone: '+9190000${(10000 + seq).toString().padLeft(5, '0')}',
      status: OrderStatus.newOrder,
      totalCents: price,
      createdAt: DateTime.now(),
      items: [
        OrderLine(name: dish[0] as String, quantity: 1, priceCents: price),
      ],
    );
  }
}
