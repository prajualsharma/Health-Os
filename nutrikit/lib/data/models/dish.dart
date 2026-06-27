class Dish {
  const Dish({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.calories,
    required this.protein,
    required this.isVeg,
    this.price = 0,
    this.portion = '350g',
    this.kitchenName = 'HealthOS Cloud Kitchen',
    this.rating = 4.7,
    this.deliveryEta = '25–35 min',
    this.isAddOn = false,
  });

  final String id;
  final String name;
  final String emoji;
  final String category;
  final int calories;
  final int protein;
  final bool isVeg;
  final double price;
  final String portion;
  final String kitchenName;
  final double rating;
  final String deliveryEta;
  final bool isAddOn;

  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        emoji: json['emoji'] as String? ?? '🍽️',
        category: json['category'] as String? ?? 'All',
        calories: (json['calories'] as num?)?.toInt() ?? 0,
        protein: (json['protein'] as num?)?.toInt() ?? 0,
        isVeg: json['isVeg'] as bool? ?? true,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        portion: json['portion'] as String? ?? '350g',
        kitchenName: json['kitchenName'] as String? ?? 'HealthOS Cloud Kitchen',
        rating: (json['rating'] as num?)?.toDouble() ?? 4.7,
        deliveryEta: json['deliveryEta'] as String? ?? '25–35 min',
        isAddOn: json['isAddOn'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'category': category,
        'calories': calories,
        'protein': protein,
        'isVeg': isVeg,
        'price': price,
        'portion': portion,
        'kitchenName': kitchenName,
        'rating': rating,
        'deliveryEta': deliveryEta,
        'isAddOn': isAddOn,
      };
}
