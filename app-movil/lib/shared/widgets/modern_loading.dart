import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_text_styles.dart';

/// Modern loading indicators with multiple variants
/// Enterprise-grade loading states
class ModernLoading extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const ModernLoading({
    super.key,
    this.message,
    this.size = 48.0,
    this.color,
  });

  /// Centered full-screen loading
  factory ModernLoading.fullscreen({
    String? message,
    Color? color,
  }) {
    return ModernLoading(
      message: message,
      size: 64.0,
      color: color,
    );
  }

  /// Inline loading indicator
  factory ModernLoading.inline({
    double size = 24.0,
    Color? color,
  }) {
    return ModernLoading(
      size: size,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loadingColor = color ?? AppColors.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated loading indicator
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: size > 40 ? 4 : 3,
              valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                duration: 1000.ms,
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                curve: Curves.easeInOut,
              )
              .then()
              .scale(
                duration: 1000.ms,
                begin: const Offset(1.0, 1.0),
                end: const Offset(0.8, 0.8),
                curve: Curves.easeInOut,
              ),

          if (message != null) ...[
            SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTextStyles.bodyMedium(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 300.ms)
                .slideY(begin: 0.2, end: 0),
          ],
        ],
      ),
    );
  }
}

/// Shimmer loading skeleton for cards and lists
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppSpacing.radiusMd,
  });

  /// Card skeleton
  factory ShimmerLoading.card({
    double? width,
    double height = 120,
  }) {
    return ShimmerLoading(
      width: width ?? double.infinity,
      height: height,
      borderRadius: AppSpacing.radiusLg,
    );
  }

  /// List tile skeleton
  factory ShimmerLoading.listTile() {
    return const ShimmerLoading(
      width: double.infinity,
      height: 72,
      borderRadius: AppSpacing.radiusMd,
    );
  }

  /// Circle skeleton (for avatars)
  factory ShimmerLoading.circle({
    double size = 48,
  }) {
    return ShimmerLoading(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }

  /// Text line skeleton
  factory ShimmerLoading.text({
    double? width,
    double height = 16,
  }) {
    return ShimmerLoading(
      width: width ?? 120,
      height: height,
      borderRadius: AppSpacing.radiusSm,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark
          ? AppColors.surfaceVariantDark
          : AppColors.shimmerBase,
      highlightColor: isDark
          ? AppColors.outlineDark
          : AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Loading skeleton for list of items
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 120,
    this.spacing = AppSpacing.sm,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.sm),
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        return ShimmerLoading.card(height: itemHeight);
      },
    );
  }
}

/// Loading skeleton for grid of items
class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;

  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.5,
    this.spacing = AppSpacing.sm,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.sm),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const ShimmerLoading(
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }
}

/// Custom loading widget with message and retry
class LoadingState extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onRetry;

  const LoadingState({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: AppSpacing.iconXxl,
                color: AppColors.primary,
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 2000.ms)
                  .then()
                  .rotate(duration: 2000.ms),
              SizedBox(height: AppSpacing.lg),
            ] else ...[
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
            ],

            if (title != null) ...[
              Text(
                title!,
                style: AppTextStyles.titleLarge(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xs),
            ],

            if (message != null) ...[
              Text(
                message!,
                style: AppTextStyles.bodyMedium(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
            ],

            if (onRetry != null) ...[
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
