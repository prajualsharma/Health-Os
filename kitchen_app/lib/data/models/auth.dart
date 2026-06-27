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
