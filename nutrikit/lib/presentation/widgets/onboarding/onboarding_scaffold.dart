import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../onboarding/onboarding_progress_reporter.dart';
import 'onboarding_progress_bar.dart';

class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.routePath,
    required this.title,
    this.subtitle,
    required this.body,
    required this.onNext,
    this.nextLabel = 'Next',
    this.nextEnabled = true,
    this.isLoading = false,
  });

  final String routePath;
  final String title;
  final String? subtitle;
  final Widget body;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool nextEnabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    OnboardingProgressReporter.trackRoute(routePath);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 28),
                    color: AppColors.text,
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: OnboardingProgressBar(
                      progress: OnboardingFlow.progress(routePath),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTypography.h1.copyWith(fontSize: 26),
                      textAlign: TextAlign.center,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        subtitle!,
                        style: AppTypography.caption.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 28),
                    body,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: nextEnabled && !isLoading
                      ? () {
                          onNext?.call();
                          OnboardingProgressReporter.reportRoute(routePath);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.cardBorder,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          nextLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
