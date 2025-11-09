import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_shadows.dart';
import '../../domain/entities/reclamo.dart';

/// Premium reclamo card with enterprise design
class PremiumReclamoCard extends StatelessWidget {
  final Reclamo reclamo;
  final VoidCallback onTap;
  final int index;

  const PremiumReclamoCard({
    super.key,
    required this.reclamo,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final estadoColor = AppColors.getEstadoColor(reclamo.estado);
    final prioridadColor = AppColors.getPrioridadColor(reclamo.prioridad);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  isDark
                      ? AppColors.surfaceDark.withOpacity(0.95)
                      : AppColors.surfaceLight.withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: isDark
                    ? AppColors.borderDark.withOpacity(0.5)
                    : AppColors.borderLight.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: AppShadows.card,
            ),
            child: Stack(
              children: [
                // Gradient accent line on the left
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          prioridadColor,
                          prioridadColor.withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSpacing.radiusLg),
                        bottomLeft: Radius.circular(AppSpacing.radiusLg),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row with ID and status
                      Row(
                        children: [
                          // Claim number chip
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xxxs,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.8),
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              reclamo.numero ?? '#${reclamo.id.substring(0, 6)}',
                              style: AppTextStyles.bodyXSmall(
                                color: Colors.white,
                              ).copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),

                          // Status badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xxxs,
                            ),
                            decoration: BoxDecoration(
                              color: estadoColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                              border: Border.all(
                                color: estadoColor.withOpacity(0.3),
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
                                    color: estadoColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: estadoColor.withOpacity(0.5),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: AppSpacing.xxxs),
                                Text(
                                  reclamo.estadoDisplayName,
                                  style: AppTextStyles.bodyXSmall(
                                    color: estadoColor,
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),

                          // Priority icon
                          Container(
                            padding: EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: prioridadColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Icon(
                              _getPriorityIcon(reclamo.prioridad),
                              size: 16,
                              color: prioridadColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.sm),

                      // Title
                      Text(
                        reclamo.titulo,
                        style: AppTextStyles.titleSmall(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ).copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSpacing.xs),

                      // Description
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
                      SizedBox(height: AppSpacing.sm),

                      // Footer with metadata
                      Row(
                        children: [
                          // Category chip
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xxxs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 12,
                                  color: AppColors.secondary,
                                ),
                                SizedBox(width: AppSpacing.xxxs),
                                Text(
                                  _formatCategoria(reclamo.categoria),
                                  style: AppTextStyles.bodyXSmall(
                                    color: AppColors.secondary,
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),

                          // Date
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                          SizedBox(width: AppSpacing.xxxs),
                          Text(
                            _formatDate(reclamo.createdAt),
                            style: AppTextStyles.bodyXSmall(
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight,
                            ),
                          ),
                          const Spacer(),

                          // Arrow icon
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 50 * index))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0);
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toUpperCase()) {
      case 'URGENTE':
        return Icons.priority_high;
      case 'ALTA':
        return Icons.arrow_upward;
      case 'MEDIA':
        return Icons.remove;
      case 'BAJA':
        return Icons.arrow_downward;
      default:
        return Icons.help_outline;
    }
  }

  String _formatCategoria(String categoria) {
    return categoria
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes}m';
      }
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return DateFormat('dd/MM/yy').format(date);
    }
  }
}
