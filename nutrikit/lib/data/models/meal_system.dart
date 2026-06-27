enum MealSystemType { none, twoMeal, threeMeal }

extension MealSystemTypeX on MealSystemType {
  String get storageKey => switch (this) {
        MealSystemType.none => 'none',
        MealSystemType.twoMeal => 'two',
        MealSystemType.threeMeal => 'three',
      };

  static MealSystemType fromKey(String? key) => switch (key) {
        'two' => MealSystemType.twoMeal,
        'three' => MealSystemType.threeMeal,
        _ => MealSystemType.none,
      };

  bool get isSubscribed => this != MealSystemType.none;

  List<String> get slots => switch (this) {
        MealSystemType.threeMeal =>
          ['Breakfast', 'Lunch', 'Dinner'],
        MealSystemType.twoMeal => ['Lunch', 'Dinner'],
        MealSystemType.none => [],
      };
}

class MealSystemPlan {
  const MealSystemPlan({
    required this.id,
    required this.name,
    required this.tagline,
    required this.pricePerMonth,
    required this.systemType,
    required this.slots,
    required this.features,
  });

  final String id;
  final String name;
  final String tagline;
  final int pricePerMonth;
  final MealSystemType systemType;
  final List<String> slots;
  final List<String> features;
}
