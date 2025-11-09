import 'package:flutter/material.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_text_styles.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownButton<String>(
      value: selectedPeriod,
      underline: Container(),
      icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
      items: [
        DropdownMenuItem(value: 'today', child: Text('Hoy')),
        DropdownMenuItem(value: 'week', child: Text('Esta Semana')),
        DropdownMenuItem(value: 'month', child: Text('Este Mes')),
        DropdownMenuItem(value: 'quarter', child: Text('Trimestre')),
        DropdownMenuItem(value: 'year', child: Text('Año')),
        DropdownMenuItem(value: 'custom', child: Text('Personalizado')),
      ],
      onChanged: (value) {
        if (value != null) onPeriodChanged(value);
      },
      style: AppTextStyles.bodyMedium(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }
}
