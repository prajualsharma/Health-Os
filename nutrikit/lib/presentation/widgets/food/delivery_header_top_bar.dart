import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/onboarding_store.dart';
import '../../providers/profile_provider.dart';

/// Shared top row: ETA + address (left) and NutriKit Active pill (right).
class DeliveryHeaderTopBar extends StatelessWidget {
  const DeliveryHeaderTopBar({super.key, this.eta = '25 mins'});

  final String eta;

  static const horizontalPadding = EdgeInsets.fromLTRB(16, 8, 16, 0);
  static const leftColumnMinHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    final city = OnboardingStore.instance.data.city;
    final profile = context.watch<ProfileProvider>().profile;
    final planLabel = _planDisplayName(profile?.plan);
    final address = city.isNotEmpty
        ? 'To Home — $city'
        : 'To Home — Flat 401, 4th Floor, set city in profile';

    return Padding(
      padding: horizontalPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: leftColumnMinHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    eta,
                    style: AppTypography.h1.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          address,
                          style: AppTypography.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          DeliveryPlanPill(planLabel: planLabel),
        ],
      ),
    );
  }

  static String _planDisplayName(String? plan) {
    if (plan == null || plan.isEmpty) return 'NutriKit';
    if (plan.toLowerCase().contains('nutrikit')) return 'NutriKit';
    if (plan.toLowerCase().contains('nutriplan')) return 'NutriKit';
    final parts = plan.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : plan;
  }
}

class DeliveryPlanPill extends StatelessWidget {
  const DeliveryPlanPill({super.key, required this.planLabel});

  final String planLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                planLabel,
                style: AppTypography.caption.copyWith(
                  color: AppColors.infoText,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  height: 1.1,
                ),
              ),
              Text(
                'Active',
                style: AppTypography.caption.copyWith(
                  color: AppColors.infoText,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          Container(
            width: 28,
            height: 20,
            decoration: BoxDecoration(
              gradient: AppColors.greenGradient,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 12),
          ),
        ],
      ),
    );
  }
}
