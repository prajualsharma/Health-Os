import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({ApiService? api}) : _api = api ?? ApiService.instance;

  final ApiService _api;

  int calorieTarget = 1840;
  int proteinTarget = 145;
  int carbTarget = 180;
  int fatTarget = 62;
  double currentWeight = 76.5;
  int todayCalories = 1240;
  int todayProtein = 98;
  int todayCarbs = 110;
  int todayFat = 40;
  String goal = 'Weight Loss';

  bool isLoading = false;
  String? error;

  Future<void> loadProfile() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final p = await _api.getProfile();
      calorieTarget = p.calorieTarget;
      proteinTarget = p.proteinTarget;
      carbTarget = p.carbTarget;
      fatTarget = p.fatTarget;
      currentWeight = p.currentWeight;
      goal = p.goal;
      await _persist();
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTodayProgress(int cal, int protein, int carbs, int fat) async {
    todayCalories += cal;
    todayProtein += protein;
    todayCarbs += carbs;
    todayFat += fat;
    await _persist();
    notifyListeners();
  }

  Future<void> logWeight(double weight) async {
    currentWeight = weight;
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.profileKey,
      jsonEncode({
        'calorieTarget': calorieTarget,
        'proteinTarget': proteinTarget,
        'carbTarget': carbTarget,
        'fatTarget': fatTarget,
        'currentWeight': currentWeight,
        'todayCalories': todayCalories,
        'todayProtein': todayProtein,
        'todayCarbs': todayCarbs,
        'todayFat': todayFat,
        'goal': goal,
      }),
    );
  }

  Future<void> restoreFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.profileKey);
    if (raw == null) return;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    calorieTarget = (map['calorieTarget'] as num?)?.toInt() ?? calorieTarget;
    proteinTarget = (map['proteinTarget'] as num?)?.toInt() ?? proteinTarget;
    carbTarget = (map['carbTarget'] as num?)?.toInt() ?? carbTarget;
    fatTarget = (map['fatTarget'] as num?)?.toInt() ?? fatTarget;
    currentWeight = (map['currentWeight'] as num?)?.toDouble() ?? currentWeight;
    todayCalories = (map['todayCalories'] as num?)?.toInt() ?? todayCalories;
    todayProtein = (map['todayProtein'] as num?)?.toInt() ?? todayProtein;
    todayCarbs = (map['todayCarbs'] as num?)?.toInt() ?? todayCarbs;
    todayFat = (map['todayFat'] as num?)?.toInt() ?? todayFat;
    goal = map['goal'] as String? ?? goal;
    notifyListeners();
  }
}
