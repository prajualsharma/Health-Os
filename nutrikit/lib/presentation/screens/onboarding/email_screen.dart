import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void initState() {
    super.initState();
    _email.text = 'prajual.sharma.1559@gmail.com';
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _continue() {
    final text = _email.text.trim();
    if (text.isNotEmpty && !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    OnboardingStore.instance.update((d) => d.copyWith(email: text));
    context.go('/onboarding/calculating');
  }

  void _skip() {
    OnboardingStore.instance.update((d) => d.copyWith(email: ''));
    context.go('/onboarding/calculating');
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
                Text('ALMOST THERE',
                    style: AppTypography.label.copyWith(color: AppColors.green)),
                const SizedBox(height: 6),
                Text('Add your email', style: AppTypography.h1),
                const SizedBox(height: 4),
                Text('Optional — only for receipts and order updates',
                    style: AppTypography.caption),
                const SizedBox(height: 28),
                AppInput(
                  label: 'Email (optional)',
                  placeholder: 'you@email.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 24),
                AppButton(label: 'Continue', onPressed: _continue),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _skip,
                    child: Text('Skip for now',
                        style: AppTypography.caption
                            .copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
