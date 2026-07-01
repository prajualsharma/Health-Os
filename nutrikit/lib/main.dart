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

  // Global stale-session handling: clear cache and return to phone login.
  ApiService.instance.onUnauthorized = () {
    final ctx = AppRouter.router.routerDelegate.navigatorKey.currentContext;
    if (ctx != null) {
      ctx.read<AuthProvider>().logout();
      ctx.read<ProfileProvider>().clear();
      ctx.read<ProfileProvider>().clearCache();
    }
    AppRouter.router.go('/auth/phone');
  };

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
