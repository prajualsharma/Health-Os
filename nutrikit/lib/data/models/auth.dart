class AuthResponse {
  const AuthResponse({required this.token, required this.userId, this.name});

  final String token;
  final String userId;
  final String? name;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'] as String? ?? '',
        userId: json['userId']?.toString() ?? '',
        name: json['name'] as String?,
      );
}

class OnboardingData {
  const OnboardingData({
    this.phone = '',
    this.name = '',
    this.email = '',
    this.goal = '',
    this.goals = const [],
    this.gender = '',
    this.age = 0,
    this.height = 0,
    this.heightFeet = 5,
    this.heightInches = 8,
    this.currentWeight = 0,
    this.targetWeight = 0,
    this.activityLevel = '',
    this.dietType = '',
    this.allergies = const [],
    this.medicalConditions = const [],
    this.city = '',
    this.goalPace = 'moderate',
    this.heightUnit = 'cm',
    this.weightUnit = 'kg',
  });

  final String phone;
  final String name;
  final String email;
  final String goal;
  final List<String> goals;
  final String gender;
  final int age;
  final int height;
  final int heightFeet;
  final int heightInches;
  final double currentWeight;
  final double targetWeight;
  final String activityLevel;
  final String dietType;
  final List<String> allergies;
  final List<String> medicalConditions;
  final String city;
  final String goalPace;
  final String heightUnit;
  final String weightUnit;

  OnboardingData copyWith({
    String? phone,
    String? name,
    String? email,
    String? goal,
    List<String>? goals,
    String? gender,
    int? age,
    int? height,
    int? heightFeet,
    int? heightInches,
    double? currentWeight,
    double? targetWeight,
    String? activityLevel,
    String? dietType,
    List<String>? allergies,
    List<String>? medicalConditions,
    String? city,
    String? goalPace,
    String? heightUnit,
    String? weightUnit,
  }) {
    return OnboardingData(
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      goal: goal ?? this.goal,
      goals: goals ?? this.goals,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      heightFeet: heightFeet ?? this.heightFeet,
      heightInches: heightInches ?? this.heightInches,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      activityLevel: activityLevel ?? this.activityLevel,
      dietType: dietType ?? this.dietType,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      city: city ?? this.city,
      goalPace: goalPace ?? this.goalPace,
      heightUnit: heightUnit ?? this.heightUnit,
      weightUnit: weightUnit ?? this.weightUnit,
    );
  }

  static String primaryGoal(List<String> goals) {
    const priority = [
      'Weight Loss',
      'Gain Muscle',
      'Maintain Weight',
      'Eat Healthier',
      'Diet Plan',
      'Calorie Tracker',
      'Workouts',
    ];
    for (final p in priority) {
      if (goals.contains(p)) return p;
    }
    return goals.isNotEmpty ? goals.first : '';
  }

  Map<String, dynamic> toJson() => {
        'goal': goal,
        'goals': goals,
        'gender': gender,
        'age': age,
        'height': height,
        'currentWeight': currentWeight,
        'targetWeight': targetWeight,
        'activityLevel': activityLevel,
        'dietType': dietType,
        'allergies': allergies,
        'medicalConditions': medicalConditions,
        'city': city,
        'goalPace': goalPace,
        'heightUnit': heightUnit,
        'weightUnit': weightUnit,
      };

  /// Payload for the backend `POST /auth/register-phone` contract.
  Map<String, dynamic> toRegisterJson(String registrationToken) {
    final primary = goal.isNotEmpty ? goal : primaryGoal(goals);
    return {
      'phone': phone,
      'registrationToken': registrationToken,
      'name': name,
      'goal': _mapGoal(primary),
      'goals': goals.map(_mapGoal).toList(),
      'gender': gender,
      'age': age,
      'height': height,
      'weight': currentWeight.round(),
      'targetWeight': targetWeight.round(),
      'activity': _mapActivity(activityLevel),
      'diet': dietType,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'city': city,
      'goalPace': goalPace,
      'heightUnit': heightUnit,
      'weightUnit': weightUnit,
      if (email.isNotEmpty) 'email': email,
    };
  }

  static String _mapGoal(String goal) {
    switch (goal) {
      case 'Weight Loss':
        return 'lose_weight';
      case 'Gain Muscle':
        return 'build_muscle';
      case 'Maintain Weight':
        return 'maintain';
      case 'Eat Healthier':
        return 'eat_healthier';
      case 'Diet Plan':
        return 'diet_plan';
      case 'Calorie Tracker':
        return 'calorie_tracker';
      case 'Workouts':
        return 'workouts';
      default:
        return goal;
    }
  }

