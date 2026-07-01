import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/unit_conversion.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/onboarding/onboarding_field.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/unit_segmented_toggle.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  String _unit = 'Kg';
  final _weight = TextEditingController(text: '65');

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  double get _kg {
    final v = double.tryParse(_weight.text.trim()) ?? 0;
    return weightToKg(unit: _unit == 'Kg' ? 'kg' : 'lb', value: v);
  }

  bool get _valid => _kg >= 30 && _kg <= 300;

  void _continue() {
    OnboardingStore.instance.update((d) => d.copyWith(
          currentWeight: _kg,
          weightUnit: _unit == 'Kg' ? 'kg' : 'lb',
        ));
    context.push(OnboardingFlow.nextPath('/onboarding/weight')!);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      routePath: '/onboarding/weight',
      title: "What's your current weight?",
      subtitle:
          'This will help us determine your goal, and monitor your progress over time.',
      nextEnabled: _valid,
      onNext: _continue,
      body: Column(
        children: [
          OnboardingNumberField(
            controller: _weight,
            unitLabel: _unit,
            hint: _unit == 'Kg' ? '65' : '143',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          UnitSegmentedToggle(
            options: const ['Kg', 'Lb'],
            selected: _unit,
            onChanged: (v) {
              final currentKg = _kg;
              setState(() {
                _unit = v;
                if (v == 'Lb') {
                  _weight.text = kgToLb(currentKg).round().toString();
                } else {
                  _weight.text = currentKg.round().toString();
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
