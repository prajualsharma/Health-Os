import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/services/api_service.dart';
import '../providers/onboarding_store.dart';
import 'onboarding_flow.dart';

/// Fire-and-forget onboarding progress pings for abandoned-signup reminders.
class OnboardingProgressReporter {
  OnboardingProgressReporter._();

  static String? _lastRoute;

  static void trackRoute(String routePath) {
    if (routePath.startsWith('/onboarding/')) {
      _lastRoute = routePath;
    }
  }

  static Future<void> reportRoute(String routePath) async {
    final step = OnboardingFlow.stepKeyFromPath(routePath);
    if (step == null) return;
    await _report(step);
  }

  static Future<void> reportLastTracked() async {
    final route = _lastRoute;
    if (route == null) return;
    await reportRoute(route);
  }

  static Future<void> _report(String step) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.registrationTokenKey);
    if (token == null || token.isEmpty) return;

    final store = OnboardingStore.instance.data;
    final firstName = _firstName(store.name);
    final email = store.email.isNotEmpty ? store.email : null;

    try {
      await ApiService.instance.updateOnboardingProgress(
        registrationToken: token,
        step: step,
        firstName: firstName,
        email: email,
      );
    } catch (_) {
      // Best-effort; do not block onboarding UI.
    }
  }

  static String? _firstName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split(RegExp(r'\s+'));
    return parts.first;
  }
}
