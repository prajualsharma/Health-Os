import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/models.dart';
import '../../data/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({ApiService? api}) : _api = api ?? ApiService.instance;

  final ApiService _api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _lastDevMode = false;
  SessionRole? _role;

  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;
  bool get lastDevMode => _lastDevMode;
  SessionRole? get role => _role;

  Future<bool> initiatePhone(String phone) async {
    _setLoading(true);
    try {
      final res = await _api.initiatePhone(phone);
      _lastDevMode = res.devMode;
      _error = null;
      return res.otpSent;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verifies the OTP and logs in. Returns true on success.
  Future<bool> verifyPhone(String phone, String otp) async {
    _setLoading(true);
    try {
      final res = await _api.verifyPhone(phone, otp);
      _error = null;
      await _persistTokens(
        res.accessToken ?? 'mock-access-token',
        res.refreshToken,
      );
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setRole(SessionRole role) async {
    _role = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.roleKey, role.name);
    notifyListeners();
  }

  Future<void> _persistTokens(String access, String? refresh) async {
    _token = access;
    await _storage.write(key: AppConstants.tokenKey, value: access);
    if (refresh != null && refresh.isNotEmpty) {
      await _storage.write(key: AppConstants.refreshTokenKey, value: refresh);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, access);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.roleKey);
    _token = null;
    _role = null;
    notifyListeners();
  }
}
