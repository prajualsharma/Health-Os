import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({ApiService? api}) : _api = api ?? ApiService.instance;

  final ApiService _api;

  UserProfile? profile;
  int calorieTarget = 0;
  int proteinTarget = 0;
  int carbTarget = 0;
  int fatTarget = 0;
  double currentWeight = 0;
  int todayCalories = 0;
  int todayProtein = 0;
  int todayCarbs = 0;
  int todayFat = 0;
  String goal = '';

  bool isLoading = false;
  String? error;

  Future<void> loadProfile() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final p = await _api.getProfile();
      profile = p;
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
    if (profile != null) {
      profile = UserProfile(
        name: profile!.name,
        email: profile!.email,
        initials: profile!.initials,
        goal: profile!.goal,
        currentWeight: weight,
        targetWeight: profile!.targetWeight,
        height: profile!.height,
        calorieTarget: profile!.calorieTarget,
        proteinTarget: profile!.proteinTarget,
        carbTarget: profile!.carbTarget,
        fatTarget: profile!.fatTarget,
        plan: profile!.plan,
        gymName: profile!.gymName,
      );
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{
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
    };
    if (profile != null) {
      map.addAll(profile!.toJson());
    }
    await prefs.setString(AppConstants.profileKey, jsonEncode(map));
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
    if (map['name'] != null) {
      profile = UserProfile.fromJson(map);
    }
    notifyListeners();
  }

  void clear() {
    profile = null;
    calorieTarget = 0;
    proteinTarget = 0;
    carbTarget = 0;
    fatTarget = 0;
    currentWeight = 0;
    todayCalories = 0;
    todayProtein = 0;
    todayCarbs = 0;
    todayFat = 0;
    goal = '';
    error = null;
    notifyListeners();
  }
}
