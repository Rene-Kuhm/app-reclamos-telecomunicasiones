import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_text_styles.dart';

/// Modern empty state with illustrations and actions
/// Enterprise-grade empty state component
class ModernEmptyState extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double iconSize;

  const ModernEmptyState({
    super.key,
    this.icon,
    this.imagePath,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconSize = 120,
  }) : assert(
          icon != null || imagePath != null,
          'Either icon or imagePath must be provided',
        );

  /// No data empty state
  factory ModernEmptyState.noData({
    String title = 'No hay datos',
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return ModernEmptyState(
      icon: Icons.inbox_outlined,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      iconColor: AppColors.textTertiaryDark,
    );
  }

  /// No results empty state (for search/filter)
  factory ModernEmptyState.noResults({
    String title = 'Sin resultados',
    String? description = 'Intenta ajustar tus filtros o criterios de búsqueda',
    String? actionLabel = 'Limpiar filtros',
    VoidCallback? onAction,
  }) {
    return ModernEmptyState(
      icon: Icons.search_off_outlined,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      iconColor: AppColors.textTertiaryDark,
    );
  }

  /// No notifications empty state
  factory ModernEmptyState.noNotifications({
    String title = 'Sin notificaciones',
    String? description = 'No tienes notificaciones nuevas en este momento',
  }) {
    return ModernEmptyState(
      icon: Icons.notifications_off_outlined,
      title: title,
      description: description,
      iconColor: AppColors.textTertiaryDark,
    );
  }

  /// No claims empty state
  factory ModernEmptyState.noClaims({
    String title = 'Sin reclamos',
    String? description = 'Aún no has creado ningún reclamo',
    String? actionLabel = 'Crear reclamo',
    VoidCallback? onAction,
  }) {
    return ModernEmptyState(
      icon: Icons.description_outlined,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      iconColor: AppColors.primary,
    );
  }

  /// Error empty state
  factory ModernEmptyState.error({
    String title = 'Algo salió mal',
    String? description = 'Ocurrió un error al cargar los datos',
    String? actionLabel = 'Reintentar',
    VoidCallback? onAction,
  }) {
    return ModernEmptyState(
      icon: Icons.error_outline,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      iconColor: AppColors.error,
    );
  }

  /// Network error empty state
  factory ModernEmptyState.networkError({
    String title = 'Sin conexión',
    String? description = 'Verifica tu conexión a Internet e intenta nuevamente',
    String? actionLabel = 'Reintentar',
    VoidCallback? onAction,
  }) {
    return ModernEmptyState(
      icon: Icons.wifi_off_outlined,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      iconColor: AppColors.warning,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon or Image
            _buildIcon(isDark)
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                .then(delay: 200.ms)
                .shake(hz: 2, curve: Curves.easeInOut),

            SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              title,
              style: AppTextStyles.headlineSmall(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            // Description
            if (description != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                description!,
                style: AppTextStyles.bodyLarge(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
            ],

            // Action Button
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.sm,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(bool isDark) {
    if (imagePath != null) {
      return Image.asset(
        imagePath!,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackIcon(isDark);
        },
      );
    }

    return _buildFallbackIcon(isDark);
  }

  Widget _buildFallbackIcon(bool isDark) {
    final color = iconColor ??
        (isDark
            ? AppColors.textTertiaryDark
            : AppColors.textTertiaryLight);

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon ?? Icons.inbox_outlined,
        size: iconSize * 0.6,
        color: color,
      ),
    );
  }
}

/// Compact empty state for smaller spaces (like within cards)
class CompactEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color? iconColor;

  const CompactEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = iconColor ??
        (isDark
            ? AppColors.textTertiaryDark
            : AppColors.textTertiaryLight);

    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSpacing.iconXl,
            color: color,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTextStyles.bodyMedium(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
