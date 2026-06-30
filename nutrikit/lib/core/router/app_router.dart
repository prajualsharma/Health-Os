import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/meal.dart';
import '../../data/models/recipe.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/auth/phone_screen.dart';
import '../../presentation/screens/main/cart_screen.dart';
import '../../presentation/screens/main/food_screen.dart';
import '../../presentation/screens/main/gym_screen.dart';
import '../../presentation/screens/main/home_screen.dart';
import '../../presentation/screens/main/main_shell.dart';
import '../../presentation/screens/main/meal_detail_screen.dart';
import '../../presentation/screens/main/order_confirm_screen.dart';
import '../../presentation/screens/main/profile_screen.dart';
import '../../presentation/screens/main/progress_screen.dart';
import '../../presentation/screens/main/recipe_detail_screen.dart';
import '../../presentation/screens/main/tracking_screen.dart';
import '../../presentation/screens/onboarding/activity_screen.dart';
import '../../presentation/screens/onboarding/age_screen.dart';
import '../../presentation/screens/onboarding/calculating_screen.dart';
import '../../presentation/screens/onboarding/city_screen.dart';
import '../../presentation/screens/onboarding/diet_screen.dart';
import '../../presentation/screens/onboarding/email_screen.dart';
import '../../presentation/screens/onboarding/goal_screen.dart';
import '../../presentation/screens/onboarding/height_screen.dart';
import '../../presentation/screens/onboarding/intro_screen.dart';
import '../../presentation/screens/onboarding/medical_screen.dart';
import '../../presentation/screens/onboarding/meal_system_picker_screen.dart';
import '../../presentation/screens/onboarding/name_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/onboarding/pace_screen.dart';
import '../../presentation/screens/onboarding/results_screen.dart';
import '../../presentation/screens/onboarding/sex_screen.dart';
import '../../presentation/screens/onboarding/splash_screen.dart';
import '../../presentation/screens/onboarding/target_weight_screen.dart';
import '../../presentation/screens/onboarding/weight_screen.dart';
import '../../presentation/providers/onboarding_store.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    redirect: _guardRegistrationSession,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
        redirect: (context, state) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.tokenKey);
          if (token != null && token.isNotEmpty) {
            return '/home/dashboard';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth/phone',
        builder: (context, state) => const PhoneScreen(),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) => const OTPScreen(),
      ),
      GoRoute(
        path: '/onboarding/intro',
        builder: (context, state) => const IntroScreen(),
      ),
      GoRoute(
        path: '/onboarding/goals',
        builder: (context, state) => const GoalScreen(),
      ),
      GoRoute(
        path: '/onboarding/sex',
        builder: (context, state) => const SexScreen(),
      ),
      GoRoute(
        path: '/onboarding/age',
        builder: (context, state) => const AgeScreen(),
      ),
      GoRoute(
        path: '/onboarding/height',
        builder: (context, state) => const HeightScreen(),
      ),
      GoRoute(
        path: '/onboarding/weight',
        builder: (context, state) => const WeightScreen(),
      ),
      GoRoute(
        path: '/onboarding/target-weight',
        builder: (context, state) => const TargetWeightScreen(),
      ),
      GoRoute(
        path: '/onboarding/pace',
        builder: (context, state) => const PaceScreen(),
      ),
      GoRoute(
        path: '/onboarding/medical',
        builder: (context, state) => const MedicalScreen(),
      ),
      GoRoute(
        path: '/onboarding/city',
        builder: (context, state) => const CityScreen(),
      ),
      GoRoute(
        path: '/onboarding/name',
        builder: (context, state) => const NameScreen(),
      ),
      GoRoute(
        path: '/onboarding/activity',
        builder: (context, state) => const ActivityScreen(),
      ),
      GoRoute(
        path: '/onboarding/diet',
        builder: (context, state) => const DietScreen(),
      ),
      GoRoute(
        path: '/onboarding/email',
        builder: (context, state) => const EmailScreen(),
      ),
      GoRoute(
        path: '/onboarding/calculating',
        builder: (context, state) => const CalculatingScreen(),
      ),
      GoRoute(
        path: '/onboarding/results',
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: '/onboarding/meal-system',
        builder: (context, state) => const MealSystemPickerScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/dashboard',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/food',
                builder: (context, state) {
                  final segment =
                      foodSegmentFromQuery(state.uri.queryParameters['segment']);
                  return FoodScreen(initialSegment: segment);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/gym',
                builder: (context, state) => const GymScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/plan',
        redirect: (context, state) => '/home/food?segment=plan',
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/progress',
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            const _DeepLinkScaffold(title: 'Progress', child: ProgressScreen()),
      ),
      GoRoute(
        path: '/recipe-detail',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final recipe = state.extra as Recipe?;
          if (recipe == null) {
            return const Scaffold(
              body: Center(child: Text('Recipe not found')),
            );
          }
          return RecipeDetailScreen(recipe: recipe);
        },
      ),
      GoRoute(
        path: '/meal-detail',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final meal = state.extra as Meal?;
          if (meal == null) {
            return const Scaffold(
              body: Center(child: Text('Meal not found')),
            );
          }
          return MealDetailScreen(meal: meal);
        },
      ),
      GoRoute(
        path: '/cart',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/order-confirm',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const OrderConfirmScreen(),
      ),
      GoRoute(
        path: '/order-tracking',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const TrackingScreen(),
      ),
    ],
  );

  static const _postRegistrationOnboarding = {
    '/onboarding/results',
    '/onboarding/meal-system',
  };

  /// Blocks profile onboarding unless the user completed phone OTP verify.
  static Future<String?> _guardRegistrationSession(
    BuildContext context,
    GoRouterState state,
  ) async {
    final loc = state.matchedLocation;
    if (!loc.startsWith('/onboarding/') ||
        _postRegistrationOnboarding.contains(loc)) {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString(AppConstants.tokenKey);
    if (authToken != null && authToken.isNotEmpty) {
      return null;
    }

    final regToken = prefs.getString(AppConstants.registrationTokenKey);
    final phone = prefs.getString(AppConstants.registrationPhoneKey);
    if (regToken == null || regToken.isEmpty || phone == null || phone.isEmpty) {
      return '/auth/phone';
    }

    if (OnboardingStore.instance.data.phone.isEmpty) {
      OnboardingStore.instance.update((d) => d.copyWith(phone: phone));
    }
    return null;
  }
}

/// Wraps a shell screen in a standalone Scaffold (with a back button) so it can
/// be presented as a deep-link route outside the bottom-nav shell.
class _DeepLinkScaffold extends StatelessWidget {
  const _DeepLinkScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: Text(title),
      ),
      body: child,
    );
  }
}
