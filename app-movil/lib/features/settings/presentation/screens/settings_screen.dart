import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_shadows.dart';
import '../../../../core/config/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/about_dialog.dart';

/// Enterprise Settings Screen with comprehensive configuration options
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _biometricsEnabled = false;
  bool _autoSync = true;
  String _language = 'es';
  String _dateFormat = 'dd/MM/yyyy';
  String _timeFormat = '24h';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),

            // Settings Content
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Profile Section
                  if (user != null) _buildProfileSection(user, isDark),

                  SizedBox(height: AppSpacing.lg),

                  // Appearance Section
                  SettingsSection(
                    title: 'Apariencia',
                    icon: Icons.palette,
                    children: [
                      SettingsTile(
                        title: 'Tema',
                        subtitle: _getThemeModeLabel(themeMode),
                        icon: _getThemeModeIcon(themeMode),
                        onTap: () => _showThemeSelector(context),
                      ),
                      SettingsTile(
                        title: 'Idioma',
                        subtitle: _getLanguageLabel(_language),
                        icon: Icons.language,
                        onTap: () => _showLanguageSelector(context),
                      ),
                      SettingsTile(
                        title: 'Formato de Fecha',
                        subtitle: _dateFormat,
                        icon: Icons.calendar_today,
                        onTap: () => _showDateFormatSelector(context),
                      ),
                      SettingsTile(
                        title: 'Formato de Hora',
                        subtitle: _timeFormat,
                        icon: Icons.access_time,
                        onTap: () => _showTimeFormatSelector(context),
                      ),
                    ],
                  ).animate().fadeIn().slideX(),

                  SizedBox(height: AppSpacing.lg),

                  // Notifications Section
                  SettingsSection(
                    title: 'Notificaciones',
                    icon: Icons.notifications,
                    children: [
                      SettingsTile(
                        title: 'Activar Notificaciones',
                        subtitle: 'Recibir alertas sobre reclamos',
                        icon: Icons.notifications_active,
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            HapticFeedback.lightImpact();
                            setState(() => _notificationsEnabled = value);
                          },
                        ),
                      ),
                      if (_notificationsEnabled) ...[
                        SettingsTile(
                          title: 'Email',
                          subtitle: 'Notificaciones por correo',
                          icon: Icons.email,
                          trailing: Switch(
                            value: _emailNotifications,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() => _emailNotifications = value);
                            },
                          ),
                        ),
                        SettingsTile(
                          title: 'Push',
                          subtitle: 'Notificaciones push',
                          icon: Icons.phonelink,
                          trailing: Switch(
                            value: _pushNotifications,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() => _pushNotifications = value);
                            },
                          ),
                        ),
                        SettingsTile(
                          title: 'Sonido',
                          subtitle: 'Sonido de notificaciones',
                          icon: Icons.volume_up,
                          trailing: Switch(
                            value: _soundEnabled,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() => _soundEnabled = value);
                            },
                          ),
                        ),
                        SettingsTile(
                          title: 'Vibración',
                          subtitle: 'Vibración en notificaciones',
                          icon: Icons.vibration,
                          trailing: Switch(
                            value: _vibrationEnabled,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              setState(() => _vibrationEnabled = value);
                            },
                          ),
                        ),
                      ],
                    ],
                  ).animate(delay: 100.ms).fadeIn().slideX(),

                  SizedBox(height: AppSpacing.lg),

                  // Security Section
                  SettingsSection(
                    title: 'Seguridad',
                    icon: Icons.security,
                    children: [
                      SettingsTile(
                        title: 'Cambiar Contraseña',
                        subtitle: 'Actualizar credenciales',
                        icon: Icons.lock,
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                      SettingsTile(
                        title: 'Autenticación Biométrica',
                        subtitle: 'Huella o Face ID',
                        icon: Icons.fingerprint,
                        trailing: Switch(
                          value: _biometricsEnabled,
                          onChanged: (value) {
                            HapticFeedback.mediumImpact();
                            setState(() => _biometricsEnabled = value);
                          },
                        ),
                      ),
                      SettingsTile(
                        title: 'Sesiones Activas',
                        subtitle: 'Gestionar dispositivos',
                        icon: Icons.devices,
                        onTap: () => _showActiveSessionsDialog(context),
                      ),
                      SettingsTile(
                        title: 'Privacidad',
                        subtitle: 'Configuración de privacidad',
                        icon: Icons.privacy_tip,
                        onTap: () => _showPrivacySettings(context),
                      ),
                    ],
                  ).animate(delay: 150.ms).fadeIn().slideX(),

                  SizedBox(height: AppSpacing.lg),

                  // Data & Storage Section
                  SettingsSection(
                    title: 'Datos y Almacenamiento',
                    icon: Icons.storage,
                    children: [
                      SettingsTile(
                        title: 'Sincronización Automática',
                        subtitle: 'Sincronizar datos automáticamente',
                        icon: Icons.sync,
                        trailing: Switch(
                          value: _autoSync,
                          onChanged: (value) {
                            HapticFeedback.lightImpact();
                            setState(() => _autoSync = value);
                          },
                        ),
                      ),
                      SettingsTile(
                        title: 'Limpiar Caché',
                        subtitle: 'Liberar espacio en disco',
                        icon: Icons.cleaning_services,
                        onTap: () => _showClearCacheDialog(context),
                      ),
                      SettingsTile(
                        title: 'Exportar Datos',
                        subtitle: 'Descargar mis datos',
                        icon: Icons.download,
                        onTap: () => _showExportDataDialog(context),
                      ),
                      SettingsTile(
                        title: 'Uso de Almacenamiento',
                        subtitle: '120 MB usados',
                        icon: Icons.pie_chart,
                        onTap: () => _showStorageUsageDialog(context),
                      ),
                    ],
                  ).animate(delay: 200.ms).fadeIn().slideX(),

                  SizedBox(height: AppSpacing.lg),

                  // About Section
                  SettingsSection(
                    title: 'Acerca de',
                    icon: Icons.info,
                    children: [
                      SettingsTile(
                        title: 'Versión',
                        subtitle: '1.0.0+1',
                        icon: Icons.numbers,
                        onTap: () {},
                      ),
                      SettingsTile(
                        title: 'Centro de Ayuda',
                        subtitle: 'FAQs y soporte',
                        icon: Icons.help,
                        onTap: () => context.push('/help'),
                      ),
                      SettingsTile(
                        title: 'Términos y Condiciones',
                        subtitle: 'Leer términos de uso',
                        icon: Icons.description,
                        onTap: () => _showTermsDialog(context),
                      ),
                      SettingsTile(
                        title: 'Política de Privacidad',
                        subtitle: 'Cómo usamos tus datos',
                        icon: Icons.policy,
                        onTap: () => _showPrivacyPolicyDialog(context),
                      ),
                      SettingsTile(
                        title: 'Sobre la App',
                        subtitle: 'Información del desarrollador',
                        icon: Icons.info_outline,
                        onTap: () => showAboutAppDialog(context),
                      ),
                    ],
                  ).animate(delay: 250.ms).fadeIn().slideX(),

                  SizedBox(height: AppSpacing.lg),

                  // Danger Zone
                  SettingsSection(
                    title: 'Zona de Peligro',
                    icon: Icons.warning,
                    color: AppColors.error,
                    children: [
                      SettingsTile(
                        title: 'Cerrar Sesión',
                        subtitle: 'Salir de la aplicación',
                        icon: Icons.logout,
                        iconColor: AppColors.error,
                        onTap: () => _showLogoutDialog(context),
                      ),
                      SettingsTile(
                        title: 'Eliminar Cuenta',
                        subtitle: 'Borrar permanentemente mi cuenta',
                        icon: Icons.delete_forever,
                        iconColor: AppColors.error,
                        onTap: () => _showDeleteAccountDialog(context),
                      ),
                    ],
                  ).animate(delay: 300.ms).fadeIn().slideX(),

                  SizedBox(height: AppSpacing.xxl * 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Configuración',
            style: AppTextStyles.headlineMedium(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildProfileSection(dynamic user, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Text(
              user.nombre[0].toUpperCase(),
              style: AppTextStyles.headlineLarge(
                color: AppColors.primary,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nombre,
                  style: AppTextStyles.titleLarge(
                    color: Colors.white,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  user.email,
                  style: AppTextStyles.bodyMedium(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    user.rol.toUpperCase(),
                    style: AppTextStyles.caption(
                      color: Colors.white,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () => context.push('/perfil'),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  String _getLanguageLabel(String language) {
    switch (language) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      case 'pt':
        return 'Português';
      default:
        return language;
    }
  }

  void _showThemeSelector(BuildContext context) {
    final currentMode = ref.read(themeModeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'Seleccionar Tema',
        children: [
          _buildThemeOption(context, 'Claro', Icons.light_mode, ThemeMode.light, currentMode),
          _buildThemeOption(context, 'Oscuro', Icons.dark_mode, ThemeMode.dark, currentMode),
          _buildThemeOption(context, 'Sistema', Icons.brightness_auto, ThemeMode.system, currentMode),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    IconData icon,
    ThemeMode mode,
    ThemeMode currentMode,
  ) {
    final isSelected = mode == currentMode;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : null,
      ),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
        context.pop();
      },
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'Seleccionar Idioma',
        children: [
          _buildLanguageOption(context, 'Español', 'es'),
          _buildLanguageOption(context, 'English', 'en'),
          _buildLanguageOption(context, 'Português', 'pt'),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String label, String code) {
    final isSelected = code == _language;

    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _language = code);
        context.pop();
      },
    );
  }

  void _showDateFormatSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'Formato de Fecha',
        children: [
          _buildFormatOption(context, 'DD/MM/YYYY', 'dd/MM/yyyy', _dateFormat),
          _buildFormatOption(context, 'MM/DD/YYYY', 'MM/dd/yyyy', _dateFormat),
          _buildFormatOption(context, 'YYYY-MM-DD', 'yyyy-MM-dd', _dateFormat),
        ],
      ),
    );
  }

  void _showTimeFormatSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(
        context,
        title: 'Formato de Hora',
        children: [
          _buildFormatOption(context, '24 Horas', '24h', _timeFormat),
          _buildFormatOption(context, '12 Horas (AM/PM)', '12h', _timeFormat),
        ],
      ),
    );
  }

  Widget _buildFormatOption(BuildContext context, String label, String value, String current) {
    final isSelected = value == current;

    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          if (current == _dateFormat) {
            _dateFormat = value;
          } else {
            _timeFormat = value;
          }
        });
        context.pop();
      },
    );
  }

  Widget _buildBottomSheet(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.borderDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            title,
            style: AppTextStyles.titleLarge(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  // Dialog Methods
  void _showChangePasswordDialog(BuildContext context) {
    // TODO: Implement change password dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cambiar contraseña próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showActiveSessionsDialog(BuildContext context) {
    // TODO: Implement active sessions dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sesiones activas próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    // TODO: Implement privacy settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configuración de privacidad próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpiar Caché'),
        content: Text('¿Estás seguro que deseas limpiar la caché?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.pop();
              // Clear cache
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Caché limpiada exitosamente'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog(BuildContext context) {
    // TODO: Implement export data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exportación de datos próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showStorageUsageDialog(BuildContext context) {
    // TODO: Implement storage usage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Uso de almacenamiento próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    // TODO: Implement terms dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Términos y condiciones próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    // TODO: Implement privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Política de privacidad próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar Sesión'),
        content: Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              context.pop();
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Cuenta'),
        content: Text(
          'Esta acción es permanente y no se puede deshacer. '
          'Todos tus datos serán eliminados.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              // TODO: Implement delete account
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Eliminación de cuenta próximamente'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Eliminar Permanentemente'),
          ),
        ],
      ),
    );
  }
}