  static String _mapActivity(String activity) {
    switch (activity) {
      case 'Sedentary':
        return 'sedentary';
      case 'Lightly Active':
        return 'lightly_active';
      case 'Moderately Active':
        return 'moderately_active';
      case 'Very Active':
        return 'very_active';
      default:
        return activity;
    }
  }
}

/// Result of `POST /auth/phone/initiate`.
class PhoneInitiateResult {
  const PhoneInitiateResult({
    required this.exists,
    required this.otpSent,
    required this.devMode,
    required this.otpDelivered,
    this.deliveryEmail,
  });

  final bool exists;
  final bool otpSent;
  final bool devMode;
  final bool otpDelivered;
  final String? deliveryEmail;

  factory PhoneInitiateResult.fromJson(Map<String, dynamic> json) =>
      PhoneInitiateResult(
        exists: json['exists'] as bool? ?? false,
        otpSent: json['otpSent'] as bool? ?? false,
        devMode: json['devMode'] as bool? ?? false,
        otpDelivered: json['otpDelivered'] as bool? ?? false,
        deliveryEmail: json['deliveryEmail'] as String?,
      );
}

/// Result of `POST /auth/phone/verify`: either tokens (returning user) or a
/// registration token (new user).
class PhoneVerifyResult {
  const PhoneVerifyResult({
    required this.newUser,
    this.accessToken,
    this.refreshToken,
    this.registrationToken,
  });

  final bool newUser;
  final String? accessToken;
  final String? refreshToken;
  final String? registrationToken;

  factory PhoneVerifyResult.fromJson(Map<String, dynamic> json) =>
      PhoneVerifyResult(
        newUser: json['newUser'] as bool? ?? false,
        accessToken: json['accessToken'] as String?,
        refreshToken: json['refreshToken'] as String?,
        registrationToken: json['registrationToken'] as String?,
      );
}

/// Result of `POST /auth/register-phone`.
class RegisterResult {
  const RegisterResult({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.targets,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final OnboardingResponse targets;

  factory RegisterResult.fromJson(
    Map<String, dynamic> json, {
    required double targetWeight,
  }) {
    final t = (json['targets'] as Map?)?.cast<String, dynamic>() ?? const {};
    return RegisterResult(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      userId: json['userId']?.toString() ?? '',
      targets: OnboardingResponse(
        calorieTarget: (t['calories'] as num?)?.toInt() ?? 0,
        proteinTarget: (t['protein'] as num?)?.toInt() ?? 0,
        carbTarget: (t['carbs'] as num?)?.toInt() ?? 0,
        fatTarget: (t['fat'] as num?)?.toInt() ?? 0,
        timelineWeeks: (t['timelineWeeks'] as num?)?.toInt() ?? 10,
        targetWeight: targetWeight,
      ),
    );
  }
}

class OnboardingResponse {
  const OnboardingResponse({
    required this.calorieTarget,
    required this.proteinTarget,
    required this.carbTarget,
    required this.fatTarget,
    required this.timelineWeeks,
    required this.targetWeight,
  });

  final int calorieTarget;
  final int proteinTarget;
  final int carbTarget;
  final int fatTarget;
  final int timelineWeeks;
  final double targetWeight;

  factory OnboardingResponse.fromJson(Map<String, dynamic> json) =>
      OnboardingResponse(
        calorieTarget: (json['calorieTarget'] as num?)?.toInt() ?? 0,
        proteinTarget: (json['proteinTarget'] as num?)?.toInt() ?? 0,
        carbTarget: (json['carbTarget'] as num?)?.toInt() ?? 0,
        fatTarget: (json['fatTarget'] as num?)?.toInt() ?? 0,
        timelineWeeks: (json['timelineWeeks'] as num?)?.toInt() ?? 0,
        targetWeight: (json['targetWeight'] as num?)?.toDouble() ?? 0,
      );
}

class OnboardingProgress {
  const OnboardingProgress({
    required this.currentStep,
    required this.routePath,
    required this.stepLabel,
    this.phone,
  });

  final String currentStep;
  final String routePath;
  final String stepLabel;
  final String? phone;

  factory OnboardingProgress.fromJson(Map<String, dynamic> json) =>
      OnboardingProgress(
        currentStep: json['currentStep'] as String? ?? 'name',
        routePath: json['routePath'] as String? ?? '/onboarding/name',
        stepLabel: json['stepLabel'] as String? ?? 'Add your name',
        phone: json['phone'] as String?,
      );
}
