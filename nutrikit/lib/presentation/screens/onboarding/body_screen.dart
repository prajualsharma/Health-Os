import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';

class BodyScreen extends StatefulWidget {
  const BodyScreen({super.key});

  @override
  State<BodyScreen> createState() => _BodyScreenState();
}

class _BodyScreenState extends State<BodyScreen> {
  final _formKey = GlobalKey<FormState>();
  String _gender = 'Male';
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _target = TextEditingController();

  @override
  void dispose() {
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    _target.dispose();
    super.dispose();
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    OnboardingStore.instance.update((d) => d.copyWith(
          gender: _gender,
          age: int.tryParse(_age.text) ?? 0,
          height: int.tryParse(_height.text) ?? 0,
          currentWeight: double.tryParse(_weight.text) ?? 0,
          targetWeight: double.tryParse(_target.text) ?? 0,
        ));
    context.go('/onboarding/activity');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STEP 3 OF 5',
                    style:
                        AppTypography.label.copyWith(color: AppColors.green)),
                const SizedBox(height: 6),
                Text('Your Body Stats', style: AppTypography.h1),
                const SizedBox(height: 4),
                Text('We use these to size your portions',
                    style: AppTypography.caption),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _genderButton('Male', '♂')),
                    const SizedBox(width: 12),
                    Expanded(child: _genderButton('Female', '♀')),
                  ],
                ),
                const SizedBox(height: 20),
                AppInput(
                  label: 'Age',
                  placeholder: '28',
                  controller: _age,
                  keyboardType: TextInputType.number,
                  validator: (v) => Validators.number(v, 'Age'),
                ),
                const SizedBox(height: 16),
                AppInput(
                  label: 'Height (cm)',
                  placeholder: '178',
                  controller: _height,
                  keyboardType: TextInputType.number,
                  validator: (v) => Validators.number(v, 'Height'),
                ),
                const SizedBox(height: 16),
                AppInput(
                  label: 'Current Weight (kg)',
                  placeholder: '76.5',
                  controller: _weight,
                  keyboardType: TextInputType.number,
                  validator: (v) => Validators.number(v, 'Weight'),
                ),
                const SizedBox(height: 16),
                AppInput(
                  label: 'Target Weight (kg)',
                  placeholder: '70',
                  controller: _target,
                  keyboardType: TextInputType.number,
                  validator: (v) => Validators.number(v, 'Target weight'),
                ),
                const SizedBox(height: 24),
                AppButton(label: 'Continue', onPressed: _continue),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _genderButton(String label, String symbol) {
    final selected = _gender == label;
    return GestureDetector(
      onTap: () => setState(() => _gender = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenGlow : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            '$symbol  $label',
            style: TextStyle(
              color: selected ? AppColors.green : AppColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
