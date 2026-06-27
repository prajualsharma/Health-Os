import 'package:flutter/material.dart';

/// Kitchen-display palette: dark slate canvas with a warm orange brand accent,
/// tuned for an at-a-glance order board (Swiggy/Zomato kitchen style).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFFF5722);
  static const Color primaryDark = Color(0xFFE64A19);

  // Dark canvas (kitchen displays are usually on tablets in bright rooms;
  // high-contrast dark UI reads well).
  static const Color bg = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color card = Color(0xFF1E293B);
  static const Color cardBorder = Color(0xFF334155);

  static const Color text = Color(0xFFF1F5F9);
  static const Color muted = Color(0xFF94A3B8);
  static const Color dim = Color(0xFF64748B);
  static const Color white = Color(0xFFFFFFFF);

  // Order status colors
  static const Color statusNew = Color(0xFF3B82F6); // blue
  static const Color statusAccepted = Color(0xFFF59E0B); // amber
  static const Color statusPreparing = Color(0xFFF97316); // orange
  static const Color statusReady = Color(0xFF22C55E); // green
  static const Color statusPicked = Color(0xFF64748B); // slate
  static const Color statusCancelled = Color(0xFFEF4444); // red

  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color veg = Color(0xFF22C55E);
  static const Color nonVeg = Color(0xFFEF4444);

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
}
