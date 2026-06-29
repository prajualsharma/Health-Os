import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_store.dart';
import '../../providers/profile_provider.dart';

class CalculatingScreen extends StatefulWidget {
  const CalculatingScreen({super.key});

  @override
  State<CalculatingScreen> createState() => _CalculatingScreenState();
}

class _CalculatingScreenState extends State<CalculatingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;
  Timer? _timer;
  int _step = 0;
  bool _failed = false;

  static const _steps = [
    'Analyzing your body stats',
    'Calculating your TDEE',
    'Balancing your macros',
    'Matching meals to your taste',
    'Finalizing your daily plan',
  ];

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _run();
  }

  Future<void> _run() async {
    final registrationFuture = _submit();
    await _revealSteps();
    await registrationFuture;
    if (!mounted || _failed) return;
    context.go('/onboarding/results');
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final res = await auth.registerPhone(OnboardingStore.instance.data);
    if (!mounted) return;
    if (res != null) {
      OnboardingStore.instance.result = res.targets;
      await context.read<ProfileProvider>().loadProfile();
      return;
    }

    _failed = true;
    _timer?.cancel();
    final message = auth.error ?? 'Could not save your profile. Please try again.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.red,
        content: Text(message),
      ),
    );
    context.go('/auth/otp');
  }

  Future<void> _revealSteps() async {
    final completer = Completer<void>();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      if (_failed) {
        t.cancel();
        if (!completer.isCompleted) completer.complete();
        return;
      }
      if (_step >= _steps.length) {
        t.cancel();
        Future<void>.delayed(const Duration(milliseconds: 900), () {
          if (!completer.isCompleted) completer.complete();
        });
      } else {
        setState(() => _step++);
      }
    });
    return completer.future;
  }

  @override
  void dispose() {
    _spin.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 0.9,
            colors: [AppColors.greenGlow, AppColors.bg],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RotationTransition(
                  turns: _spin,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppColors.greenGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(color: AppColors.greenGlow, blurRadius: 30),
                      ],
                    ),
                    child: const Center(
                      child: Text('🧠', style: TextStyle(fontSize: 44)),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text('AI is working…', style: AppTypography.h2),
                const SizedBox(height: 36),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: List.generate(_steps.length, (i) {
                      final done = i < _step;
                      final active = i == _step;
                      final visible = i <= _step;
                      return AnimatedOpacity(
                        opacity: visible ? 1 : 0.25,
                        duration: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: done
                                      ? AppColors.green
                                      : active
                                          ? AppColors.accent
                                          : AppColors.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: done
                                    ? const Icon(Icons.check,
                                        size: 13, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Text(
                                _steps[i],
                                style: TextStyle(
                                  color: done
                                      ? AppColors.green
                                      : active
                                          ? AppColors.accent
                                          : AppColors.muted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
