class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.initials,
    required this.goal,
    required this.currentWeight,
    required this.targetWeight,
    required this.height,
    required this.calorieTarget,
    required this.proteinTarget,
    required this.carbTarget,
    required this.fatTarget,
    this.plan = 'Pro',
    this.gymName = 'FitHub Gym',
  });

  final String name;
  final String email;
  final String initials;
  final String goal;
  final double currentWeight;
  final double targetWeight;
  final int height;
  final int calorieTarget;
  final int proteinTarget;
  final int carbTarget;
  final int fatTarget;
  final String plan;
  final String gymName;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    final initials = json['initials'] as String? ?? _initialsFromName(name);
    final rawGoal = json['goal'] as String? ?? '';
    return UserProfile(
      name: name,
      email: json['email'] as String? ?? '',
      initials: initials,
      goal: _formatGoal(rawGoal),
      currentWeight: (json['currentWeight'] as num?)?.toDouble() ??
          (json['weight'] as num?)?.toDouble() ??
          0,
      targetWeight: (json['targetWeight'] as num?)?.toDouble() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      calorieTarget: (json['calorieTarget'] as num?)?.toInt() ?? 0,
      proteinTarget: (json['proteinTarget'] as num?)?.toInt() ?? 0,
      carbTarget: (json['carbTarget'] as num?)?.toInt() ?? 0,
      fatTarget: (json['fatTarget'] as num?)?.toInt() ?? 0,
      plan: json['plan'] as String? ?? 'NutriKit',
      gymName: json['gymName'] as String? ?? '',
    );
  }

  static String _initialsFromName(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'NK';
    if (parts.length == 1) {
      final word = parts.first;
      if (word.length >= 2) {
        return word.substring(0, 2);
      }
      return word.toUpperCase();
    }
    return parts
        .take(2)
        .map((p) => p[0])
        .join()
        .toUpperCase();
  }

  static String _formatGoal(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'lose_weight':
      case 'lose':
      case 'weight_loss':
        return 'Lose Weight';
      case 'build_muscle':
      case 'gain_muscle':
      case 'muscle_gain':
        return 'Gain Muscle';
      case 'maintain':
      case 'maintain_weight':
        return 'Maintain Weight';
      case 'eat_healthier':
        return 'Eat Healthier';
      default:
        return raw.isEmpty ? 'Health Goal' : raw;
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'initials': initials,
        'goal': goal,
        'currentWeight': currentWeight,
        'targetWeight': targetWeight,
        'height': height,
        'calorieTarget': calorieTarget,
        'proteinTarget': proteinTarget,
        'carbTarget': carbTarget,
        'fatTarget': fatTarget,
        'plan': plan,
        'gymName': gymName,
      };
}
