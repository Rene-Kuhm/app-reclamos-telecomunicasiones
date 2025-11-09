import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_shadows.dart';
import '../screens/analytics_screen.dart';

class KPIComparisonCard extends StatelessWidget {
  final KPIData data;
  final bool isComparing;

  const KPIComparisonCard({
    super.key,
    required this.data,
    this.isComparing = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.card,
        border: Border.all(
          color: data.color.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  data.icon,
                  color: data.color,
                  size: AppSpacing.iconMd,
                ),
              ),
              Spacer(),
              _buildTrendIndicator(),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          Text(
            data.title,
            style: AppTextStyles.bodySmall(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),

          SizedBox(height: AppSpacing.xs),

          Text(
            data.value,
            style: AppTextStyles.headlineMedium(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
          ),

          if (isComparing) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              'vs ${data.previousValue}',
              style: AppTextStyles.caption(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],

          SizedBox(height: AppSpacing.sm),

          LinearPercentIndicator(
            percent: data.change.abs() / 100,
            lineHeight: 4,
            progressColor: data.change >= 0 ? AppColors.success : AppColors.error,
            backgroundColor: isDark
                ? AppColors.borderDark
                : AppColors.borderLight,
            barRadius: Radius.circular(AppSpacing.radiusSm),
            animation: true,
            animationDuration: 1000,
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildTrendIndicator() {
    final isPositive = data.change >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
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
            size: AppSpacing.iconXs,
          ),
          SizedBox(width: 2),
          Text(
            '${data.change.abs().toStringAsFixed(1)}%',
            style: AppTextStyles.caption(color: color).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
