import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GymMembershipProvider extends ChangeNotifier {
  GymMembershipProvider() {
    _restore();
  }

  static const _gymKey = 'linked_gym_id';
  static const _trainerKey = 'assigned_trainer';

  String? _linkedGymId;
  String? _assignedTrainerName;
  bool _loaded = false;

  String? get linkedGymId => _linkedGymId;
  String? get assignedTrainerName => _assignedTrainerName;
  bool get hasLinkedGym => _linkedGymId != null;
  bool get loaded => _loaded;

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _linkedGymId = prefs.getString(_gymKey);
    _assignedTrainerName = prefs.getString(_trainerKey);
    _loaded = true;
    notifyListeners();
  }

  Future<void> joinGym({
    required String gymId,
    required String trainerName,
  }) async {
    _linkedGymId = gymId;
    _assignedTrainerName = trainerName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gymKey, gymId);
    await prefs.setString(_trainerKey, trainerName);
    notifyListeners();
  }

  Future<void> leaveGym() async {
    _linkedGymId = null;
    _assignedTrainerName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gymKey);
    await prefs.remove(_trainerKey);
    notifyListeners();
  }
}
