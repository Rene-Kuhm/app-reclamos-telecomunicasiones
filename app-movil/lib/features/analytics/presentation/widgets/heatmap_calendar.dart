import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_text_styles.dart';

class HeatmapCalendar extends StatelessWidget {
  final Map<DateTime, int> data;
  final List<Color> colorScheme;
  final int maxValue;

  const HeatmapCalendar({
    super.key,
    required this.data,
    required this.colorScheme,
    this.maxValue = 10,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final startDate = DateTime(now.year, 1, 1);
    final endDate = DateTime(now.year, 12, 31);
    final totalDays = endDate.difference(startDate).inDays;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heatmap Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(53, (weekIndex) {
                return Column(
                  children: List.generate(7, (dayIndex) {
                    final dayOffset = (weekIndex * 7) + dayIndex;
                    if (dayOffset >= totalDays) {
                      return SizedBox(width: 12, height: 12);
                    }

                    final date = startDate.add(Duration(days: dayOffset));
                    final value = data[_normalizeDate(date)] ?? 0;
                    final color = _getColor(value);

                    return Container(
                      width: 12,
                      height: 12,
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                );
              }),
            ),

            SizedBox(height: AppSpacing.md),

            // Legend
            Row(
              children: [
                Text(
                  'Menos',
                  style: AppTextStyles.caption(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                ...colorScheme.map((color) {
                  return Container(
                    width: 12,
                    height: 12,
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Más',
                  style: AppTextStyles.caption(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Color _getColor(int value) {
    if (value == 0) return colorScheme[0];
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    final index = (percentage * (colorScheme.length - 1)).round();
    return colorScheme[index];
  }
}
