import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_animations.dart';
import '../../../../core/design/app_shadows.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/perfil_provider.dart';

/// Perfil screen
class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(perfilProvider.notifier).loadProfile();
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final perfilState = ref.watch(perfilProvider);
    final user = perfilState.user ?? authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Mi Perfil',
          style: AppTextStyles.titleMedium(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(AppSpacing.md),
              children: [
                // User avatar and name
                Center(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.createGradient(AppColors.primaryGradient),
                          boxShadow: AppShadows.elevation8,
                        ),
                        child: CircleAvatar(
                          radius: AppSpacing.avatarLg / 2,
                          backgroundColor: Colors.transparent,
                          child: Text(
                            user.nombre[0].toUpperCase(),
                            style: AppTextStyles.headlineLarge(color: Colors.white).copyWith(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn(),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        user.nombre,
                        style: AppTextStyles.headlineSmall(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),
                      SizedBox(height: AppSpacing.xxxs),
                      Text(
                        user.email,
                        style: AppTextStyles.bodyMedium(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ).animate(delay: 150.ms).fadeIn(),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xxl),

                // User info section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    side: BorderSide(
                      color: (isDark ? AppColors.outlineDark : AppColors.outlineLight).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Icon(Icons.phone, color: AppColors.info, size: AppSpacing.iconMd),
                        ),
                        title: Text(
                          'Teléfono',
                          style: AppTextStyles.bodyMedium(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          user.telefono ?? 'No especificado',
                          style: AppTextStyles.bodySmall(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                      Divider(height: 1, color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Icon(Icons.home, color: AppColors.success, size: AppSpacing.iconMd),
                        ),
                        title: Text(
                          'Dirección',
                          style: AppTextStyles.bodyMedium(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          user.direccion ?? 'No especificada',
                          style: AppTextStyles.bodySmall(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                      if (user.dni != null) ...[
                        Divider(height: 1, color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                        ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: Icon(Icons.badge, color: AppColors.warning, size: AppSpacing.iconMd),
                          ),
                          title: Text(
                            'DNI',
                            style: AppTextStyles.bodyMedium(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            user.dni!,
                            style: AppTextStyles.bodySmall(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
                SizedBox(height: AppSpacing.md),

                // Actions section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    side: BorderSide(
                      color: (isDark ? AppColors.outlineDark : AppColors.outlineLight).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Icon(Icons.edit, color: AppColors.primary, size: AppSpacing.iconMd),
                        ),
                        title: Text(
                          'Editar perfil',
                          style: AppTextStyles.bodyMedium(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                        ),
                        onTap: () => context.push('/perfil/edit'),
                      ),
                      Divider(height: 1, color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Icon(Icons.lock, color: AppColors.secondary, size: AppSpacing.iconMd),
                        ),
                        title: Text(
                          'Cambiar contraseña',
                          style: AppTextStyles.bodyMedium(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                        ),
                        onTap: () => context.push('/perfil/change-password'),
                      ),
                      Divider(height: 1, color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Icon(Icons.settings, color: AppColors.info, size: AppSpacing.iconMd),
                        ),
                        title: Text(
                          'Configuración',
                          style: AppTextStyles.bodyMedium(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                        ),
                        onTap: () => context.push('/perfil/settings'),
                      ),
                    ],
                  ),
                ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.2, end: 0),
                SizedBox(height: AppSpacing.md),

                // Logout button
                FilledButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.all(AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ).animate(delay: 300.ms).fadeIn().scale(begin: const Offset(0.95, 0.95)),
              ],
            ),
    );
  }
}
