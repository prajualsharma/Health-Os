enum PlanCategory { home, diet, gym, couple }

extension PlanCategoryX on PlanCategory {
  String get label => switch (this) {
        PlanCategory.home => 'Home',
        PlanCategory.diet => 'Diet',
        PlanCategory.gym => 'Gym',
        PlanCategory.couple => 'Couple',
      };

  String get emoji => switch (this) {
        PlanCategory.home => '🏠',
        PlanCategory.diet => '🥗',
        PlanCategory.gym => '💪',
        PlanCategory.couple => '💑',
      };

  static PlanCategory fromKey(String key) => switch (key) {
        'home' => PlanCategory.home,
        'gym' => PlanCategory.gym,
        'couple' => PlanCategory.couple,
        _ => PlanCategory.diet,
      };
}

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.tagline,
    required this.pricePerMonth,
    required this.category,
    required this.features,
    this.highlight = false,
    this.route,
  });

  final String id;
  final String name;
  final String tagline;
  final int pricePerMonth;
  final PlanCategory category;
  final List<String> features;
  final bool highlight;
  final String? route;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final cat = json['category'] as String? ?? 'diet';
    return SubscriptionPlan(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      pricePerMonth: (json['pricePerMonth'] as num?)?.toInt() ?? 0,
      category: PlanCategoryX.fromKey(cat),
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      highlight: json['highlight'] as bool? ?? false,
      route: json['route'] as String?,
    );
  }
}

class CouplePartner {
  const CouplePartner({
    required this.name,
    required this.initials,
    this.linked = false,
  });

  final String name;
  final String initials;
  final bool linked;
}
