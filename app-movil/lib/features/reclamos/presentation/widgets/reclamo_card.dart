import 'package:flutter/material.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_shadows.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/reclamo.dart';
import 'estado_chip.dart';
import 'prioridad_indicator.dart';

/// Reclamo card widget
class ReclamoCard extends StatelessWidget {
  final Reclamo reclamo;
  final VoidCallback? onTap;

  const ReclamoCard({
    super.key,
    required this.reclamo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prioridadColor = AppColors.getPrioridadColor(reclamo.prioridad);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: (isDark ? AppColors.outlineDark : AppColors.outlineLight).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Stack(
        children: [
          // Colored left border indicator
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: AppSpacing.xxxs,
              decoration: BoxDecoration(
                color: prioridadColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusLg),
                  bottomLeft: Radius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),
          ),

          // Main content
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  top: AppSpacing.md,
                  bottom: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with numero and estado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (reclamo.numero != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xxxs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              '#${reclamo.numero}',
                              style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        EstadoChip(estado: reclamo.estado),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),

                    // Title
                    Text(
                      reclamo.titulo,
                      style: AppTextStyles.titleMedium(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.xs),

                    // Description
                    Text(
                      reclamo.descripcion,
                      style: AppTextStyles.bodyMedium(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ).copyWith(height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.sm),

                    // Footer with metadata
                    Row(
                      children: [
                        // Prioridad
                        PrioridadIndicator(prioridad: reclamo.prioridad),
                        SizedBox(width: AppSpacing.sm),

                        // Categoria with icon
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: AppSpacing.xxxs,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoriaIcon(reclamo.categoria),
                                size: 14,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                              SizedBox(width: AppSpacing.xxxs),
                              Text(
                                reclamo.categoriaDisplayName,
                                style: AppTextStyles.bodySmall(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ).copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Date with icon
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                        ),
                        SizedBox(width: AppSpacing.xxxs),
                        Text(
                          DateFormatter.formatRelative(reclamo.createdAt),
                          style: AppTextStyles.bodySmall(
                            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                          ).copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoriaIcon(String categoria) {
    switch (categoria.toUpperCase()) {
      case 'INTERNET_ADSL':
      case 'INTERNET_FIBRA':
        return Icons.wifi;
      case 'TELEFONO_ADSL':
      case 'TELEFONO_FIBRA':
        return Icons.phone;
      case 'TV_SENSA':
        return Icons.tv;
      default:
        return Icons.help_outline;
    }
  }
}
