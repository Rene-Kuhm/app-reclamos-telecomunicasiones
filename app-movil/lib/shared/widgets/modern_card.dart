import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_shadows.dart';
import '../../core/design/app_text_styles.dart';

/// Modern Card with glassmorphism, gradient and advanced effects
/// Enterprise-grade card component with multiple variants
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Gradient? gradient;
  final bool hasGradient;
  final bool hasGlassmorphism;
  final bool hasBorder;
  final bool hasElevation;
  final double borderRadius;
  final List<BoxShadow>? customShadow;
  final Border? customBorder;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.onLongPress,
    this.color,
    this.gradient,
    this.hasGradient = false,
    this.hasGlassmorphism = false,
    this.hasBorder = true,
    this.hasElevation = false,
    this.borderRadius = AppSpacing.radiusLg,
    this.customShadow,
    this.customBorder,
  });

  /// Glass card with frosted glass effect
  factory ModernCard.glass({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    VoidCallback? onTap,
    double borderRadius = AppSpacing.radiusLg,
  }) {
    return ModernCard(
      hasGlassmorphism: true,
      hasBorder: true,
      hasElevation: false,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      onTap: onTap,
      borderRadius: borderRadius,
      child: child,
    );
  }

  /// Gradient card with smooth color transitions
  factory ModernCard.gradient({
    required Widget child,
    required Gradient gradient,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    VoidCallback? onTap,
    double borderRadius = AppSpacing.radiusLg,
  }) {
    return ModernCard(
      hasGradient: true,
      gradient: gradient,
      hasBorder: false,
      hasElevation: true,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      onTap: onTap,
      borderRadius: borderRadius,
      child: child,
    );
  }

  /// Elevated card with shadow
  factory ModernCard.elevated({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    VoidCallback? onTap,
    Color? color,
    double borderRadius = AppSpacing.radiusLg,
  }) {
    return ModernCard(
      hasElevation: true,
      hasBorder: false,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      onTap: onTap,
      color: color,
      borderRadius: borderRadius,
      child: child,
    );
  }

  /// Outline card with border only
  factory ModernCard.outlined({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    VoidCallback? onTap,
    Color? color,
    double borderRadius = AppSpacing.radiusLg,
  }) {
    return ModernCard(
      hasBorder: true,
      hasElevation: false,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      onTap: onTap,
      color: color,
      borderRadius: borderRadius,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine background color
    Color backgroundColor;
    if (hasGlassmorphism) {
      backgroundColor = isDark
          ? AppColors.surfaceDark.withOpacity(0.3)
          : AppColors.surfaceLight.withOpacity(0.3);
    } else {
      backgroundColor = color ??
          (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    }

    // Build decoration
    BoxDecoration decoration = BoxDecoration(
      color: hasGradient ? null : backgroundColor,
      gradient: hasGradient ? gradient : null,
      borderRadius: BorderRadius.circular(borderRadius),
      border: hasBorder
          ? customBorder ?? Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
              width: 1,
            )
          : null,
      boxShadow: hasElevation
          ? (customShadow ?? AppShadows.card)
          : null,
    );

    Widget cardContent = Container(
      width: width,
      height: height,
      margin: margin ?? EdgeInsets.all(AppSpacing.cardMargin),
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: hasGlassmorphism
            ? _buildGlassContent(context, isDark)
            : _buildNormalContent(),
      ),
    );

    // Add tap functionality if provided
    if (onTap != null || onLongPress != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }

  Widget _buildGlassContent(BuildContext context, bool isDark) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(isDark ? 0.05 : 0.1),
              Colors.white.withOpacity(isDark ? 0.02 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
            width: 1.5,
          ),
        ),
        padding: padding ?? EdgeInsets.all(AppSpacing.cardPadding),
        child: child,
      ),
    );
  }

  Widget _buildNormalContent() {
    return Padding(
      padding: padding ?? EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );
  }
}