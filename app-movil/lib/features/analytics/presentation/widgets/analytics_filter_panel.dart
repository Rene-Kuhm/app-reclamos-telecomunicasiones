import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_text_styles.dart';

class AnalyticsFilterPanel extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const AnalyticsFilterPanel({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<AnalyticsFilterPanel> createState() => _AnalyticsFilterPanelState();
}

class _AnalyticsFilterPanelState extends State<AnalyticsFilterPanel> {
  late Map<String, dynamic> _tempFilters;

  @override
  void initState() {
    super.initState();
    _tempFilters = Map.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.borderDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros Avanzados',
                  style: AppTextStyles.titleLarge(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _tempFilters.clear());
                  },
                  child: Text('Limpiar Todo'),
                ),
              ],
            ),
          ),

          Divider(),

          // Filters Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filter
                  _buildFilterSection(
                    title: 'Categoría',
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        'Internet',
                        'Telefonía',
                        'Cable',
                        'Todos',
                      ].map((category) {
                        final isSelected = (_tempFilters['categories'] as List?)
                                ?.contains(category) ??
                            false;
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            HapticFeedback.lightImpact();
                            setState(() {
                              final categories =
                                  (_tempFilters['categories'] as List?) ?? [];
                              if (selected) {
                                _tempFilters['categories'] = [
                                  ...categories,
                                  category
                                ];
                              } else {
                                categories.remove(category);
                                _tempFilters['categories'] =
                                    categories.isEmpty ? null : categories;
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: AppSpacing.lg),

                  // Priority Filter
                  _buildFilterSection(
                    title: 'Prioridad',
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        'Alta',
                        'Media',
                        'Baja',
                      ].map((priority) {
                        final isSelected = (_tempFilters['priorities'] as List?)
                                ?.contains(priority) ??
                            false;
                        return FilterChip(
                          label: Text(priority),
                          selected: isSelected,
                          onSelected: (selected) {
                            HapticFeedback.lightImpact();
                            setState(() {
                              final priorities =
                                  (_tempFilters['priorities'] as List?) ?? [];
                              if (selected) {
                                _tempFilters['priorities'] = [
                                  ...priorities,
                                  priority
                                ];
                              } else {
                                priorities.remove(priority);
                                _tempFilters['priorities'] =
                                    priorities.isEmpty ? null : priorities;
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: AppSpacing.lg),

                  // Status Filter
                  _buildFilterSection(
                    title: 'Estado',
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        'Pendiente',
                        'En Curso',
                        'Resuelto',
                        'Cerrado',
                      ].map((status) {
                        final isSelected = (_tempFilters['statuses'] as List?)
                                ?.contains(status) ??
                            false;
                        return FilterChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            HapticFeedback.lightImpact();
                            setState(() {
                              final statuses =
                                  (_tempFilters['statuses'] as List?) ?? [];
                              if (selected) {
                                _tempFilters['statuses'] = [...statuses, status];
                              } else {
                                statuses.remove(status);
                                _tempFilters['statuses'] =
                                    statuses.isEmpty ? null : statuses;
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: AppSpacing.lg),

                  // Date Range Filter
                  _buildFilterSection(
                    title: 'Rango de Fechas',
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectDate(context, 'from'),
                            icon: Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              _tempFilters['dateFrom'] != null
                                  ? 'Desde: ${_formatDate(_tempFilters["dateFrom"])}'
                                  : 'Desde',
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectDate(context, 'to'),
                            icon: Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              _tempFilters['dateTo'] != null
                                  ? 'Hasta: ${_formatDate(_tempFilters["dateTo"])}'
                                  : 'Hasta',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.lg),

                  // SLA Filter
                  _buildFilterSection(
                    title: 'SLA',
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: Text('Solo fuera de SLA'),
                          value: _tempFilters['slaViolated'] ?? false,
                          onChanged: (value) {
                            HapticFeedback.lightImpact();
                            setState(() => _tempFilters['slaViolated'] = value);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: Text('Próximos a vencer'),
                          value: _tempFilters['slaNearExpiry'] ?? false,
                          onChanged: (value) {
                            HapticFeedback.lightImpact();
                            setState(() => _tempFilters['slaNearExpiry'] = value);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancelar'),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      widget.onApplyFilters(_tempFilters);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Aplicar Filtros'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleSmall(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }

  void _selectDate(BuildContext context, String type) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        if (type == 'from') {
          _tempFilters['dateFrom'] = date;
        } else {
          _tempFilters['dateTo'] = date;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
