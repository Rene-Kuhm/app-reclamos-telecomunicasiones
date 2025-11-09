import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_shadows.dart';

/// Advanced metric card with trend indicators and progress
class AdvancedMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final double? percentChange;
  final bool isPositiveTrend;
  final double? progress; // 0.0 to 1.0
  final VoidCallback? onTap;

  const AdvancedMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.percentChange,
    this.isPositiveTrend = true,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon and trend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: AppSpacing.iconMd,
                    ),
                  ),
                  if (percentChange != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxxs,
                      ),
                      decoration: BoxDecoration(
                        color: isPositiveTrend
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositiveTrend
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: isPositiveTrend
                                ? AppColors.success
                                : AppColors.error,
                            size: 14,
                          ),
                          SizedBox(width: AppSpacing.xxxs),
                          Text(
                            '${percentChange!.abs().toStringAsFixed(1)}%',
                            style: AppTextStyles.bodySmall(
                              color: isPositiveTrend
                                  ? AppColors.success
                                  : AppColors.error,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.md),

              // Title
              Text(
                title,
                style: AppTextStyles.bodySmall(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: AppSpacing.xxxs),

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
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (progress != null)
                    CircularPercentIndicator(
                      radius: 20,
                      lineWidth: 3,
                      percent: progress!.clamp(0.0, 1.0),
                      center: Text(
                        '${(progress! * 100).toInt()}%',
                        style: AppTextStyles.bodyXSmall(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      progressColor: color,
                      backgroundColor: color.withOpacity(0.1),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                ],
              ),

              // Subtitle
              if (subtitle != null) ...[
                SizedBox(height: AppSpacing.xxxs),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodyXSmall(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
