import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/onboarding/onboarding_pace_card.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';

class PaceScreen extends StatefulWidget {
  const PaceScreen({super.key});

  @override
  State<PaceScreen> createState() => _PaceScreenState();
}

class _PaceScreenState extends State<PaceScreen> {
  String _pace = 'moderate';

  static const _options = [
    ('relaxed', 'Relaxed', '0.25 kg per week', Icons.self_improvement),
    ('gradual', 'Gradual', '0.5 kg per week', Icons.trending_up),
    ('moderate', 'Moderate', '0.75 kg per week', Icons.speed),
    ('rapid', 'Rapid', '1 kg per week', Icons.rocket_launch_outlined),
  ];

  String get _summary {
    final d = OnboardingStore.instance.data;
    final diff = (d.targetWeight - d.currentWeight).abs();
    final weekly = switch (_pace) {
      'relaxed' => 0.25,
      'gradual' => 0.5,
      'rapid' => 1.0,
      _ => 0.75,
    };
    final weeks = diff < 0.5 ? 0 : (diff / weekly).ceil();
    final months = weeks ~/ 4;
    final days = (weeks % 4) * 7;
    final verb = d.targetWeight > d.currentWeight ? 'Gain' : 'Lose';
    if (weeks == 0) return 'You are already at your target weight.';
    return 'You will $verb ${diff.toStringAsFixed(1)} Kg in $months months $days days.';
  }

  void _continue() {
    OnboardingStore.instance.update((d) => d.copyWith(goalPace: _pace));
    context.push(OnboardingFlow.nextPath('/onboarding/pace')!);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      routePath: '/onboarding/pace',
      title: 'How fast do you want to reach your goal?',
      subtitle: 'This is a good, sustainable pace to reach your goal weight.',
      onNext: _continue,
      body: Column(
        children: [
          ..._options.map((o) => OnboardingPaceCard(
                icon: o.$4,
                title: o.$2,
                rateLabel: o.$3,
                selected: _pace == o.$1,
                onTap: () => setState(() => _pace = o.$1),
              )),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              _summary,
              style: AppTypography.bodyBold.copyWith(
                color: AppColors.primaryDark,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
