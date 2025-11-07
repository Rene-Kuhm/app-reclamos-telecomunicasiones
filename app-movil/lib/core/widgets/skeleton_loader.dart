import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';

/// Skeleton loader para mostrar estados de carga
/// Inspirado en Slack, LinkedIn, Facebook
class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isDark;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.surfaceVariantDark : AppColors.shimmerBase,
      highlightColor: isDark ? AppColors.outlineDark : AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
    );
  }
}

/// Skeleton para cards de reclamo
class ReclamoCardSkeleton extends StatelessWidget {
  final bool isDark;

  const ReclamoCardSkeleton({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonLoader(
                  width: 60,
                  height: 20,
                  isDark: isDark,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                const Spacer(),
                SkeletonLoader(
                  width: 80,
                  height: 24,
                  isDark: isDark,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            SkeletonLoader(
              width: double.infinity,
              height: 20,
              isDark: isDark,
            ),
            SizedBox(height: AppSpacing.xxs),
            SkeletonLoader(
              width: 200,
              height: 16,
              isDark: isDark,
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                SkeletonLoader(
                  width: 100,
                  height: 16,
                  isDark: isDark,
                ),
                SizedBox(width: AppSpacing.sm),
                SkeletonLoader(
                  width: 100,
                  height: 16,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton para statistics card
class StatisticsCardSkeleton extends StatelessWidget {
  final bool isDark;

  const StatisticsCardSkeleton({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonLoader(
                  width: AppSpacing.iconLg,
                  height: AppSpacing.iconLg,
                  isDark: isDark,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      width: 80,
                      height: 16,
                      isDark: isDark,
                    ),
                    SizedBox(height: AppSpacing.xxxs),
                    SkeletonLoader(
                      width: 60,
                      height: 32,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton para lista genérica
class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool isDark;

  const ListSkeleton({
    super.key,
    this.itemCount = 5,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: EdgeInsets.all(AppSpacing.sm),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.xxs),
          child: ReclamoCardSkeleton(isDark: isDark),
        );
      },
    );
  }
}

/// Skeleton para avatar circular
class AvatarSkeleton extends StatelessWidget {
  final double size;
  final bool isDark;

  const AvatarSkeleton({
    super.key,
    this.size = 40,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: size,
      height: size,
      isDark: isDark,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
    );
  }
}

/// Skeleton para text lines
class TextSkeleton extends StatelessWidget {
  final int lines;
  final double? width;
  final bool isDark;

  const TextSkeleton({
    super.key,
    this.lines = 3,
    this.width,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        lines,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.xxs),
          child: SkeletonLoader(
            width: width ?? (index == lines - 1 ? 150 : double.infinity),
            height: 16,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}
