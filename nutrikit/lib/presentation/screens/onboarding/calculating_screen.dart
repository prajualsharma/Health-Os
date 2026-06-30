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

class _CalculatingScreenState extends State<CalculatingScreen> {
  Timer? _rotateTimer;
  int _trustIndex = 0;
  bool _failed = false;

  static const _trustLines = [
    '3 Crore Lives Transformed',
    '2000+ elite coaches',
    'Highly qualified in fitness and nutrition',
    'With the help of our coaches',
  ];

  static const _trustSubs = [
    'With the help of our coaches',
    'Highly qualified in fitness and nutrition',
    'With the help of our coaches',
    'Building your personalized plan',
  ];

  @override
  void initState() {
    super.initState();
    _rotateTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() => _trustIndex = (_trustIndex + 1) % _trustLines.length);
    });
    _run();
  }

  Future<void> _run() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final registrationFuture = _submit();
    await Future<void>.delayed(const Duration(seconds: 3));
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
    final message = auth.error ?? 'Could not save your profile. Please try again.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.red, content: Text(message)),
    );
    final expired = message.toLowerCase().contains('expired') ||
        message.toLowerCase().contains('verify your phone');
    context.go(expired ? '/auth/phone' : '/onboarding/email');
  }

  @override
  void dispose() {
    _rotateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = OnboardingStore.instance.data;
    final goals = data.goals.take(2).toList();
    final weightGoal = data.targetWeight > data.currentWeight
        ? 'Gain ${(data.targetWeight - data.currentWeight).round()} kg'
        : 'Lose ${(data.currentWeight - data.targetWeight).round()} kg';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (goals.isNotEmpty) _summaryTile(Icons.restaurant_menu, goals.first),
                  if (goals.length > 1) ...[
                    const SizedBox(width: 24),
                    _summaryTile(Icons.monitor_weight_outlined, weightGoal),
                  ] else ...[
                    const SizedBox(width: 24),
                    _summaryTile(Icons.monitor_weight_outlined, weightGoal),
                  ],
                ],
              ),
              const Spacer(),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                _trustLines[_trustIndex],
                style: AppTypography.h2.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _trustSubs[_trustIndex],
                style: AppTypography.caption.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryTile(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 28, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTypography.bodyBold.copyWith(fontSize: 13)),
      ],
    );
  }
}
