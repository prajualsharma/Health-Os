import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/app_button.dart';

class _Slide {
  const _Slide(this.emoji, this.title, this.description);
  final String emoji;
  final String title;
  final String description;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const List<_Slide> _slides = [
    _Slide('🥗', 'Eat for your goals',
        'AI builds a daily meal plan around your body, your targets, and what you love to eat.'),
    _Slide('🍱', 'Cooked & delivered',
        'Your kitchen preps every portion to hit your macros — then delivers it to your door, fresh.'),
    _Slide('📈', 'Track every win',
        'Watch your weight, streaks, and adherence climb. Small daily wins, big results.'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      context.go('/auth/phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) {
                    final s = _slides[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          s.emoji,
                          style: const TextStyle(
                            fontSize: 80,
                            shadows: [
                              Shadow(color: AppColors.greenGlow, blurRadius: 30),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(s.title,
                            style: AppTypography.h1,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 14),
                        Text(
                          s.description,
                          style:
                              AppTypography.body.copyWith(color: AppColors.dim),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final selected = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selected ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.green : Colors.transparent,
                      border: selected
                          ? null
                          : Border.all(color: AppColors.cardBorder, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: _page == _slides.length - 1 ? 'Get Started' : 'Next',
                onPressed: _next,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.go('/auth/phone'),
                child: RichText(
                  text: const TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                    children: [
                      TextSpan(
                        text: 'Log in',
                        style: TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
