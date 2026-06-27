import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    OnboardingStore.instance.update((d) => d.copyWith(name: _name.text.trim()));
    context.go('/onboarding/goal');
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
                Text('STEP 1 OF 5',
                    style: AppTypography.label.copyWith(color: AppColors.green)),
                const SizedBox(height: 6),
                Text("What's your name?", style: AppTypography.h1),
                const SizedBox(height: 4),
                Text('So we can personalise your plan',
                    style: AppTypography.caption),
                const SizedBox(height: 28),
                AppInput(
                  label: 'Full Name',
                  placeholder: 'Arjun Mehta',
                  controller: _name,
                  validator: (v) => Validators.required(v, 'Name'),
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
}
