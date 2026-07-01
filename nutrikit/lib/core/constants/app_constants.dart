class AppConstants {
  AppConstants._();

  static const String appName = 'NutriKit';
  static const String tagline = 'Your kitchen. Your macros.';

  /// Points at the API gateway, which routes `/auth/**` to user-management-service.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// When true, the API service serves in-app mock data so the app runs
  /// standalone on all platforms without a live backend. Controls the content
  /// endpoints (dashboard / meal plan / kitchen / orders / progress / profile),
  /// which the HealthOS backend does not implement yet.
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  /// Controls only the phone auth + registration flow. The HealthOS backend
  /// implements `/auth/**` (and persists the user + profile to Postgres on
  /// `register-phone`), so this can be `false` to run real auth even while
  /// `useMock` keeps the (not-yet-built) content endpoints on mock data.
  /// Defaults to [useMock] so existing builds are unaffected.
  static const bool mockAuth = bool.fromEnvironment(
    'MOCK_AUTH',
    defaultValue: useMock,
  );

  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String registrationTokenKey = 'registration_token';
  static const String registrationPhoneKey = 'registration_phone';
  static const String onboardingDoneKey = 'onboarding_done';
  static const String profileKey = 'profile_cache';

  /// Bottom scroll inset above the shell bottom nav (inline FAB layout).
  static const double shellScrollBottomPadding = 24;
}
