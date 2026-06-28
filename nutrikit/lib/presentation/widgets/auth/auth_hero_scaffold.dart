import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Full-screen hero background with a white bottom sheet (Swish-style).
class AuthHeroScaffold extends StatelessWidget {
  const AuthHeroScaffold({
    super.key,
    required this.appName,
    required this.tagline,
    required this.headline,
    required this.badgeText,
    required this.logoEmoji,
    required this.sheetChild,
    this.accentColor = AppColors.primary,
    this.heroGradient = const [
      Color(0xFF3D1F0F),
      Color(0xFF1A0A05),
      Color(0xFF0D0502),
    ],
    this.onSkip,
  });

  final String appName;
  final String tagline;
  final String headline;
  final String badgeText;
  final String logoEmoji;
  final Widget sheetChild;
  final Color accentColor;
  final List<Color> heroGradient;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: heroGradient,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      children: [
                        Text(logoEmoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 6),
                        Text(
                          appName,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tagline,
                            style: TextStyle(
                              color: accentColor.withValues(alpha: 0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onSkip != null)
                          TextButton(
                            onPressed: onSkip,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.black26,
                              foregroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Skip',
                                style: TextStyle(fontSize: 13)),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          headline,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                  child: sheetChild,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Legal footer for auth bottom sheets.
class AuthLegalFooter extends StatelessWidget {
  const AuthLegalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text.rich(
        TextSpan(
          style: AppTypography.caption.copyWith(fontSize: 11),
          children: const [
            TextSpan(text: 'By clicking "Continue", '),
            TextSpan(
              text: 'Privacy policy',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: ' & '),
            TextSpan(
              text: 'Terms of Conditions',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: ' apply'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
