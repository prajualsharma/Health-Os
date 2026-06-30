import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  String? _diet;
  final Set<String> _allergies = {};

  static const _diets = ['Veg', 'Non-Veg', 'Vegan', 'No Pref'];
  static const _allergens = [
    'Nuts',
    'Dairy',
    'Gluten',
    'Soy',
    'Eggs',
    'Shellfish',
  ];

  @override
  void initState() {
    super.initState();
    _diet = 'No Pref';
  }

  void _submit() {
    OnboardingStore.instance.update((d) => d.copyWith(
          dietType: _diet ?? 'No Pref',
          allergies: _allergies.toList(),
        ));
    context.push(OnboardingFlow.nextPath('/onboarding/diet')!);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      routePath: '/onboarding/diet',
      title: 'Diet & Allergies',
      subtitle: 'Tell us about your food preferences.',
      nextEnabled: _diet != null,
      onNext: _submit,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DIET TYPE', style: AppTypography.label),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _diets.map((d) => _chip(
                  label: d,
                  selected: _diet == d,
                  onTap: () => setState(() => _diet = d),
                )).toList(),
          ),
          const SizedBox(height: 24),
          Text('ALLERGIES', style: AppTypography.label),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _allergens.map((a) {
              final selected = _allergies.contains(a);
              return _chip(
                label: a,
                selected: selected,
                danger: true,
                onTap: () => setState(() {
                  if (selected) {
                    _allergies.remove(a);
                  } else {
                    _allergies.add(a);
                  }
                }),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final color = danger ? AppColors.red : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppColors.text,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
