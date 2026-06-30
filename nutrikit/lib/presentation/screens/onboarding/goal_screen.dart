import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/auth.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_select_card.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final Set<String> _selected = {};

  static const _goals = [
    (Icons.restaurant_menu, 'Diet Plan'),
    (Icons.monitor_weight_outlined, 'Weight Loss'),
    (Icons.fitness_center, 'Gain Muscle'),
    (Icons.local_fire_department_outlined, 'Calorie Tracker'),
    (Icons.directions_run, 'Workouts'),
    (Icons.eco_outlined, 'Eat Healthier'),
    (Icons.camera_alt_outlined, 'Meal Snap'),
  ];

  void _toggle(String goal) {
    setState(() {
      if (_selected.contains(goal)) {
        _selected.remove(goal);
      } else {
        _selected.add(goal);
      }
    });
  }

  void _continue() {
    final goals = _selected.toList();
    final primary = OnboardingData.primaryGoal(goals);
    OnboardingStore.instance.update(
      (d) => d.copyWith(goals: goals, goal: primary),
    );
    context.push(OnboardingFlow.nextPath('/onboarding/goals')!);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      routePath: '/onboarding/goals',
      title: 'What are you looking for?',
      subtitle: 'Selecting one or more options would help us tailor your experience.',
      nextEnabled: _selected.isNotEmpty,
      onNext: _continue,
      body: Column(
        children: _goals.map((g) {
          return OnboardingSelectCard(
            icon: g.$1,
            title: g.$2,
            selected: _selected.contains(g.$2),
            multiSelect: true,
            onTap: () => _toggle(g.$2),
          );
        }).toList(),
      ),
    );
  }
}
