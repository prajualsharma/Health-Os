import 'package:flutter/material.dart';

/// Blinkit Bistro / Zepto Cafe ops palette — light surfaces, reference green CTAs.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF00A859);
  static const Color primaryDark = Color(0xFF0D5C3D);
  static const Color primaryLight = Color(0xFFE8F5E9);

  static const Color headerDark = Color(0xFF0D5C3D);
  static const Color headerBottom = Color(0xFF123832);

  static const Color bg = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE8ECE8);
  static const Color sectionMint = Color(0xFFE8F5E9);

  static const Color text = Color(0xFF212121);
  static const Color muted = Color(0xFF757575);
  static const Color dim = Color(0xFF9E9E9E);
  static const Color white = Color(0xFFFFFFFF);

  static const Color statusNew = Color(0xFF1565C0);
  static const Color statusAccepted = Color(0xFF00897B);
  static const Color statusPreparing = Color(0xFFF57C00);
  static const Color statusReady = Color(0xFF00A859);
  static const Color statusPicked = Color(0xFF9E9E9E);
  static const Color statusCancelled = Color(0xFFE53935);

  static const Color success = Color(0xFF00A859);
  static const Color danger = Color(0xFFE53935);
  static const Color veg = Color(0xFF00A859);
  static const Color nonVeg = Color(0xFF8B4513);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [headerDark, headerBottom],
  );

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];
}
