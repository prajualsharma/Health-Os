import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/select_card.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int? _selected;

  static const _levels = [
    ['🛋️', 'Sedentary', 'Little to no exercise'],
    ['🚶', 'Lightly Active', '1–3 workouts a week'],
    ['🏃', 'Moderately Active', '3–5 workouts a week'],
    ['🏋️', 'Very Active', '6–7 intense sessions'],
  ];

  void _continue() {
    if (_selected == null) return;
    OnboardingStore.instance
        .update((d) => d.copyWith(activityLevel: _levels[_selected!][1]));
    context.go('/onboarding/diet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STEP 4 OF 5',
                  style: AppTypography.label.copyWith(color: AppColors.green)),
              const SizedBox(height: 6),
              Text('Activity Level', style: AppTypography.h1),
              const SizedBox(height: 4),
              Text('How active are you day to day?',
                  style: AppTypography.caption),
              const SizedBox(height: 24),
              ...List.generate(_levels.length, (i) {
                final l = _levels[i];
                return SelectCard(
                  emoji: l[0],
                  title: l[1],
                  subtitle: l[2],
                  selected: _selected == i,
                  onTap: () => setState(() => _selected = i),
                );
              }),
              const SizedBox(height: 16),
              AppButton(
                label: 'Continue',
                onPressed: _selected == null ? null : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
