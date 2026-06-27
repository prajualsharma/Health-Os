import 'package:flutter/material.dart';

/// HealthifyMe-inspired light palette. Orange primary, white surfaces.
class AppColors {
  AppColors._();

  // Brand primary (HealthifyMe orange)
  static const Color primary = Color(0xFFFF5722);
  static const Color primaryDark = Color(0xFFE64A19);
  static const Color primaryGlow = Color(0x1FFF5722);

  // Back-compat aliases used across the codebase
  static const Color green = primary;
  static const Color greenDark = primaryDark;
  static const Color greenGlow = primaryGlow;

  // Semantic success green (Veg badges, Active status, protein macros)
  static const Color success = Color(0xFF4CAF50);

  // Neutrals
  static const Color bg = Color(0xFFFAFAFA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE0E0E0);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color text = Color(0xFF212121);
  static const Color muted = Color(0xFF757575);
  static const Color dim = Color(0xFF9E9E9E);
  static const Color white = Color(0xFFFFFFFF);

  // Secondary accents
  static const Color accent = Color(0xFFFFB300);
  static const Color orange = Color(0xFFFF9800);
  static const Color red = Color(0xFFF44336);
  static const Color blue = Color(0xFF2196F3);
  static const Color amber = Color(0xFFFFB300);

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF5F0), card],
  );

  /// Subtle shadow for cards on light backgrounds.
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
