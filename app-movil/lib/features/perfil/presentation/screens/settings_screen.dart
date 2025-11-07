import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/theme_provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/providers/push_notification_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final pushState = ref.watch(pushNotificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          // Notifications Section
          _buildSectionHeader(context, 'Notificaciones'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('Notificaciones Push'),
            subtitle: Text(
              pushState.hasPermission
                  ? 'Las notificaciones están activadas'
                  : 'Las notificaciones están desactivadas',
            ),
            value: pushState.hasPermission,
            onChanged: (value) async {
              if (value) {
                await ref.read(pushNotificationProvider.notifier).optIn();
                await ref.read(pushNotificationProvider.notifier).requestPermission();
              } else {
                await ref.read(pushNotificationProvider.notifier).optOut();
              }
            },
          ),
          if (pushState.playerId != null)
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('ID del Dispositivo'),
              subtitle: Text(
                pushState.playerId!,
                style: const TextStyle(fontSize: 10),
              ),
              isThreeLine: true,
            ),
          const Divider(),

          // Appearance Section
          _buildSectionHeader(context, 'Apariencia'),
          _buildThemeTile(
            context,
            ref,
            title: 'Tema Claro',
            icon: Icons.light_mode,
            themeMode: ThemeMode.light,
            currentMode: themeMode,
          ),
          _buildThemeTile(
            context,
            ref,
            title: 'Tema Oscuro',
            icon: Icons.dark_mode,
            themeMode: ThemeMode.dark,
            currentMode: themeMode,
          ),
          _buildThemeTile(
            context,
            ref,
            title: 'Tema del Sistema',
            icon: Icons.brightness_auto,
            themeMode: ThemeMode.system,
            currentMode: themeMode,
          ),
          const Divider(),

          // App Information Section
          _buildSectionHeader(context, 'Información de la App'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Versión'),
            subtitle: Text(AppConfig.appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Ambiente'),
            subtitle: Text(AppConfig.environment.toUpperCase()),
          ),
          ListTile(
            leading: const Icon(Icons.api),
            title: const Text('API Base URL'),
            subtitle: Text(AppConfig.baseUrl),
            isThreeLine: true,
          ),
          const Divider(),

          // Support Section
          _buildSectionHeader(context, 'Soporte'),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Contactar Soporte'),
            subtitle: Text(AppConfig.supportEmail),
            onTap: () {
              // TODO: Open email client
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Contactar a: ${AppConfig.supportEmail}'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Política de Privacidad'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // TODO: Open privacy policy URL
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Abriendo política de privacidad...'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Términos de Servicio'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // TODO: Open terms of service URL
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Abriendo términos de servicio...'),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // App Logo and Credits
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.phone_in_talk_rounded,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  AppConfig.appName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v${AppConfig.appVersion}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required IconData icon,
    required ThemeMode themeMode,
    required ThemeMode currentMode,
  }) {
    final isSelected = themeMode == currentMode;

    return RadioListTile<ThemeMode>(
      value: themeMode,
      groupValue: currentMode,
      onChanged: (ThemeMode? value) {
        if (value != null) {
          ref.read(themeModeProvider.notifier).setThemeMode(value);
        }
      },
      title: Text(title),
      secondary: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
    );
  }
}
