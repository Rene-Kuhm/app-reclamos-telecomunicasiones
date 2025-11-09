import 'package:flutter/material.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_text_styles.dart';

void showAboutAppDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: AppSpacing.iconLg,
          ),
          SizedBox(width: AppSpacing.sm),
          Text('Sobre la App'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // App Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Icon(
                  Icons.support_agent,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            // App Name
            Center(
              child: Text(
                'Reclamos Telco',
                style: AppTextStyles.headlineMedium(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: AppSpacing.xs),

            // Version
            Center(
              child: Text(
                'Versión 2.0.0 Enterprise Edition',
                style: AppTextStyles.bodyMedium(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            Divider(),

            SizedBox(height: AppSpacing.md),

            // Description
            Text(
              'Sistema enterprise de gestión de reclamos de telecomunicaciones.',
              style: AppTextStyles.bodyMedium(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppSpacing.lg),

            // Features
            _buildFeatureItem(
              icon: Icons.analytics,
              text: 'Analytics Avanzado',
            ),
            _buildFeatureItem(
              icon: Icons.view_kanban,
              text: 'Kanban Board',
            ),
            _buildFeatureItem(
              icon: Icons.search,
              text: 'Búsqueda Inteligente',
            ),
            _buildFeatureItem(
              icon: Icons.dark_mode,
              text: 'Modo Oscuro',
            ),

            SizedBox(height: AppSpacing.lg),

            Divider(),

            SizedBox(height: AppSpacing.md),

            // Credits
            Text(
              'Desarrollado con',
              style: AppTextStyles.caption(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flutter_dash, color: AppColors.info, size: 20),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Flutter',
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.info,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.md),

            // Copyright
            Text(
              '© 2025 Reclamos Telco. Todos los derechos reservados.',
              style: AppTextStyles.caption(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cerrar'),
        ),
      ],
    ),
  );
}

Widget _buildFeatureItem({required IconData icon, required String text}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        SizedBox(width: AppSpacing.sm),
        Text(
          text,
          style: AppTextStyles.bodySmall(color: AppColors.textPrimaryLight),
        ),
      ],
    ),
  );
}
