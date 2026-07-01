import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get h1 => GoogleFonts.dmSans(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: -1,
        color: AppColors.text,
      );

  static TextStyle get h2 => GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.text,
      );

  static TextStyle get h3 => GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      );

  static TextStyle get body => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  static TextStyle get bodyBold => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      );

  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
      );

  static TextStyle get label => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.muted,
        letterSpacing: 0.8,
      );

  static TextStyle get mealSlot => GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppColors.muted,
        letterSpacing: 0.5,
      );

  static TextStyle get cafeSectionTitle => GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.5,
        color: AppColors.text,
      );
}
