import 'models.dart';

class PhoneInitiateResult {
  const PhoneInitiateResult({
    required this.exists,
    required this.otpSent,
    required this.devMode,
  });

  final bool exists;
  final bool otpSent;
  final bool devMode;

  factory PhoneInitiateResult.fromJson(Map<String, dynamic> json) =>
      PhoneInitiateResult(
        exists: json['exists'] as bool? ?? false,
        otpSent: json['otpSent'] as bool? ?? true,
        devMode: json['devMode'] as bool? ?? false,
      );
}

class PhoneVerifyResult {
  const PhoneVerifyResult({
    required this.newUser,
    this.registrationToken,
    this.accessToken,
    this.refreshToken,
  });

  final bool newUser;
  final String? registrationToken;
  final String? accessToken;
  final String? refreshToken;

  factory PhoneVerifyResult.fromJson(Map<String, dynamic> json) =>
      PhoneVerifyResult(
        newUser: json['newUser'] as bool? ?? false,
        registrationToken: json['registrationToken'] as String?,
        accessToken: json['accessToken'] as String?,
        refreshToken: json['refreshToken'] as String?,
      );
}

class RegisterResult {
  const RegisterResult({
    required this.accessToken,
    this.refreshToken,
  });

  final String accessToken;
  final String? refreshToken;

  factory RegisterResult.fromJson(Map<String, dynamic> json) => RegisterResult(
        accessToken: json['accessToken'] as String? ?? '',
        refreshToken: json['refreshToken'] as String?,
      );
}

class StaffMembership {
  const StaffMembership({
    required this.portal,
    required this.scopeType,
    required this.scopeId,
    required this.role,
  });

  final String portal;
  final String scopeType;
  final String scopeId;
  final String role;

  factory StaffMembership.fromJson(Map<String, dynamic> json) => StaffMembership(
        portal: json['portal']?.toString() ?? '',
        scopeType: json['scopeType']?.toString() ?? '',
        scopeId: json['scopeId']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
      );

  SessionRole? get sessionRole {
    if (portal.toUpperCase() != 'KITCHEN') return null;
    switch (role.toUpperCase()) {
      case 'CORPORATE':
        return SessionRole.corporate;
      case 'KITCHEN_STAFF':
        return SessionRole.kitchen;
      default:
        return null;
    }
  }
}
