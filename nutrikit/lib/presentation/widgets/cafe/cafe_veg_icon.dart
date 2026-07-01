import 'package:flutter/material.dart';

import '../../../core/theme/cafe_colors.dart';

class CafeVegIcon extends StatelessWidget {
  const CafeVegIcon({super.key, required this.isVeg, this.size = 14});

  final bool isVeg;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? CafeColors.accentGreen : CafeColors.nonVegBrown;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: isVeg
            ? Container(
                width: size * 0.45,
                height: size * 0.45,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              )
            : CustomPaint(
                size: Size(size * 0.5, size * 0.5),
                painter: _TrianglePainter(color),
              ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
