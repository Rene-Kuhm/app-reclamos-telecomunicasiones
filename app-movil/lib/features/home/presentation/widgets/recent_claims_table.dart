import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_shadows.dart';
import '../../../reclamos/domain/entities/reclamo.dart';

/// Professional recent claims data table
class RecentClaimsTable extends StatelessWidget {
  final List<Reclamo> reclamos;
  final Function(String) onRowTap;

  const RecentClaimsTable({
    super.key,
    required this.reclamos,
    required this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reclamos Recientes',
                style: AppTextStyles.titleMedium(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('Filtros'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // Table
          SizedBox(
            height: 400,
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 600,
              headingRowColor: WidgetStateProperty.all(
                isDark
                    ? AppColors.surfaceDark.withOpacity(0.5)
                    : AppColors.surfaceLight.withOpacity(0.5),
              ),
              headingRowHeight: 56,
              dataRowHeight: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              columns: [
                DataColumn2(
                  label: Text(
                    'ID',
                    style: AppTextStyles.bodySmall(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(
                    'Título',
                    style: AppTextStyles.bodySmall(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(
                    'Estado',
                    style: AppTextStyles.bodySmall(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(
                    'Prioridad',
                    style: AppTextStyles.bodySmall(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(
                    'Fecha',
                    style: AppTextStyles.bodySmall(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  size: ColumnSize.M,
                ),
              ],
              rows: reclamos.map((reclamo) {
                return DataRow2(
                  onTap: () => onRowTap(reclamo.id),
                  cells: [
                    DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xxxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          '#${reclamo.id.substring(0, 6)}',
                          style: AppTextStyles.bodyXSmall(
                            color: AppColors.primary,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            reclamo.titulo,
                            style: AppTextStyles.bodySmall(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ).copyWith(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSpacing.xxxs),
                          Text(
                            reclamo.categoria,
                            style: AppTextStyles.bodyXSmall(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xxxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.getEstadoColor(reclamo.estado)
                              .withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                          border: Border.all(
                            color:
                                AppColors.getEstadoColor(reclamo.estado),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.getEstadoColor(reclamo.estado),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: AppSpacing.xxxs),
                            Text(
                              reclamo.estadoDisplayName,
                              style: AppTextStyles.bodyXSmall(
                                color:
                                    AppColors.getEstadoColor(reclamo.estado),
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.getPrioridadColor(reclamo.prioridad)
                              .withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Icon(
                          _getPriorityIcon(reclamo.prioridad),
                          size: 16,
                          color: AppColors.getPrioridadColor(reclamo.prioridad),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        DateFormat('dd/MM/yy').format(reclamo.createdAt),
                        style: AppTextStyles.bodySmall(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toUpperCase()) {
      case 'ALTA':
        return Icons.priority_high;
      case 'MEDIA':
        return Icons.remove;
      case 'BAJA':
        return Icons.arrow_downward;
      default:
        return Icons.help_outline;
    }
  }
}
