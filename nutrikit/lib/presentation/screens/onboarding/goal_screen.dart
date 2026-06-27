import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/select_card.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  int? _selected;

  static const _goals = [
    ['🔥', 'Lose Weight', 'Shed fat while keeping muscle'],
    ['💪', 'Gain Muscle', 'Build lean mass with a surplus'],
    ['⚖️', 'Maintain Weight', 'Stay where you are, eat smart'],
    ['🥦', 'Eat Healthier', 'Better food, balanced macros'],
  ];

  void _continue() {
    if (_selected == null) return;
    OnboardingStore.instance
        .update((d) => d.copyWith(goal: _goals[_selected!][1]));
    context.go('/onboarding/body');
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
              Text('STEP 2 OF 5',
                  style: AppTypography.label.copyWith(color: AppColors.green)),
              const SizedBox(height: 6),
              Text("What's your goal?", style: AppTypography.h1),
              const SizedBox(height: 4),
              Text('We tailor your plan around it', style: AppTypography.caption),
              const SizedBox(height: 24),
              ...List.generate(_goals.length, (i) {
                final g = _goals[i];
                return SelectCard(
                  emoji: g[0],
                  title: g[1],
                  subtitle: g[2],
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
