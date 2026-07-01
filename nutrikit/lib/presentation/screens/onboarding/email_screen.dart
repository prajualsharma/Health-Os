import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_field.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

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
    context.push('/onboarding/calculating');
  }

  void _skip() {
    OnboardingStore.instance.update((d) => d.copyWith(email: ''));
    context.push('/onboarding/calculating');
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      routePath: '/onboarding/email',
      title: 'Add your email',
      subtitle: 'Optional — only for receipts and order updates',
      onNext: _continue,
      nextLabel: 'Continue',
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            OnboardingTextField(
              controller: _email,
              hintText: 'you@email.com',
              style: AppTypography.body,
              keyboardType: TextInputType.emailAddress,
              borderColor: AppColors.cardBorder,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                return Validators.email(v);
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _skip,
              child: Text(
                'Skip for now',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
