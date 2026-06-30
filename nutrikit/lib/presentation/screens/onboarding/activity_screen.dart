import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../onboarding/onboarding_flow.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_select_card.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String? _selected;

  static const _levels = [
    (Icons.weekend_outlined, 'Sedentary', 'Little to no exercise'),
    (Icons.directions_walk, 'Lightly Active', '1–3 workouts a week'),
    (Icons.directions_run, 'Moderately Active', '3–5 workouts a week'),
    (Icons.fitness_center, 'Very Active', '6–7 intense sessions'),
  ];

  void _continue() {
    if (_selected == null) return;
    OnboardingStore.instance.update((d) => d.copyWith(activityLevel: _selected));
    context.push(OnboardingFlow.nextPath('/onboarding/activity')!);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      routePath: '/onboarding/activity',
      title: 'Activity Level',
      subtitle: 'How active are you day to day?',
      nextEnabled: _selected != null,
      onNext: _continue,
      body: Column(
        children: _levels.map((l) {
          return OnboardingSelectCard(
            icon: l.$1,
            title: l.$2,
            subtitle: l.$3,
            selected: _selected == l.$2,
            onTap: () => setState(() => _selected = l.$2),
          );
        }).toList(),
      ),
    );
  }
}
