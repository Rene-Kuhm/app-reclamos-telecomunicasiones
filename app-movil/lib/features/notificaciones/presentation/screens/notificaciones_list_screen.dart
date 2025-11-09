import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_shadows.dart';
import '../../../../shared/widgets/index.dart';
import '../providers/notificaciones_provider.dart';
import '../widgets/notificacion_item.dart';

/// Professional notificaciones list screen with enterprise design
class NotificacionesListScreen extends ConsumerStatefulWidget {
  const NotificacionesListScreen({super.key});

  @override
  ConsumerState<NotificacionesListScreen> createState() =>
      _NotificacionesListScreenState();
}

class _NotificacionesListScreenState
    extends ConsumerState<NotificacionesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    Future.microtask(() {
      ref.read(notificacionesProvider.notifier).loadNotificaciones();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        SnackBar(
          content: const Text('Todas las notificaciones marcadas como leídas'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificacionesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final notificacionesNoLeidas = state.notificaciones
        .where((n) => !n.leida)
        .toList();
    final notificacionesLeidas = state.notificaciones
        .where((n) => n.leida)
        .toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Modern gradient AppBar
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.createGradient(AppColors.primaryGradient),
                  boxShadow: innerBoxIsScrolled ? AppShadows.card : null,
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notificaciones',
                    style: AppTextStyles.titleLarge(color: Colors.white)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (state.unreadCount > 0)
                    Text(
                      '${state.unreadCount} sin leer',
                      style: AppTextStyles.bodySmall(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                ],
              ),
              actions: [
                if (state.unreadCount > 0)
                  Container(
                    margin: EdgeInsets.only(right: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: TextButton.icon(
                      onPressed: _markAllAsRead,
                      icon: Icon(
                        Icons.done_all,
                        color: Colors.white,
                        size: AppSpacing.iconSm,
                      ),
                      label: Text(
                        'Marcar todas',
                        style: AppTextStyles.labelMedium(color: Colors.white),
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: Colors.transparent,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.6),
                    labelStyle: AppTextStyles.bodyMedium(color: Colors.white)
                        .copyWith(fontWeight: FontWeight.w600),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('No leídas'),
                            if (state.unreadCount > 0) ...[
                              SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.radiusSm),
                                ),
                                child: Text(
                                  '${state.unreadCount}',
                                  style: AppTextStyles.bodyXSmall(color: Colors.white)
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Tab(text: 'Todas'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // No leídas
            _buildNotificacionesList(
              notificacionesNoLeidas,
              state,
              isDark,
              isEmpty: state.unreadCount == 0,
              emptyMessage: 'No tienes notificaciones sin leer',
            ),
            // Todas
            _buildNotificacionesList(
              state.notificaciones,
              state,
              isDark,
              isEmpty: state.notificaciones.isEmpty,
              emptyMessage: 'No tienes notificaciones',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificacionesList(
    List notificaciones,
    NotificacionesState state,
    bool isDark, {
    required bool isEmpty,
    required String emptyMessage,
  }) {
    if (state.isLoading && state.notificaciones.isEmpty) {
      return Center(
        child: ModernLoading(
          message: 'Cargando notificaciones...',
          color: AppColors.primary,
        ),
      );
    }

    if (state.error != null && state.notificaciones.isEmpty) {
      return ModernEmptyState.error(
        title: 'Error al cargar',
        description: state.error!,
        actionLabel: 'Reintentar',
        onAction: _handleRefresh,
      );
    }

    if (isEmpty) {
      return ModernEmptyState(
        icon: Icons.notifications_none,
        title: 'Sin notificaciones',
        description: emptyMessage,
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: notificaciones.length,
        separatorBuilder: (context, index) => SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final notificacion = notificaciones[index];
          return ModernCard.outlined(
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
            padding: EdgeInsets.zero,
            child: Dismissible(
              key: Key(notificacion.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: AppSpacing.iconMd,
                ),
              ),
              confirmDismiss: (direction) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar notificación'),
                    content: const Text(
                        '¿Estás seguro de que deseas eliminar esta notificación?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      ModernButton(
                        onPressed: () => Navigator.pop(context, true),
                        label: 'Eliminar',
                        color: AppColors.error,
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) async {
                final success = await ref
                    .read(notificacionesProvider.notifier)
                    .deleteNotificacion(notificacion.id);

                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Notificación eliminada'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: NotificacionItem(
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
                      SnackBar(
                        content: const Text('Notificación eliminada'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              ),
            ),
          ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1);
        },
      ),
    );
  }
}
