import 'package:flutter/material.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';

/// Enterprise-grade Statistics card widget with gradient background
class StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatisticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.08),
            color.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: (isDark ? AppColors.outlineDark : AppColors.outlineLight).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with background
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                icon,
                color: color,
                size: AppSpacing.iconMd,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            // Value
            Text(
              value,
              style: AppTextStyles.headlineLarge(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ).copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: AppSpacing.xxxs),
            // Title
            Text(
              title,
              style: AppTextStyles.bodyMedium(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ).copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
