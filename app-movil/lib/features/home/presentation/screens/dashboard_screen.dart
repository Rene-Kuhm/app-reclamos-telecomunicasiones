import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../reclamos/presentation/providers/reclamos_provider.dart';
import '../../../reclamos/presentation/providers/reclamos_stats_provider.dart';
import '../../../notificaciones/presentation/providers/notificaciones_provider.dart';
import '../widgets/statistics_card.dart';
import '../widgets/quick_action_button.dart';

/// Dashboard screen
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificacionesProvider.notifier).loadNotificaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final statsAsync = ref.watch(reclamosStatsProvider);
    final notificacionesState = ref.watch(notificacionesProvider);
    final reclamosState = ref.watch(reclamosProvider);

    final user = authState.user;
    final notificacionesNoLeidas = notificacionesState.unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${user?.nombre.split(' ')[0] ?? 'Usuario'}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Bienvenido de vuelta',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.refresh(reclamosStatsProvider.future),
              ref.read(notificacionesProvider.notifier).refresh(),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
            // Greeting card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.wb_sunny_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()}!',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gestiona tus reclamos fácilmente',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistics section
            Text(
              'Estadísticas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatisticsCard(
                    title: 'Total',
                    value: stats.total.toString(),
                    icon: Icons.report,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatisticsCard(
                    title: 'Pendientes',
                    value: stats.pendientes.toString(),
                    icon: Icons.error_outline,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatisticsCard(
                    title: 'En Progreso',
                    value: stats.enProgreso.toString(),
                    icon: Icons.hourglass_empty,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatisticsCard(
                    title: 'Resueltos',
                    value: stats.resueltos.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick actions section
            Text(
              'Acciones Rápidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: QuickActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'Nuevo Reclamo',
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => context.push('/reclamos/create'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickActionButton(
                    icon: Icons.list_alt,
                    label: 'Ver Reclamos',
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: () => context.push('/reclamos'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent reclamos section
            if (reclamosState.reclamos.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reclamos Recientes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/reclamos'),
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...reclamosState.reclamos.take(3).map((reclamo) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getPrioridadColor(reclamo.prioridad),
                      child: const Icon(Icons.report_problem, color: Colors.white),
                    ),
                    title: Text(
                      reclamo.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(reclamo.estadoDisplayName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/reclamos/${reclamo.id}'),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.invalidate(reclamosStatsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  Color _getPrioridadColor(String prioridad) {
    switch (prioridad.toUpperCase()) {
      case 'BAJA':
        return Colors.green;
      case 'MEDIA':
        return Colors.orange;
      case 'ALTA':
        return Colors.red;
      case 'URGENTE':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }
}
