class AppConstants {
  AppConstants._();

  static const String appName = 'HealthOS Cloud Kitchen';
  static const String tagline = 'Run your cloud kitchen.';

  /// API gateway base URL. The gateway routes `/auth/**` to user-management
  /// and `/kitchen/**` to kitchen-service.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// When true, all data (kitchens, menu, orders) is served from in-app mock
  /// data so the app runs standalone with no backend.
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  /// Controls only the phone auth flow. Defaults to [useMock].
  static const bool mockAuth = bool.fromEnvironment(
    'MOCK_AUTH',
    defaultValue: useMock,
  );

  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String roleKey = 'session_role';
}
