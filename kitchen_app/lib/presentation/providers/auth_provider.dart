import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/auth.dart';
import '../../data/models/models.dart';
import '../../data/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({ApiService? api}) : _api = api ?? ApiService.instance {
    _loadSession();
  }

  final ApiService _api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;
  String? _registrationToken;
  String? _pendingPhone;
  bool _isLoading = false;
  String? _error;
  bool _lastDevMode = false;
  SessionRole? _role;
  List<StaffMembership> _memberships = [];

  String? get token => _token;
  String? get registrationToken => _registrationToken;
  String? get pendingPhone => _pendingPhone;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;
  bool get lastDevMode => _lastDevMode;
  SessionRole? get role => _role;
  List<StaffMembership> get memberships => _memberships;

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final roleName = prefs.getString(AppConstants.roleKey);
    if (token != null && token.isNotEmpty) {
      _token = token;
      if (roleName != null) {
        try {
          _role = SessionRole.values.byName(roleName);
        } catch (_) {
          _role = null;
        }
      }
      await _refreshMemberships();
      notifyListeners();
    }
  }

  Future<void> _refreshMemberships() async {
    if (_token == null) return;
    try {
      _memberships = await _api.getStaffMemberships();
      if (_role == null) {
        final derived = _memberships
            .map((m) => m.sessionRole)
            .whereType<SessionRole>()
            .firstOrNull;
        if (derived != null) {
          _role = derived;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConstants.roleKey, derived.name);
        }
      }
    } catch (_) {
      _memberships = [];
    }
  }

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

  Future<bool?> verifyPhone(String phone, String otp) async {
    _setLoading(true);
    try {
      final res = await _api.verifyPhone(phone, otp);
      _error = null;
      if (res.newUser) {
        _registrationToken = res.registrationToken;
        _pendingPhone = phone;
        return true;
      }
      await _persistTokens(
        res.accessToken ?? 'mock-access-token',
        res.refreshToken,
      );
      await _refreshMemberships();
      return false;
    } on ApiException catch (e) {
      _error = e.message;
      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerPhone(String name) async {
    final phone = _pendingPhone;
    final token = _registrationToken;
    if (phone == null || token == null) {
      _error = 'Session expired. Please log in again.';
      return false;
    }

    _setLoading(true);
    try {
      final res = await _api.registerPhone(
        phone: phone,
        registrationToken: token,
        name: name,
      );
      _error = null;
      await _persistTokens(res.accessToken, res.refreshToken);
      _registrationToken = null;
      _pendingPhone = null;
      await _refreshMemberships();
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
    final match = _memberships
        .where((m) => m.sessionRole == role)
        .cast<StaffMembership?>()
        .firstOrNull;
    if (match != null) {
      try {
        await _api.setActiveScope(
          portal: match.portal,
          scopeType: match.scopeType,
          scopeId: match.scopeId,
        );
      } catch (_) {}
    }
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
    _memberships = [];
    _registrationToken = null;
    _pendingPhone = null;
    notifyListeners();
  }
}
