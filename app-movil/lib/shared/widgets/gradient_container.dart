import 'package:flutter/material.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_shadows.dart';

/// Gradient container with multiple preset styles
/// Enterprise-grade gradient backgrounds
class GradientContainer extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientContainer({
    super.key,
    required this.child,
    this.gradient,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppSpacing.radiusLg,
    this.border,
    this.boxShadow,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  /// Primary gradient (blue tones)
  factory GradientContainer.primary({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = AppSpacing.radiusLg,
  }) {
    return GradientContainer(
      gradient: LinearGradient(
        colors: AppColors.primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      boxShadow: AppShadows.elevation8,
      child: child,
    );
  }

  /// Success gradient (green tones)
  factory GradientContainer.success({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = AppSpacing.radiusLg,
  }) {
    return GradientContainer(
      gradient: LinearGradient(
        colors: AppColors.successGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      boxShadow: AppShadows.elevation8,
      child: child,
    );
  }

  /// Error gradient (red tones)
  factory GradientContainer.error({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = AppSpacing.radiusLg,
  }) {
    return GradientContainer(
      gradient: LinearGradient(
        colors: AppColors.errorGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      boxShadow: AppShadows.elevation8,
      child: child,
    );
  }

  /// Accent gradient (orange tones)
  factory GradientContainer.accent({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = AppSpacing.radiusLg,
  }) {
    return GradientContainer(
      gradient: LinearGradient(
        colors: AppColors.accentGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      boxShadow: AppShadows.elevation8,
      child: child,
    );
  }

  /// Dark gradient (dark tones for dark mode)
  factory GradientContainer.dark({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = AppSpacing.radiusLg,
  }) {
    return GradientContainer(
      gradient: LinearGradient(
        colors: AppColors.secondaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      boxShadow: AppShadows.elevation8,
      child: child,
    );
  }

  /// Sunset gradient (warm tones)
  factory GradientContainer.sunset({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = AppSpacing.radiusLg,
  }) {
    return GradientContainer(
      gradient: const LinearGradient(
        colors: [
          Color(0xFFFF6B6B),
          Color(0xFFFFE66D),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      boxShadow: AppShadows.elevation8,
      child: child,
    );
  }

  /// Ocean gradient (blue-green tones)
  factory GradientContainer.ocean({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = AppSpacing.radiusLg,
  }) {
    return GradientContainer(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF667EEA),
          Color(0xFF764BA2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      boxShadow: AppShadows.elevation8,
      child: child,
    );
  }

  /// Aurora gradient (purple-pink tones)
  factory GradientContainer.aurora({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = AppSpacing.radiusLg,
  }) {
    return GradientContainer(
      gradient: const LinearGradient(
        colors: [
          Color(0xFFA18CD1),
          Color(0xFFFBC2EB),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      boxShadow: AppShadows.elevation8,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              colors: AppColors.primaryGradient,
              begin: begin,
              end: end,
            ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: boxShadow,
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}

/// Animated gradient background
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.colors,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<AlignmentGeometry> _topAlignmentAnimation;
  late Animation<AlignmentGeometry> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _topAlignmentAnimation = TweenSequence<AlignmentGeometry>([
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.topRight,
          end: Alignment.bottomRight,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.bottomRight,
          end: Alignment.bottomLeft,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.bottomLeft,
          end: Alignment.topLeft,
        ),
        weight: 1,
      ),
    ]).animate(_controller);

    _bottomAlignmentAnimation = TweenSequence<AlignmentGeometry>([
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.bottomRight,
          end: Alignment.bottomLeft,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.bottomLeft,
          end: Alignment.topLeft,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.topRight,
          end: Alignment.bottomRight,
        ),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.colors,
              begin: _topAlignmentAnimation.value,
              end: _bottomAlignmentAnimation.value,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
