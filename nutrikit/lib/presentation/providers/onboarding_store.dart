import '../../data/models/auth.dart';

/// Lightweight singleton that accumulates onboarding selections across the
/// multi-step flow before submission.
class OnboardingStore {
  OnboardingStore._();
  static final OnboardingStore instance = OnboardingStore._();

  OnboardingData data = const OnboardingData();
  OnboardingResponse? result;

  void update(OnboardingData Function(OnboardingData) fn) {
    data = fn(data);
  }

  void reset() {
    data = const OnboardingData();
    result = null;
  }
}
