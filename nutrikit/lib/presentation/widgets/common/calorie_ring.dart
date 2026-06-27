import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CalorieRing extends StatelessWidget {
  const CalorieRing({
    super.key,
    required this.pct,
    this.size = 84,
    this.strokeWidth = 9,
    this.color = AppColors.green,
    required this.label,
    required this.sub,
  });

  final double pct;
  final double size;
  final double strokeWidth;
  final Color color;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: CalorieRingPainter(
              pct: pct.clamp(0, 100),
              strokeWidth: strokeWidth,
              color: color,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                sub,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CalorieRingPainter extends CustomPainter {
  CalorieRingPainter({
    required this.pct,
    required this.strokeWidth,
    required this.color,
  });

  final double pct;
  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * math.pi, false, bgPaint);

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * (pct / 100);
    canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
  }

  @override
  bool shouldRepaint(CalorieRingPainter oldDelegate) =>
      oldDelegate.pct != pct ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
