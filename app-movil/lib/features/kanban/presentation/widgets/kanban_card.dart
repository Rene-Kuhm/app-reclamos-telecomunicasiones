import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_shadows.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../reclamos/data/models/reclamo_model.dart';

class KanbanCard extends StatelessWidget {
  final ReclamoModel reclamo;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isDragging;

  const KanbanCard({
    super.key,
    required this.reclamo,
    required this.onTap,
    required this.onLongPress,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: _getPriorityColor().withOpacity(0.3),
              width: 2,
            ),
            boxShadow: isDragging
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ]
                : AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with ID and Priority
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ID Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      '#${reclamo.id.substring(0, 8)}',
                      style: AppTextStyles.caption(
                        color: AppColors.primary,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Priority Badge
                  _buildPriorityBadge(),
                ],
              ),

              SizedBox(height: AppSpacing.sm),

              // Title
              Text(
                reclamo.titulo,
                style: AppTextStyles.bodyLarge(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (reclamo.descripcion.isNotEmpty) ...[
                SizedBox(height: AppSpacing.xs),
                Text(
                  reclamo.descripcion,
                  style: AppTextStyles.bodySmall(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              SizedBox(height: AppSpacing.sm),

              // Metadata Row
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  // Category Chip
                  _buildChip(
                    icon: Icons.category,
                    label: reclamo.categoria,
                    color: AppColors.info,
                  ),

                  // Date Chip
                  _buildChip(
                    icon: Icons.calendar_today,
                    label: DateFormatter.formatRelative(reclamo.createdAt),
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),

                  // Comments Count (from metadata)
                  if (reclamo.count?['comentarios'] != null && reclamo.count!['comentarios'] > 0)
                    _buildChip(
                      icon: Icons.comment,
                      label: reclamo.count!['comentarios'].toString(),
                      color: AppColors.secondary,
                    ),

                  // Attachments Count (from metadata)
                  if (reclamo.count?['archivos'] != null && reclamo.count!['archivos'] > 0)
                    _buildChip(
                      icon: Icons.attach_file,
                      label: reclamo.count!['archivos'].toString(),
                      color: AppColors.warning,
                    ),
                ],
              ),

              // Assigned Technician (if any)
              if (reclamo.tecnicoAsignado != null && reclamo.tecnicoAsignado!['nombre'] != null) ...[
                SizedBox(height: AppSpacing.sm),
                Divider(height: 1),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        (reclamo.tecnicoAsignado!['nombre'] as String)[0].toUpperCase(),
                        style: AppTextStyles.caption(
                          color: AppColors.primary,
                        ).copyWith(fontSize: 10),
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        reclamo.tecnicoAsignado!['nombre'] as String,
                        style: AppTextStyles.caption(
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
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    final color = _getPriorityColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: color.withOpacity(0.3),
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
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Text(
            reclamo.prioridad,
            style: AppTextStyles.caption(
              color: color,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: color,
          ),
          SizedBox(width: 2),
          Text(
            label,
            style: AppTextStyles.caption(
              color: color,
            ).copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor() {
    switch (reclamo.prioridad.toLowerCase()) {
      case 'alta':
      case 'high':
        return AppColors.error;
      case 'media':
      case 'medium':
        return AppColors.warning;
      case 'baja':
      case 'low':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }
}
