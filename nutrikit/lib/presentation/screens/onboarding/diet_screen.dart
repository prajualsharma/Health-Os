import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/common/app_button.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  String? _diet;
  final Set<String> _allergies = {};

  static const _diets = [
    ['🥦', 'Veg'],
    ['🍗', 'Non-Veg'],
    ['🌱', 'Vegan'],
    ['🤷', 'No Pref'],
  ];

  static const _allergens = [
    'Nuts',
    'Dairy',
    'Gluten',
    'Soy',
    'Eggs',
    'Shellfish'
  ];

  void _submit() {
    OnboardingStore.instance.update((d) => d.copyWith(
          dietType: _diet ?? 'No Pref',
          allergies: _allergies.toList(),
        ));
    context.go('/onboarding/email');
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
              Text('STEP 5 OF 5',
                  style: AppTypography.label.copyWith(color: AppColors.green)),
              const SizedBox(height: 6),
              Text('Diet & Allergies', style: AppTypography.h1),
              const SizedBox(height: 24),
              Text('DIET TYPE', style: AppTypography.label),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _diets.map((d) {
                  final selected = _diet == d[1];
                  return _chip(
                    label: '${d[0]} ${d[1]}',
                    selected: selected,
                    onTap: () => setState(() => _diet = d[1]),
                  );
                }).toList(),
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
              const SizedBox(height: 32),
              AppButton(label: 'Continue', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final color = danger ? AppColors.red : AppColors.green;
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
