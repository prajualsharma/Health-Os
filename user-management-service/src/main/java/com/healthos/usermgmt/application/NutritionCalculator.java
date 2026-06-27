package com.healthos.usermgmt.application;

import com.healthos.usermgmt.application.AuthService.NutritionTargets;

/**
 * Computes daily calorie and macro targets using the Mifflin-St Jeor equation. This is a simple,
 * deterministic baseline; a dedicated nutrition service can replace it later.
 */
final class NutritionCalculator {
  private NutritionCalculator() {}

  static NutritionTargets compute(
      String gender, Integer age, Integer heightCm, Integer weightKg, String activity, String goal) {
    if (heightCm == null || weightKg == null || age == null) {
      return new NutritionTargets(2000, 130, 220, 60);
    }

    double bmr = 10.0 * weightKg + 6.25 * heightCm - 5.0 * age;
    bmr += isFemale(gender) ? -161 : 5;

    double calories = bmr * activityFactor(activity) + goalAdjustment(goal);
    int caloriesInt = (int) Math.round(calories);

    int protein = (int) Math.round(1.8 * weightKg);
    int fat = (int) Math.round((caloriesInt * 0.25) / 9.0);
    int carbs = (int) Math.round((caloriesInt - (protein * 4.0) - (fat * 9.0)) / 4.0);
    if (carbs < 0) carbs = 0;

    return new NutritionTargets(caloriesInt, protein, carbs, fat);
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

  private static double goalAdjustment(String goal) {
    if (goal == null) return 0;
    return switch (goal.trim().toLowerCase()) {
      case "lose_weight", "lose", "weight_loss", "fat_loss" -> -500;
      case "gain_weight", "gain", "build_muscle", "muscle_gain" -> 300;
      default -> 0;
    };
  }
}
