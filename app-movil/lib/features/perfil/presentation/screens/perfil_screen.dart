import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // User avatar and name
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          user.nombre[0].toUpperCase(),
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.nombre,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // User info section
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text('Teléfono'),
                        subtitle: Text(user.telefono),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text('Dirección'),
                        subtitle: Text(user.direccion),
                      ),
                      if (user.dni != null) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.badge),
                          title: const Text('DNI'),
                          subtitle: Text(user.dni!),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Actions section
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Editar perfil'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/perfil/edit'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('Cambiar contraseña'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/perfil/change-password'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Logout button
                FilledButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
    );
  }
}
