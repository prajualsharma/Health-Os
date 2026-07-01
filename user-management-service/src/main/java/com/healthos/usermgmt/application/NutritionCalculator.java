package com.healthos.usermgmt.application;

import com.healthos.usermgmt.application.AuthService.NutritionTargets;

/**
 * Computes daily calorie and macro targets using the Mifflin-St Jeor equation. This is a simple,
 * deterministic baseline; a dedicated nutrition service can replace it later.
 */
public final class NutritionCalculator {
  private NutritionCalculator() {}

  public static NutritionTargets compute(
      String gender,
      Integer age,
      Integer heightCm,
      Integer weightKg,
      Integer targetWeightKg,
      String activity,
      String goal,
      String goalPace) {
    if (heightCm == null || weightKg == null || age == null) {
      return new NutritionTargets(2000, 130, 220, 60, 10);
    }

    double bmr = 10.0 * weightKg + 6.25 * heightCm - 5.0 * age;
    bmr += isFemale(gender) ? -161 : 5;

    double calories = bmr * activityFactor(activity) + goalAdjustment(goal, goalPace);
    int caloriesInt = (int) Math.round(calories);

    int protein = (int) Math.round(1.8 * weightKg);
    int fat = (int) Math.round((caloriesInt * 0.25) / 9.0);
    int carbs = (int) Math.round((caloriesInt - (protein * 4.0) - (fat * 9.0)) / 4.0);
    if (carbs < 0) carbs = 0;

    int timelineWeeks =
        estimateTimelineWeeks(weightKg, targetWeightKg != null ? targetWeightKg : weightKg, goalPace);

    return new NutritionTargets(caloriesInt, protein, carbs, fat, timelineWeeks);
  }

  static int estimateTimelineWeeks(int currentKg, int targetKg, String goalPace) {
    double weeklyChange =
        switch (goalPace == null ? "moderate" : goalPace.trim().toLowerCase()) {
          case "relaxed" -> 0.25;
          case "gradual" -> 0.5;
          case "rapid" -> 1.0;
          default -> 0.75;
        };
    double diff = Math.abs(targetKg - currentKg);
    if (diff < 0.5) return 0;
    return (int) Math.ceil(diff / weeklyChange);
  }

  private static boolean isFemale(String gender) {
    return gender != null && gender.trim().toLowerCase().startsWith("f");
  }

  private static double activityFactor(String activity) {
    if (activity == null) return 1.375;
    return switch (activity.trim().toLowerCase()) {
      case "sedentary" -> 1.2;
      case "light", "lightly_active" -> 1.375;
      case "moderate", "moderately_active" -> 1.55;
      case "active", "very_active" -> 1.725;
      case "athlete", "extra_active" -> 1.9;
      default -> 1.375;
    };
  }

  private static double goalAdjustment(String goal, String goalPace) {
    double paceFactor =
        switch (goalPace == null ? "moderate" : goalPace.trim().toLowerCase()) {
          case "relaxed" -> 0.5;
          case "gradual" -> 0.75;
          case "rapid" -> 1.5;
          default -> 1.0;
        };
    if (goal == null) return 0;
    double base =
        switch (goal.trim().toLowerCase()) {
          case "lose_weight", "lose", "weight_loss", "fat_loss" -> -500;
          case "gain_weight", "gain", "build_muscle", "muscle_gain" -> 300;
          default -> 0;
        };
    return base * paceFactor;
  }
}
