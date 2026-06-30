import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/profile_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bounce;
  late final AnimationController _dots;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _dots = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _navigate();
  }

  Future<void> _navigate() async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final registrationToken = prefs.getString(AppConstants.registrationTokenKey);
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      await context.read<ProfileProvider>().loadProfile();
      if (!mounted) return;
      context.go('/home/dashboard');
    } else if (registrationToken != null && registrationToken.isNotEmpty) {
      context.go('/onboarding/intro');
    } else {
      context.go('/auth/phone');
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.9,
            colors: [AppColors.greenGlow, AppColors.bg],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.06).animate(
                  CurvedAnimation(parent: _bounce, curve: Curves.easeInOut),
                ),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppColors.greenGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: AppColors.greenGlow, blurRadius: 30),
                    ],
                  ),
                  child: const Center(
                    child: Text('🥗', style: TextStyle(fontSize: 40)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'NutriKit',
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your kitchen. Your macros.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 48),
              AnimatedBuilder(
                animation: _dots,
                builder: (context, _) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      final t = (_dots.value + i / 3) % 1.0;
                      final scale = 0.6 + 0.4 * (1 - (t - 0.5).abs() * 2);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
