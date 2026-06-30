import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../widgets/common/app_button.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text.rich(
                TextSpan(
                  style: AppTypography.h1.copyWith(fontSize: 28),
                  children: const [
                    TextSpan(text: 'Snap and '),
                    TextSpan(
                      text: 'Auto-Track Meals with AI',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Just snap a pic from your phone. We will auto-track food photos. Like magic!',
                style: AppTypography.caption.copyWith(fontSize: 14, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.cardShadow,
                ),
                child: const Center(
                  child: Icon(Icons.camera_alt_outlined, size: 72, color: AppColors.primary),
                ),
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  style: AppTypography.caption.copyWith(fontSize: 12),
                  children: const [
                    TextSpan(text: 'Your data is secure and private to you. '),
                    TextSpan(
                      text: 'Know More',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Continue',
                onPressed: () => context.push(OnboardingFlow.nextPath('/onboarding/intro')!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
