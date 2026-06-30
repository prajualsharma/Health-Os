import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/unit_conversion.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/onboarding/onboarding_number_field.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/unit_segmented_toggle.dart';

class HeightScreen extends StatefulWidget {
  const HeightScreen({super.key});

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  String _unit = 'Cm';
  final _cm = TextEditingController(text: '173');
  final _feet = TextEditingController(text: '5');
  final _inches = TextEditingController(text: '8');

  @override
  void dispose() {
    _cm.dispose();
    _feet.dispose();
    _inches.dispose();
    super.dispose();
  }

  bool get _valid {
    if (_unit == 'Cm') {
      final v = int.tryParse(_cm.text.trim()) ?? 0;
      return v >= 100 && v <= 250;
    }
    final ft = int.tryParse(_feet.text.trim()) ?? 0;
    final inch = int.tryParse(_inches.text.trim()) ?? 0;
    return ft >= 3 && ft <= 8 && inch >= 0 && inch <= 11;
  }

  void _continue() {
    final heightCm = heightToCm(
      unit: _unit == 'Cm' ? 'cm' : 'ft_in',
      cm: int.tryParse(_cm.text.trim()),
      feet: int.tryParse(_feet.text.trim()),
      inches: int.tryParse(_inches.text.trim()),
    );
    OnboardingStore.instance.update((d) => d.copyWith(
          height: heightCm,
          heightFeet: int.tryParse(_feet.text.trim()) ?? d.heightFeet,
          heightInches: int.tryParse(_inches.text.trim()) ?? d.heightInches,
          heightUnit: _unit == 'Cm' ? 'cm' : 'ft_in',
        ));
    context.push(OnboardingFlow.nextPath('/onboarding/height')!);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      routePath: '/onboarding/height',
      title: 'How tall are you?',
      subtitle:
          'Your height will help us calculate important body stats to help you reach your goals faster.',
      nextEnabled: _valid,
      onNext: _continue,
      body: Column(
        children: [
          if (_unit == 'Cm')
            OnboardingNumberField(
              controller: _cm,
              unitLabel: 'Cm',
              hint: '173',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OnboardingNumberField(
                    controller: _feet,
                    unitLabel: 'Ft',
                    hint: '5',
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OnboardingNumberField(
                    controller: _inches,
                    unitLabel: 'In',
                    hint: '8',
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          UnitSegmentedToggle(
            options: const ['Ft/In', 'Cm'],
            selected: _unit == 'Cm' ? 'Cm' : 'Ft/In',
            onChanged: (v) => setState(() => _unit = v == 'Cm' ? 'Cm' : 'Ft/In'),
          ),
        ],
      ),
    );
  }
}
