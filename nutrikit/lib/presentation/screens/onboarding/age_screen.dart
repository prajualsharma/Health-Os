import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../onboarding/onboarding_flow.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/onboarding/onboarding_number_field.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';

class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  final _age = TextEditingController(text: '26');

  @override
  void dispose() {
    _age.dispose();
    super.dispose();
  }

  void _continue() {
    final age = int.tryParse(_age.text.trim()) ?? 0;
    if (age < 13 || age > 100) return;
    OnboardingStore.instance.update((d) => d.copyWith(age: age));
    context.push(OnboardingFlow.nextPath('/onboarding/age')!);
  }

  @override
  Widget build(BuildContext context) {
    final age = int.tryParse(_age.text.trim()) ?? 0;
    return OnboardingScaffold(
      routePath: '/onboarding/age',
      title: "What's your Age?",
      subtitle: 'Your age determines how much you should consume. (Select your age in years)',
      nextEnabled: age >= 13 && age <= 100,
      onNext: _continue,
      body: OnboardingNumberField(
        controller: _age,
        unitLabel: 'Years',
        hint: '26',
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}
