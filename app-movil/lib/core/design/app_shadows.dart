import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Sistema de sombras consistente
/// Basado en Material Design elevation system
class AppShadows {
  AppShadows._();

  // Elevation shadows (for cards, buttons, etc.)
  static List<BoxShadow> get elevation1 => [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get elevation2 => [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevation4 => [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevation8 => [
        BoxShadow(
          color: AppColors.shadowMedium,
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get elevation16 => [
        BoxShadow(
          color: AppColors.shadowMedium,
          blurRadius: 24,
          offset: const Offset(0, 16),
        ),
      ];

  // Soft shadow (more subtle, for floating elements)
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 20,
          offset: const Offset(0, 4),
          spreadRadius: -4,
        ),
      ];

  // Medium shadow (for modals, bottom sheets)
  static List<BoxShadow> get medium => [
        BoxShadow(
          color: AppColors.shadowMedium,
          blurRadius: 40,
          offset: const Offset(0, 8),
          spreadRadius: -8,
        ),
      ];

  // Strong shadow (for important elevated elements)
  static List<BoxShadow> get strong => [
        BoxShadow(
          color: AppColors.shadowDark,
          blurRadius: 60,
          offset: const Offset(0, 16),
          spreadRadius: -12,
        ),
      ];

  // Card shadow (subtle, professional)
  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 12,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  // Button shadow (for raised buttons)
  static List<BoxShadow> get button => [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 8,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
      ];

  // Floating Action Button shadow
  static List<BoxShadow> get fab => [
        BoxShadow(
          color: AppColors.shadowMedium,
          blurRadius: 16,
          offset: const Offset(0, 6),
          spreadRadius: -4,
        ),
      ];

  // Inner shadow effect (for pressed states)
  static List<BoxShadow> get inner => [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 4,
          offset: const Offset(0, 2),
          spreadRadius: -2,
        ),
      ];

  // Glow effect (for focus, active states)
  static List<BoxShadow> glow(Color color, {double blur = 12}) => [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: blur,
          offset: Offset.zero,
        ),
      ];

  // Custom shadow helper
  static List<BoxShadow> custom({
    required Color color,
    required double blurRadius,
    Offset offset = Offset.zero,
    double spreadRadius = 0,
  }) {
    return [
      BoxShadow(
        color: color,
        blurRadius: blurRadius,
        offset: offset,
        spreadRadius: spreadRadius,
      ),
    ];
  }
}
