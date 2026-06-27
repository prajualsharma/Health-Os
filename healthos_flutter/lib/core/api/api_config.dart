class ApiConfig {
  ApiConfig._();

  /// API gateway base URL. The gateway routes `/auth/**` and `/me/**` to
  /// user-management-service.
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// When true, the auth client returns canned data so the prototype runs
  /// without a live backend.
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
}
