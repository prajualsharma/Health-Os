import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/unit_conversion.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/onboarding/onboarding_info_banner.dart';
import '../../widgets/onboarding/onboarding_number_field.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/unit_segmented_toggle.dart';

class TargetWeightScreen extends StatefulWidget {
  const TargetWeightScreen({super.key});

  @override
  State<TargetWeightScreen> createState() => _TargetWeightScreenState();
}

class _TargetWeightScreenState extends State<TargetWeightScreen> {
  String _unit = 'Kg';
  final _weight = TextEditingController(text: '70');

  @override
  void initState() {
    super.initState();
    final data = OnboardingStore.instance.data;
    _unit = data.weightUnit == 'lb' ? 'Lb' : 'Kg';
    final start = data.currentWeight > 0 ? data.currentWeight : 65.0;
    _weight.text = _unit == 'Kg'
        ? start.round().toString()
        : kgToLb(start).round().toString();
  }

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

  (int, int) get _healthyRange {
    final h = OnboardingStore.instance.data.height;
    return healthyWeightRangeKg(h);
  }

  String get _bannerMessage {
    final (min, max) = _healthyRange;
    if (min == 0) {
      return 'Set a realistic weight goal for yourself.';
    }
    final target = _kg.round();
    if (target >= min && target <= max) {
      return 'Your target weight is perfectly aligned with your ideal weight range of ';
    }
    return 'Healthy range based on your BMI is $min–$max kg. But, choose a goal that feels right for you.';
  }

  String? get _bannerHighlight {
    final (min, max) = _healthyRange;
    final target = _kg.round();
    if (min > 0 && target >= min && target <= max) {
      return '$min-$max kg';
    }
    return null;
  }

  void _continue() {
    OnboardingStore.instance.update((d) => d.copyWith(targetWeight: _kg));
    context.push(OnboardingFlow.nextPath('/onboarding/target-weight')!);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      routePath: '/onboarding/target-weight',
      title: "What's your target weight?",
      subtitle: 'Set a realistic weight goal for yourself.',
      nextEnabled: _valid,
      onNext: _continue,
      body: Column(
        children: [
          if (_healthyRange.$1 > 0)
            OnboardingInfoBanner(
              message: _bannerMessage,
              highlight: _bannerHighlight,
              variant: _bannerHighlight != null
                  ? InfoBannerVariant.soft
                  : InfoBannerVariant.warm,
            ),
          if (_healthyRange.$1 > 0) const SizedBox(height: 20),
          OnboardingNumberField(
            controller: _weight,
            unitLabel: _unit,
            hint: _unit == 'Kg' ? '70' : '154',
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
