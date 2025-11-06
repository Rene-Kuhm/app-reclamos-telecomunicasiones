import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notificaciones_provider.dart';
import '../widgets/notificacion_item.dart';

/// Notificaciones list screen
class NotificacionesListScreen extends ConsumerStatefulWidget {
  const NotificacionesListScreen({super.key});

  @override
  ConsumerState<NotificacionesListScreen> createState() =>
      _NotificacionesListScreenState();
}

class _NotificacionesListScreenState
    extends ConsumerState<NotificacionesListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificacionesProvider.notifier).loadNotificaciones();
    });
  }

  Future<void> _handleRefresh() async {
    await ref.read(notificacionesProvider.notifier).refresh();
  }

  Future<void> _markAllAsRead() async {
    final success =
        await ref.read(notificacionesProvider.notifier).marcarTodasLeidas();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todas las notificaciones marcadas como leídas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificacionesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Marcar todas como leídas'),
            ),
        ],
      ),
      body: _buildContent(state),
    );
  }

  Widget _buildContent(NotificacionesState state) {
    if (state.isLoading && state.notificaciones.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.notificaciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar notificaciones',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleRefresh,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.notificaciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes notificaciones',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        itemCount: state.notificaciones.length,
        itemBuilder: (context, index) {
          final notificacion = state.notificaciones[index];
          return NotificacionItem(
            notificacion: notificacion,
            onTap: () async {
              if (!notificacion.leida) {
                await ref
                    .read(notificacionesProvider.notifier)
                    .marcarLeida(notificacion.id);
              }

              if (notificacion.reclamoId != null && mounted) {
                context.push('/reclamos/${notificacion.reclamoId}');
              }
            },
            onDelete: () async {
              final success = await ref
                  .read(notificacionesProvider.notifier)
                  .deleteNotificacion(notificacion.id);

              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notificación eliminada')),
                );
              }
            },
          );
        },
      ),
    );
  }
}
