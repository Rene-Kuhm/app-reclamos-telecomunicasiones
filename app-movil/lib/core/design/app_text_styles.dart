import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sistema de tipografía profesional
/// Usa Inter font (similar a Slack, Notion)
class AppTextStyles {
  AppTextStyles._();

  // Base font family
  static String get _fontFamily => GoogleFonts.inter().fontFamily!;

  // Font weights
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Display styles (Extra large headings)
  static TextStyle displayLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 57,
        fontWeight: bold,
        letterSpacing: -0.25,
        height: 1.12,
        color: color,
      );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 45,
        fontWeight: bold,
        letterSpacing: 0,
        height: 1.16,
        color: color,
      );

  static TextStyle displaySmall({Color? color}) => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: bold,
        letterSpacing: 0,
        height: 1.22,
        color: color,
      );

  // Headline styles (Large headings)
  static TextStyle headlineLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: semiBold,
        letterSpacing: 0,
        height: 1.25,
        color: color,
      );

  static TextStyle headlineMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: semiBold,
        letterSpacing: 0,
        height: 1.29,
        color: color,
      );

  static TextStyle headlineSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: semiBold,
        letterSpacing: 0,
        height: 1.33,
        color: color,
      );

  // Title styles (Medium headings)
  static TextStyle titleLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: medium,
        letterSpacing: 0,
        height: 1.27,
        color: color,
      );

  static TextStyle titleMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: medium,
        letterSpacing: 0.15,
        height: 1.5,
        color: color,
      );

  static TextStyle titleSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: medium,
        letterSpacing: 0.1,
        height: 1.43,
        color: color,
      );

  // Body styles (Regular text)
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: regular,
        letterSpacing: 0.5,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: regular,
        letterSpacing: 0.25,
        height: 1.43,
        color: color,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: regular,
        letterSpacing: 0.4,
        height: 1.33,
        color: color,
      );

  // Label styles (Buttons, labels)
  static TextStyle labelLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: medium,
        letterSpacing: 0.1,
        height: 1.43,
        color: color,
      );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: medium,
        letterSpacing: 0.5,
        height: 1.33,
        color: color,
      );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: medium,
        letterSpacing: 0.5,
        height: 1.45,
        color: color,
      );

  // Custom styles
  static TextStyle button({Color? color}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: semiBold,
        letterSpacing: 0.5,
        height: 1.2,
        color: color,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: regular,
        letterSpacing: 0.4,
        height: 1.33,
        color: color,
      );

  static TextStyle overline({Color? color}) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: medium,
        letterSpacing: 1.5,
        height: 1.6,
        color: color,
      );

  // Number styles (for statistics, counters)
  static TextStyle numberLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 40,
        fontWeight: bold,
        letterSpacing: -0.5,
        height: 1.1,
        color: color,
        fontFeatures: [const FontFeature.tabularFigures()],
      );

  static TextStyle numberMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: semiBold,
        letterSpacing: -0.5,
        height: 1.2,
        color: color,
        fontFeatures: [const FontFeature.tabularFigures()],
      );

  static TextStyle numberSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: semiBold,
        letterSpacing: 0,
        height: 1.2,
        color: color,
        fontFeatures: [const FontFeature.tabularFigures()],
      );

  // Create TextTheme for MaterialApp
  static TextTheme createTextTheme({bool isDark = false}) {
    final Color baseColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return TextTheme(
      displayLarge: displayLarge(color: baseColor),
      displayMedium: displayMedium(color: baseColor),
      displaySmall: displaySmall(color: baseColor),
      headlineLarge: headlineLarge(color: baseColor),
      headlineMedium: headlineMedium(color: baseColor),
      headlineSmall: headlineSmall(color: baseColor),
      titleLarge: titleLarge(color: baseColor),
      titleMedium: titleMedium(color: baseColor),
      titleSmall: titleSmall(color: baseColor),
      bodyLarge: bodyLarge(color: baseColor),
      bodyMedium: bodyMedium(color: baseColor),
      bodySmall: bodySmall(color: baseColor),
      labelLarge: labelLarge(color: baseColor),
      labelMedium: labelMedium(color: baseColor),
      labelSmall: labelSmall(color: baseColor),
    );
  }
}
