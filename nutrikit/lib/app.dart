import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/onboarding/onboarding_progress_reporter.dart';

class NutriKitApp extends StatefulWidget {
  const NutriKitApp({super.key});

  @override
  State<NutriKitApp> createState() => _NutriKitAppState();
}

class _NutriKitAppState extends State<NutriKitApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      OnboardingProgressReporter.reportLastTracked();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
