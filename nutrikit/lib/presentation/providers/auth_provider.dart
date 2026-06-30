import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/auth.dart';
import '../../data/services/api_service.dart';
import 'onboarding_store.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({ApiService? api}) : _api = api ?? ApiService.instance {
    _restoreSession();
  }

  final ApiService _api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;
  String? _registrationToken;
  bool _isLoading = false;
  String? _error;
  bool _lastDevMode = false;
  bool _lastOtpDelivered = false;
  String? _lastDeliveryEmail;

  String? get token => _token;
  String? get registrationToken => _registrationToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;
  bool get lastDevMode => _lastDevMode;
  bool get lastOtpDelivered => _lastOtpDelivered;
  String? get lastDeliveryEmail => _lastDeliveryEmail;

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _registrationToken = prefs.getString(AppConstants.registrationTokenKey);
    _token = prefs.getString(AppConstants.tokenKey);
    await _hydrateOnboardingPhone(prefs);
    notifyListeners();
  }

  /// Reloads phone + registration token from disk (survives refresh / deep links).
  Future<void> ensureRegistrationSession() async {
    final prefs = await SharedPreferences.getInstance();
    _registrationToken = prefs.getString(AppConstants.registrationTokenKey);
    await _hydrateOnboardingPhone(prefs);
    notifyListeners();
  }

  Future<void> _hydrateOnboardingPhone(SharedPreferences prefs) async {
    final registrationPhone = prefs.getString(AppConstants.registrationPhoneKey);
    if (registrationPhone != null && registrationPhone.isNotEmpty) {
      final store = OnboardingStore.instance;
      if (store.data.phone.isEmpty) {
        store.update((d) => d.copyWith(phone: registrationPhone));
      }
    }
  }

  bool get hasRegistrationSession =>
      _registrationToken != null && _registrationToken!.isNotEmpty;

  Future<void> _persistRegistrationSession(String phone, String token) async {
    _registrationToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.registrationTokenKey, token);
    await prefs.setString(AppConstants.registrationPhoneKey, phone);
  }

  Future<void> _clearRegistrationSession() async {
    _registrationToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.registrationTokenKey);
    await prefs.remove(AppConstants.registrationPhoneKey);
  }

  /// Step 1: request an email OTP. Returns true if the OTP was sent.
  Future<bool> initiatePhone(String phone) async {
    _setLoading(true);
    try {
      final res = await _api.initiatePhone(phone);
      _lastDevMode = res.devMode;
      _lastOtpDelivered = res.otpDelivered;
      _lastDeliveryEmail = res.deliveryEmail;
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

  /// Step 2: verify the OTP. Returns true for a new user (needs onboarding),
  /// false for a returning user (now logged in), null on error.
  Future<bool?> verifyPhone(String phone, String otp) async {
    _setLoading(true);
    try {
      final res = await _api.verifyPhone(phone, otp);
      _error = null;
      if (res.newUser) {
        _registrationToken = res.registrationToken;
        OnboardingStore.instance.update((d) => d.copyWith(phone: phone));
        if (res.registrationToken != null && res.registrationToken!.isNotEmpty) {
          await _persistRegistrationSession(phone, res.registrationToken!);
        } else {
          _error = 'Could not start registration. Please try again.';
          return null;
        }
        return true;
      }
      await _clearRegistrationSession();
      await _persistTokens(res.accessToken!, res.refreshToken);
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

  /// Step 3 (new users): complete registration with the collected onboarding data.
  Future<RegisterResult?> registerPhone(OnboardingData data) async {
    _setLoading(true);
    try {
      await ensureRegistrationSession();
      final prefs = await SharedPreferences.getInstance();
      final phone = data.phone.isNotEmpty
          ? data.phone
          : prefs.getString(AppConstants.registrationPhoneKey) ?? '';
      final token = _registrationToken ??
          prefs.getString(AppConstants.registrationTokenKey) ??
          '';

      if (phone.isEmpty || token.isEmpty) {
        _error = 'Please verify your phone number before continuing.';
        return null;
      }

      final payload =
          data.phone.isEmpty ? data.copyWith(phone: phone) : data;
      final res = await _api.registerPhone(payload, token);
      await _persistTokens(res.accessToken, res.refreshToken);
      await _clearRegistrationSession();
      await prefs.setBool(AppConstants.onboardingDoneKey, true);
      _error = null;
      return res;
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
    await _clearRegistrationSession();
    _token = null;
    notifyListeners();
  }
}
