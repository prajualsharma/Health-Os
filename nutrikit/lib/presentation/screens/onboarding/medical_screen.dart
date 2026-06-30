import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../onboarding/onboarding_flow.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/onboarding/onboarding_chip_grid.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';

class MedicalScreen extends StatefulWidget {
  const MedicalScreen({super.key});

  @override
  State<MedicalScreen> createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen> {
  final Set<String> _selected = {};

  static const _none = 'None';
  static const _conditions = [
    _none,
    'Diabetes',
    'Pre-Diabetes',
    'Cholesterol',
    'Hypertension',
    'PCOS',
    'Thyroid',
    'Physical Injury',
    'Excessive stress/anxiety',
    'Sleep issues',
    'Depression',
    'Anger issues',
    'Loneliness',
    'Relationship stress',
  ];

  void _toggle(String label) {
    setState(() {
      if (label == _none) {
        _selected
          ..clear()
          ..add(_none);
      } else {
        _selected.remove(_none);
        if (_selected.contains(label)) {
          _selected.remove(label);
        } else {
          _selected.add(label);
        }
      }
    });
  }

  void _continue() {
    final list = _selected.toList();
    OnboardingStore.instance.update(
      (d) => d.copyWith(
        medicalConditions: list.contains(_none) ? [] : list,
      ),
    );
    context.push(OnboardingFlow.nextPath('/onboarding/medical')!);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      routePath: '/onboarding/medical',
      title: 'Any Medical Condition we should be aware of?',
      subtitle:
          'This info will help us guide you to your fitness goals safely and quickly.',
      nextEnabled: _selected.isNotEmpty,
      onNext: _continue,
      body: OnboardingChipGrid(
        options: _conditions,
        selected: _selected,
        singleSelectNoneKey: _none,
        onToggle: _toggle,
      ),
    );
  }
}
