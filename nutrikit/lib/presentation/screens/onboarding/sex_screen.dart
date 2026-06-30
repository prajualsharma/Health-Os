import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';

class SexScreen extends StatefulWidget {
  const SexScreen({super.key});

  @override
  State<SexScreen> createState() => _SexScreenState();
}

class _SexScreenState extends State<SexScreen> {
  String? _gender;

  void _continue() {
    OnboardingStore.instance.update((d) => d.copyWith(gender: _gender));
    context.push(OnboardingFlow.nextPath('/onboarding/sex')!);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      routePath: '/onboarding/sex',
      title: "What's your biological sex?",
      subtitle:
          'We support all forms of gender expression. However, we need this to calculate your body metrics.',
      nextEnabled: _gender != null,
      onNext: _continue,
      body: Row(
        children: [
          Expanded(child: _card('Male', Icons.male)),
          const SizedBox(width: 12),
          Expanded(child: _card('Female', Icons.female)),
        ],
      ),
    );
  }

  Widget _card(String label, IconData icon) {
    final selected = _gender == label;
    return GestureDetector(
      onTap: () => setState(() => _gender = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.cardBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: selected ? Colors.white : AppColors.text, size: 32),
            ),
            const SizedBox(height: 12),
            Text(label, style: AppTypography.bodyBold),
          ],
        ),
      ),
    );
  }
}
