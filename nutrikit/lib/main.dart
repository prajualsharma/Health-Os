import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'data/services/api_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/food_subscription_provider.dart';
import 'presentation/providers/gym_membership_provider.dart';
import 'presentation/providers/profile_provider.dart';
import 'platform/mobile/mobile_main.dart'
    if (dart.library.html) 'platform/web/web_main.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configurePlatform();

  // Global 401 handling: drop the user back to the phone entry screen.
  ApiService.instance.onUnauthorized = () => AppRouter.router.go('/auth/phone');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()..restoreFromCache()),
        ChangeNotifierProvider(create: (_) => FoodSubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => GymMembershipProvider()),
      ],
      child: const NutriKitApp(),
    ),
  );
}
