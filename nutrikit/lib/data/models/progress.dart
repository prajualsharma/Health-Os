class WeightPoint {
  const WeightPoint({required this.label, required this.weight});

  final String label;
  final double weight;

  factory WeightPoint.fromJson(Map<String, dynamic> json) => WeightPoint(
        label: json['label'] as String? ?? '',
        weight: (json['weight'] as num?)?.toDouble() ?? 0,
      );
}

class AdherenceDay {
  const AdherenceDay({required this.day, required this.pct});

  final String day;
  final int pct;

  factory AdherenceDay.fromJson(Map<String, dynamic> json) => AdherenceDay(
        day: json['day'] as String? ?? '',
        pct: (json['pct'] as num?)?.toInt() ?? 0,
      );
}

class ProgressData {
  const ProgressData({
    required this.currentWeight,
    required this.kgLost,
    required this.weekStreak,
    required this.weights,
    required this.adherence,
    required this.lastLoggedWeight,
  });

  final double currentWeight;
  final double kgLost;
  final int weekStreak;
  final List<WeightPoint> weights;
  final List<AdherenceDay> adherence;
  final double lastLoggedWeight;

  factory ProgressData.fromJson(Map<String, dynamic> json) => ProgressData(
        currentWeight: (json['currentWeight'] as num?)?.toDouble() ?? 0,
        kgLost: (json['kgLost'] as num?)?.toDouble() ?? 0,
        weekStreak: (json['weekStreak'] as num?)?.toInt() ?? 0,
        lastLoggedWeight: (json['lastLoggedWeight'] as num?)?.toDouble() ?? 0,
        weights: (json['weights'] as List<dynamic>? ?? [])
            .map((e) => WeightPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        adherence: (json['adherence'] as List<dynamic>? ?? [])
            .map((e) => AdherenceDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
