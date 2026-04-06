import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const white = Color(0xFFFFFFFF);

  // New vibrant indigo/violet primary palette
  static const bg = Color(0xFFF4F3FF);           // soft lavender bg
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF0EEFF);
  static const border = Color(0xFFDDD8FF);
  static const border2 = Color(0xFFBDB5F5);

  // Primary: deep indigo-violet
  static const navy = Color(0xFF2D1B8E);
  static const navy2 = Color(0xFF4C35C2);

  // Accent: vivid electric blue
  static const blue = Color(0xFF4361EE);
  static const blueLight = Color(0xFFEBEEFF);
  static const blueMid = Color(0xFFCDD4FF);

  // Teal / cyan accent
  static const teal = Color(0xFF0891B2);
  static const tealLight = Color(0xFFE0F7FC);

  // Warm amber
  static const amber = Color(0xFFB45309);
  static const amberLight = Color(0xFFFFF3DC);

  // Success green
  static const green = Color(0xFF15803D);
  static const greenLight = Color(0xFFDCFCE7);

  // Error / danger red
  static const red = Color(0xFFB91C1C);
  static const redLight = Color(0xFFFFE4E6);

  // Text hierarchy
  static const slate = Color(0xFF4A5568);
  static const slateLight = Color(0xFF8896AA);
  static const text1 = Color(0xFF1A1060);
  static const text2 = Color(0xFF3A3272);
  static const text3 = Color(0xFF6B6494);
  static const text4 = Color(0xFFAEA8CC);

  // Avatar backgrounds
  static const avBlue = Color(0xFFCDD4FF);
  static const avNavy = Color(0xFFDDD8FF);
  static const avTeal = Color(0xFFE0F7FC);
  static const avGreen = Color(0xFFDCFCE7);
  static const avAmber = Color(0xFFFFF3DC);
  static const avRed = Color(0xFFFFE4E6);

  // Hero gradient stops
  static const gradA = Color(0xFF2D1B8E);
  static const gradB = Color(0xFF4C35C2);
  static const gradC = Color(0xFF4361EE);
}

class AppTheme {
  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.dmSerifDisplay(
            color: AppColors.text1, fontWeight: FontWeight.w400),
        displayMedium: GoogleFonts.dmSerifDisplay(
            color: AppColors.text1, fontWeight: FontWeight.w400),
        displaySmall: GoogleFonts.dmSerifDisplay(
            color: AppColors.text1, fontWeight: FontWeight.w400),
        headlineLarge: GoogleFonts.dmSerifDisplay(
            color: AppColors.text1, fontWeight: FontWeight.w400),
        headlineMedium: GoogleFonts.plusJakartaSans(
            color: AppColors.text1, fontWeight: FontWeight.w700),
        bodyLarge: GoogleFonts.plusJakartaSans(
            color: AppColors.text1, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.plusJakartaSans(
            color: AppColors.text2, fontWeight: FontWeight.w400),
        bodySmall: GoogleFonts.plusJakartaSans(
            color: AppColors.text3, fontWeight: FontWeight.w400),
        labelLarge: GoogleFonts.plusJakartaSans(
            color: AppColors.text1, fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.plusJakartaSans(
            color: AppColors.text2, fontWeight: FontWeight.w600),
        labelSmall: GoogleFonts.plusJakartaSans(
            color: AppColors.text3, fontWeight: FontWeight.w600),
      );

  static ThemeData get theme => ThemeData(
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        textTheme: textTheme,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.navy,
          secondary: AppColors.blue,
          surface: AppColors.surface,
        ),
      );
}

// Reusable border radius constants
const double rSm = 8.0;
const double rMd = 12.0;
const double rLg = 18.0;
const double rXl = 24.0;
const double rFull = 999.0;

// Box shadows — tuned for indigo palette
List<BoxShadow> get shadowSm => [
      const BoxShadow(
          color: Color(0x142D1B8E), blurRadius: 4, offset: Offset(0, 1)),
      const BoxShadow(
          color: Color(0x0A2D1B8E), blurRadius: 2, offset: Offset(0, 1)),
    ];

List<BoxShadow> get shadowMd => [
      const BoxShadow(
          color: Color(0x1A2D1B8E), blurRadius: 20, offset: Offset(0, 4)),
      const BoxShadow(
          color: Color(0x0F2D1B8E), blurRadius: 8, offset: Offset(0, 2)),
    ];

List<BoxShadow> get shadowLg => [
      const BoxShadow(
          color: Color(0x262D1B8E), blurRadius: 48, offset: Offset(0, 16)),
      const BoxShadow(
          color: Color(0x142D1B8E), blurRadius: 16, offset: Offset(0, 4)),
    ];
