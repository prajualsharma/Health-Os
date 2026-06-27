import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/cart_store.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

class OrderConfirmScreen extends StatelessWidget {
  const OrderConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: AppColors.greenGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(color: AppColors.greenGlow, blurRadius: 40),
                      ],
                    ),
                    child: const Center(
                      child: Text('✓',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 46,
                            fontWeight: FontWeight.w900,
                          )),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Order Placed!',
                      style: AppTypography.h1, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    'Your kitchen is on it. We will have your fresh, macro-perfect meals delivered shortly.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.muted,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppCard(
                    child: Column(
                      children: [
                        Text('ORDER ID', style: AppTypography.label),
                        const SizedBox(height: 4),
                        const Text('#NK-20240531-1847',
                            style: TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            )),
                        const SizedBox(height: 10),
                        Text('Estimated Delivery',
                            style: AppTypography.caption),
                        const SizedBox(height: 2),
                        Text('7:30 – 8:00 PM', style: AppTypography.h3),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Track Order 📍',
                    onPressed: () => context.go('/order-tracking'),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Back to Home',
                    variant: ButtonVariant.ghost,
                    onPressed: () {
                      CartStore.instance.clear();
                      context.go('/home/dashboard');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
