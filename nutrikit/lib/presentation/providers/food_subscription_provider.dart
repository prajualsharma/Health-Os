import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/meal_system.dart';

class FoodSubscriptionProvider extends ChangeNotifier {
  FoodSubscriptionProvider() {
    _restore();
  }

  static const _key = 'meal_system';

  MealSystemType _system = MealSystemType.none;
  bool _loaded = false;

  MealSystemType get system => _system;
  bool get isSubscribed => _system.isSubscribed;
  bool get loaded => _loaded;
  List<String> get activeSlots => _system.slots;

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _system = MealSystemTypeX.fromKey(prefs.getString(_key));
    _loaded = true;
    notifyListeners();
  }

  Future<void> subscribe(MealSystemType type) async {
    if (type == MealSystemType.none) return;
    _system = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, type.storageKey);
    notifyListeners();
  }

  Future<void> cancel() async {
    _system = MealSystemType.none;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, MealSystemType.none.storageKey);
    notifyListeners();
  }
}
