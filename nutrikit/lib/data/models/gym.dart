class GymPlan {
  const GymPlan({
    required this.id,
    required this.name,
    required this.tagline,
    required this.pricePerMonth,
    required this.period,
    required this.features,
    this.popular = false,
    this.emoji = '💪',
  });

  final String id;
  final String name;
  final String tagline;
  final int pricePerMonth;
  final String period;
  final List<String> features;
  final bool popular;
  final String emoji;
}

class GymStudio {
  const GymStudio({
    required this.id,
    required this.name,
    required this.area,
    required this.rating,
    required this.emoji,
  });

  final String id;
  final String name;
  final String area;
  final double rating;
  final String emoji;
}

class PartnerGym {
  const PartnerGym({
    required this.id,
    required this.name,
    required this.area,
    required this.distanceKm,
    required this.rating,
    required this.emoji,
    required this.offerText,
    this.isPartner = true,
    this.assignedTrainer = 'Rahul Sharma',
  });

  final String id;
  final String name;
  final String area;
  final double distanceKm;
  final double rating;
  final String emoji;
  final String offerText;
  final bool isPartner;
  final String assignedTrainer;
}

class WorkoutExercise {
  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.detail,
    required this.caloriesBurn,
    this.done = false,
  });

  final String id;
  final String name;
  final String detail;
  final int caloriesBurn;
  final bool done;

  WorkoutExercise copyWith({bool? done}) => WorkoutExercise(
        id: id,
        name: name,
        detail: detail,
        caloriesBurn: caloriesBurn,
        done: done ?? this.done,
      );
}

class WorkoutDay {
  const WorkoutDay({
    required this.dayLabel,
    required this.exercises,
  });

  final String dayLabel;
  final List<WorkoutExercise> exercises;
}

class WeeklyWorkoutPlan {
  const WeeklyWorkoutPlan({
    required this.weekNumber,
    required this.title,
    required this.days,
  });

  final int weekNumber;
  final String title;
  final List<WorkoutDay> days;
}
