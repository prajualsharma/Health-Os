import 'meal.dart';

class QuickStat {
  const QuickStat({required this.emoji, required this.value, required this.label});

  final String emoji;
  final String value;
  final String label;

  factory QuickStat.fromJson(Map<String, dynamic> json) => QuickStat(
        emoji: json['emoji'] as String? ?? '',
        value: json['value']?.toString() ?? '',
        label: json['label'] as String? ?? '',
      );
}

class DashboardData {
  const DashboardData({
    required this.userName,
    required this.initials,
    required this.calorieTarget,
    required this.caloriesConsumed,
    required this.proteinConsumed,
    required this.proteinTarget,
    required this.carbsConsumed,
    required this.carbTarget,
    required this.fatConsumed,
    required this.fatTarget,
    required this.quickStats,
    required this.meals,
  });

  final String userName;
  final String initials;
  final int calorieTarget;
  final int caloriesConsumed;
  final int proteinConsumed;
  final int proteinTarget;
  final int carbsConsumed;
  final int carbTarget;
  final int fatConsumed;
  final int fatTarget;
  final List<QuickStat> quickStats;
  final List<Meal> meals;

  double get caloriePct =>
      calorieTarget <= 0 ? 0 : (caloriesConsumed / calorieTarget) * 100;

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
        userName: json['userName'] as String? ?? '',
        initials: json['initials'] as String? ?? 'NK',
        calorieTarget: (json['calorieTarget'] as num?)?.toInt() ?? 0,
        caloriesConsumed: (json['caloriesConsumed'] as num?)?.toInt() ?? 0,
        proteinConsumed: (json['proteinConsumed'] as num?)?.toInt() ?? 0,
        proteinTarget: (json['proteinTarget'] as num?)?.toInt() ?? 0,
        carbsConsumed: (json['carbsConsumed'] as num?)?.toInt() ?? 0,
        carbTarget: (json['carbTarget'] as num?)?.toInt() ?? 0,
        fatConsumed: (json['fatConsumed'] as num?)?.toInt() ?? 0,
        fatTarget: (json['fatTarget'] as num?)?.toInt() ?? 0,
        quickStats: (json['quickStats'] as List<dynamic>? ?? [])
            .map((e) => QuickStat.fromJson(e as Map<String, dynamic>))
            .toList(),
        meals: (json['meals'] as List<dynamic>? ?? [])
            .map((e) => Meal.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
