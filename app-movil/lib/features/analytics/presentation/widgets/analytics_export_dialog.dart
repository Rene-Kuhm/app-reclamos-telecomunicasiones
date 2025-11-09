import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_text_styles.dart';

class AnalyticsExportDialog extends StatefulWidget {
  final Function(String format, Map<String, dynamic> options) onExport;

  const AnalyticsExportDialog({
    super.key,
    required this.onExport,
  });

  @override
  State<AnalyticsExportDialog> createState() => _AnalyticsExportDialogState();
}

class _AnalyticsExportDialogState extends State<AnalyticsExportDialog> {
  String _selectedFormat = 'pdf';
  bool _includeCharts = true;
  bool _includeTables = true;
  bool _includeRawData = false;
  String _dateRange = 'current';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.download, color: AppColors.primary),
          SizedBox(width: AppSpacing.sm),
          Text('Exportar Reporte'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Format Selection
            Text(
              'Formato de Exportación',
              style: AppTextStyles.titleSmall(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),

            _buildFormatOption('PDF', 'pdf', Icons.picture_as_pdf, AppColors.error),
            _buildFormatOption('Excel', 'excel', Icons.table_chart, AppColors.success),
            _buildFormatOption('CSV', 'csv', Icons.description, AppColors.info),
            _buildFormatOption('PNG', 'png', Icons.image, AppColors.warning),

            SizedBox(height: AppSpacing.lg),

            // Content Options
            Text(
              'Contenido a Incluir',
              style: AppTextStyles.titleSmall(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),

            CheckboxListTile(
              title: Text('Gráficos'),
              value: _includeCharts,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                setState(() => _includeCharts = value ?? true);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: Text('Tablas'),
              value: _includeTables,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                setState(() => _includeTables = value ?? true);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: Text('Datos Crudos'),
              value: _includeRawData,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                setState(() => _includeRawData = value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            SizedBox(height: AppSpacing.lg),

            // Date Range
            Text(
              'Período de Datos',
              style: AppTextStyles.titleSmall(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),

            DropdownButtonFormField<String>(
              value: _dateRange,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              items: [
                DropdownMenuItem(value: 'current', child: Text('Período Actual')),
                DropdownMenuItem(value: 'last_month', child: Text('Último Mes')),
                DropdownMenuItem(value: 'last_quarter', child: Text('Último Trimestre')),
                DropdownMenuItem(value: 'last_year', child: Text('Último Año')),
                DropdownMenuItem(value: 'all_time', child: Text('Todo el Tiempo')),
              ],
              onChanged: (value) {
                setState(() => _dateRange = value ?? 'current');
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.heavyImpact();
            widget.onExport(_selectedFormat, {
              'includeCharts': _includeCharts,
              'includeTables': _includeTables,
              'includeRawData': _includeRawData,
              'dateRange': _dateRange,
            });
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.download),
          label: Text('Exportar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFormatOption(String label, String value, IconData icon, Color color) {
    final isSelected = _selectedFormat == value;

    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon, color: color, size: AppSpacing.iconSm),
          SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      ),
      value: value,
      groupValue: _selectedFormat,
      onChanged: (value) {
        HapticFeedback.lightImpact();
        setState(() => _selectedFormat = value ?? 'pdf');
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}
