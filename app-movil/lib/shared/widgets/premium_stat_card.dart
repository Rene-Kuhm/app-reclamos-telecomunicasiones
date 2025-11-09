import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_text_styles.dart';
import '../../core/design/app_shadows.dart';
import 'dart:math' as math;

/// Premium stat card with advanced visualizations
/// Enterprise-grade metric display
class PremiumStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color color;
  final double? percentChange;
  final bool isPositiveTrend;
  final double? progress;
  final String? badge;
  final VoidCallback? onTap;
  final bool showSparkline;
  final List<double>? sparklineData;

  const PremiumStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    required this.color,
    this.percentChange,
    this.isPositiveTrend = true,
    this.progress,
    this.badge,
    this.onTap,
    this.showSparkline = false,
    this.sparklineData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
              width: 1,
            ),
            boxShadow: AppShadows.card,
          ),
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row (icon + badge)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(
                      icon ?? Icons.trending_up,
                      color: color,
                      size: AppSpacing.iconMd,
                    ),
                  ),

                  // Badge or trend indicator
                  if (badge != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxxs,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        badge!,
                        style: AppTextStyles.labelSmall(color: color)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    )
                  else if (percentChange != null)
                    _TrendIndicator(
                      percentChange: percentChange!,
                      isPositive: isPositiveTrend,
                    ),
                ],
              ),

              SizedBox(height: AppSpacing.md),

              // Title
              Text(
                title,
                style: AppTextStyles.bodyMedium(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ).copyWith(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: AppSpacing.xs),

              // Value
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: AppTextStyles.headlineMedium(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ).copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Circular progress
                  if (progress != null)
                    CircularPercentIndicator(
                      radius: 24,
                      lineWidth: 4,
                      percent: progress!.clamp(0.0, 1.0),
                      center: Text(
                        '${(progress! * 100).toInt()}%',
                        style: AppTextStyles.bodyXSmall(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      progressColor: color,
                      backgroundColor: color.withOpacity(0.1),
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                      animationDuration: 1200,
                    ),
                ],
              ),

              // Subtitle
              if (subtitle != null) ...[
                SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Sparkline
              if (showSparkline && sparklineData != null) ...[
                SizedBox(height: AppSpacing.sm),
                _Sparkline(
                  data: sparklineData!,
                  color: color,
                  height: 32,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Trend indicator with percentage change
class _TrendIndicator extends StatelessWidget {
  final double percentChange;
  final bool isPositive;

  const _TrendIndicator({
    required this.percentChange,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.success : AppColors.error;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 16,
          ),
          SizedBox(width: AppSpacing.xxxs),
          Text(
            '${percentChange.abs().toStringAsFixed(1)}%',
            style: AppTextStyles.labelSmall(color: color)
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Simple sparkline chart
class _Sparkline extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double height;

  const _Sparkline({
    required this.data,
    required this.color,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          data: data,
          color: color,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter({
    required this.data,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final maxValue = data.reduce(math.max);
    final minValue = data.reduce(math.min);
    final range = maxValue - minValue;

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range == 0 ? 0.5 : (data[i] - minValue) / range;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}

/// Stat card with linear progress bar
class LinearStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? label;
  final IconData? icon;
  final Color color;
  final double progress;
  final VoidCallback? onTap;

  const LinearStatCard({
    super.key,
    required this.title,
    required this.value,
    this.label,
    this.icon,
    required this.color,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: color,
                      size: AppSpacing.iconSm,
                    ),
                    SizedBox(width: AppSpacing.xs),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bodyMedium(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTextStyles.headlineMedium(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSpacing.sm),
              LinearPercentIndicator(
                padding: EdgeInsets.zero,
                lineHeight: 8,
                percent: progress.clamp(0.0, 1.0),
                backgroundColor: color.withOpacity(0.1),
                progressColor: color,
                barRadius: Radius.circular(AppSpacing.radiusSm),
                animation: true,
                animationDuration: 1000,
              ),
              if (label != null) ...[
                SizedBox(height: AppSpacing.xs),
                Text(
                  label!,
                  style: AppTextStyles.bodySmall(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
