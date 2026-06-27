import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';

class AuthException implements Exception {
  AuthException(this.message, {this.code});
  final String message;
  final String? code;
  @override
  String toString() => 'AuthException($code): $message';
}

/// Result of `POST /auth/phone/verify`.
class PhoneVerifyResult {
  const PhoneVerifyResult({
    required this.newUser,
    this.accessToken,
    this.refreshToken,
    this.registrationToken,
  });

  final bool newUser;
  final String? accessToken;
  final String? refreshToken;
  final String? registrationToken;

  factory PhoneVerifyResult.fromJson(Map<String, dynamic> json) =>
      PhoneVerifyResult(
        newUser: json['newUser'] as bool? ?? false,
        accessToken: json['accessToken'] as String?,
        refreshToken: json['refreshToken'] as String?,
        registrationToken: json['registrationToken'] as String?,
      );
}

/// A single scoped membership returned by `GET /me/memberships`.
class Membership {
  const Membership({
    required this.portal,
    required this.scopeType,
    required this.scopeId,
    required this.role,
  });

  final String portal;
  final String scopeType;
  final String scopeId;
  final String role;

  factory Membership.fromJson(Map<String, dynamic> json) => Membership(
        portal: json['portal']?.toString() ?? '',
        scopeType: json['scopeType']?.toString() ?? '',
        scopeId: json['scopeId']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
      );
}

class AuthApi {
  AuthApi()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  final Dio _dio;

  bool get _mock => ApiConfig.useMock;

  Future<bool> initiatePhone(String phone) async {
    if (_mock) return true;
    return _guarded(() async {
      final res =
          await _dio.post('/auth/phone/initiate', data: {'phone': phone});
      return (res.data as Map)['otpSent'] as bool? ?? false;
    });
  }

  Future<PhoneVerifyResult> verifyPhone(String phone, String otp) async {
    if (_mock) {
      return const PhoneVerifyResult(
          newUser: false,
          accessToken: 'mock-access-token',
          refreshToken: 'mock-refresh-token');
    }
    return _guarded(() async {
      final res = await _dio
          .post('/auth/phone/verify', data: {'phone': phone, 'otp': otp});
      return PhoneVerifyResult.fromJson(res.data as Map<String, dynamic>);
    });
  }

  /// Minimal registration for a brand-new phone (B2B owner onboarding is a later
  /// phase; this creates the account so login can proceed).
  Future<String> register({
    required String phone,
    required String registrationToken,
    required String name,
  }) async {
    if (_mock) return 'mock-access-token';
    return _guarded(() async {
      final res = await _dio.post('/auth/register-phone', data: {
        'phone': phone,
        'registrationToken': registrationToken,
        'name': name,
      });
      return (res.data as Map)['accessToken'] as String? ?? '';
    });
  }

  Future<List<Membership>> getMemberships(String accessToken) async {
    if (_mock) return const [];
    return _guarded(() async {
      final res = await _dio.get(
        '/me/memberships',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final list = (res.data as Map)['memberships'] as List? ?? const [];
      return list
          .map((e) => Membership.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<T> _guarded<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final data = e.response?.data;
      var message = e.message ?? 'Network error';
      String? code;
      if (data is Map) {
        if (data['message'] != null) message = data['message'].toString();
        if (data['code'] != null) code = data['code'].toString();
      } else if (e.type == DioExceptionType.connectionError) {
        message = 'Cannot reach the server. Check your connection.';
      }
      throw AuthException(message, code: code);
    }
  }
}

final authApiProvider = Provider<AuthApi>((ref) => AuthApi());
