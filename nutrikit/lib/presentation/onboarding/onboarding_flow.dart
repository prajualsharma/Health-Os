/// Ordered onboarding steps after phone verification (for progress bar).
class OnboardingFlow {
  OnboardingFlow._();

  static const steps = <String>[
    '/onboarding/name',
    '/onboarding/goals',
    '/onboarding/sex',
    '/onboarding/age',
    '/onboarding/height',
    '/onboarding/weight',
    '/onboarding/target-weight',
    '/onboarding/pace',
    '/onboarding/medical',
    '/onboarding/city',
    '/onboarding/activity',
    '/onboarding/diet',
    '/onboarding/email',
  ];

  static int indexOf(String path) {
    final i = steps.indexOf(path);
    return i < 0 ? 0 : i;
  }

  static double progress(String path) => (indexOf(path) + 1) / steps.length;

  static String? nextPath(String path) {
    final i = indexOf(path);
    if (i < 0 || i >= steps.length - 1) return null;
    return steps[i + 1];
  }

  static String? stepKeyFromPath(String path) {
    if (!path.startsWith('/onboarding/')) return null;
    return path.substring('/onboarding/'.length);
  }

  static String routeForStep(String stepKey) => '/onboarding/$stepKey';
}
