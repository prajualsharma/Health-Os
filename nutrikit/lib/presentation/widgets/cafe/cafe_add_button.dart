import 'package:flutter/material.dart';

import '../../../core/theme/cafe_colors.dart';

class CafeAddButton extends StatelessWidget {
  const CafeAddButton({
    super.key,
    required this.onTap,
    this.showCustomise = true,
  });

  final VoidCallback onTap;
  final bool showCustomise;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CafeColors.accentGreen, width: 1.5),
          boxShadow: CafeColors.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ADD',
              style: TextStyle(
                color: CafeColors.accentGreen,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                height: 1.1,
              ),
            ),
            if (showCustomise)
              Text(
                'customise',
                style: TextStyle(
                  color: CafeColors.dim,
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CafeQuantityStepper extends StatelessWidget {
  const CafeQuantityStepper({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CafeColors.accentGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(icon: Icons.remove, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          _StepBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
