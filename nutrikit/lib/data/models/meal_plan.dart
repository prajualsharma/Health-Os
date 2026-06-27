import 'meal.dart';

class MealPlanData {
  const MealPlanData({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.onTrack,
    required this.meals,
  });

  final DateTime date;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final bool onTrack;
  final List<Meal> meals;

  factory MealPlanData.fromJson(Map<String, dynamic> json) => MealPlanData(
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        totalCalories: (json['totalCalories'] as num?)?.toInt() ?? 0,
        totalProtein: (json['totalProtein'] as num?)?.toInt() ?? 0,
        totalCarbs: (json['totalCarbs'] as num?)?.toInt() ?? 0,
        totalFat: (json['totalFat'] as num?)?.toInt() ?? 0,
        onTrack: json['onTrack'] as bool? ?? true,
        meals: (json['meals'] as List<dynamic>? ?? [])
            .map((e) => Meal.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
