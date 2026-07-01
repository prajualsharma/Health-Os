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
    this.description = '',
    this.originalPrice = 0,
    this.prepTimeMins = 15,
    this.imageUrl = '',
    this.isHighlyReordered = false,
    this.isMostLoved = false,
    this.isPreviouslyBought = false,
    this.isChefsChoice = false,
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
  final String description;
  final double originalPrice;
  final int prepTimeMins;
  final String imageUrl;
  final bool isHighlyReordered;
  final bool isMostLoved;
  final bool isPreviouslyBought;
  final bool isChefsChoice;

  int? get discountPercent {
    if (originalPrice <= 0 || originalPrice <= price) return null;
    return ((1 - price / originalPrice) * 100).round();
  }

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
        description: json['description'] as String? ?? '',
        originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0,
        prepTimeMins: (json['prepTimeMins'] as num?)?.toInt() ?? 15,
        imageUrl: json['imageUrl'] as String? ?? '',
        isHighlyReordered: json['isHighlyReordered'] as bool? ?? false,
        isMostLoved: json['isMostLoved'] as bool? ?? false,
        isPreviouslyBought: json['isPreviouslyBought'] as bool? ?? false,
        isChefsChoice: json['isChefsChoice'] as bool? ?? false,
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
        'description': description,
        'originalPrice': originalPrice,
        'prepTimeMins': prepTimeMins,
        'imageUrl': imageUrl,
        'isHighlyReordered': isHighlyReordered,
        'isMostLoved': isMostLoved,
        'isPreviouslyBought': isPreviouslyBought,
        'isChefsChoice': isChefsChoice,
      };
}

class CafeCategoryItem {
  const CafeCategoryItem({
    required this.label,
    required this.emoji,
    this.imageUrl = '',
  });

  final String label;
  final String emoji;
  final String imageUrl;
}

class CafeSections {
  const CafeSections({
    required this.orderAgain,
    required this.categories,
    required this.bestsellers,
    required this.lateNight,
    required this.partyPacks,
    required this.allItems,
  });

  final List<Dish> orderAgain;
  final List<CafeCategoryItem> categories;
  final List<Dish> bestsellers;
  final List<Dish> lateNight;
  final List<Dish> partyPacks;
  final List<Dish> allItems;

  factory CafeSections.fromJson(Map<String, dynamic> json) {
    List<Dish> dishes(String key) => (json[key] as List<dynamic>? ?? [])
        .map((e) => Dish.fromJson(e as Map<String, dynamic>))
        .toList();
    return CafeSections(
      orderAgain: dishes('orderAgain'),
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => CafeCategoryItem(
                label: e['label'] as String? ?? '',
                emoji: e['emoji'] as String? ?? '🍽️',
                imageUrl: e['imageUrl'] as String? ?? '',
              ))
          .toList(),
      bestsellers: dishes('bestsellers'),
      lateNight: dishes('lateNight'),
      partyPacks: dishes('partyPacks'),
      allItems: dishes('allItems'),
    );
  }
}
