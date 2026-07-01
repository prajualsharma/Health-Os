import 'package:flutter/material.dart';

/// Reference-green palette for Cafe / Bistro UI only.
class CafeColors {
  CafeColors._();

  static const Color headerDark = Color(0xFF0D5C3D);
  static const Color headerBottom = Color(0xFF123832);
  static const Color accentGreen = Color(0xFF00A859);
  static const Color accentGreenDark = Color(0xFF008248);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color badgeBlue = Color(0xFF2196F3);
  static const Color badgeBlueBg = Color(0xFFE3F2FD);
  static const Color sectionBg = Color(0xFFE8F5E9);
  static const Color sectionBgMint = Color(0xFFD4EDDA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color bg = Color(0xFFF7F8FA);
  static const Color text = Color(0xFF212121);
  static const Color muted = Color(0xFF757575);
  static const Color dim = Color(0xFF9E9E9E);
  static const Color border = Color(0xFFE0E0E0);
  static const Color nonVegBrown = Color(0xFF8B4513);
  static const Color mostLovedRed = Color(0xFFE53935);
  static const Color savingsBlue = Color(0xFF1565C0);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [headerDark, headerBottom],
  );

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}
