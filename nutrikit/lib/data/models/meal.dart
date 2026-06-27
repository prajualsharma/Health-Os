class Ingredient {
  const Ingredient({required this.name, required this.weight});

  final String name;
  final String weight;

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json['name'] as String? ?? '',
        weight: json['weight'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'name': name, 'weight': weight};
}

class Meal {
  const Meal({
    required this.id,
    required this.slot,
    required this.name,
    required this.emoji,
    required this.subtitle,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.portion = '420g',
    this.isVeg = true,
    this.done = false,
    this.ingredients = const [],
    this.price = 0,
  });

  final String id;
  final String slot;
  final String name;
  final String emoji;
  final String subtitle;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String portion;
  final bool isVeg;
  final bool done;
  final List<Ingredient> ingredients;
  final double price;

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        id: json['id']?.toString() ?? '',
        slot: json['slot'] as String? ?? '',
        name: json['name'] as String? ?? '',
        emoji: json['emoji'] as String? ?? '🍽️',
        subtitle: json['subtitle'] as String? ?? '',
        calories: (json['calories'] as num?)?.toInt() ?? 0,
        protein: (json['protein'] as num?)?.toInt() ?? 0,
        carbs: (json['carbs'] as num?)?.toInt() ?? 0,
        fat: (json['fat'] as num?)?.toInt() ?? 0,
        portion: json['portion'] as String? ?? '420g',
        isVeg: json['isVeg'] as bool? ?? true,
        done: json['done'] as bool? ?? false,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        ingredients: (json['ingredients'] as List<dynamic>? ?? [])
            .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'slot': slot,
        'name': name,
        'emoji': emoji,
        'subtitle': subtitle,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'portion': portion,
        'isVeg': isVeg,
        'done': done,
        'price': price,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
      };
}
