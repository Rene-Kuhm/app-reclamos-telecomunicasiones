import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_animations.dart';
import '../../../../core/design/app_shadows.dart';
import '../../../../core/widgets/skeleton_loader.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = authState.user;
    final notificacionesNoLeidas = notificacionesState.unreadCount;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${user?.nombre.split(' ')[0] ?? 'Usuario'}',
              style: AppTextStyles.titleMedium(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Bienvenido de vuelta',
              style: AppTextStyles.bodySmall(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
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
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
            // Greeting card with gradient
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.createGradient(AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: AppShadows.card,
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(
                        Icons.wb_sunny_outlined,
                        size: AppSpacing.iconXl,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()}!',
                            style: AppTextStyles.titleLarge(color: Colors.white)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: AppSpacing.xxxs),
                          Text(
                            'Gestiona tus reclamos fácilmente',
                            style: AppTextStyles.bodyMedium(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: AppAnimations.normal).scale(begin: const Offset(0.95, 0.95)),
            SizedBox(height: AppSpacing.lg),

            // Statistics section
            Text(
              'Estadísticas',
              style: AppTextStyles.titleLarge(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: StatisticsCard(
                    title: 'Total',
                    value: stats.total.toString(),
                    icon: Icons.report,
                    color: AppColors.info,
                  ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.3, end: 0),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatisticsCard(
                    title: 'Pendientes',
                    value: stats.pendientes.toString(),
                    icon: Icons.error_outline,
                    color: AppColors.warning,
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3, end: 0),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: StatisticsCard(
                    title: 'En Progreso',
                    value: stats.enProgreso.toString(),
                    icon: Icons.hourglass_empty,
                    color: AppColors.estadoEnProgreso,
                  ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.3, end: 0),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatisticsCard(
                    title: 'Resueltos',
                    value: stats.resueltos.toString(),
                    icon: Icons.check_circle,
                    color: AppColors.success,
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3, end: 0),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),

            // Quick actions section
            Text(
              'Acciones Rápidas',
              style: AppTextStyles.titleLarge(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2, end: 0),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: QuickActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'Nuevo Reclamo',
                    color: AppColors.primary,
                    onTap: () => context.push('/reclamos/create'),
                  ).animate(delay: 400.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: QuickActionButton(
                    icon: Icons.list_alt,
                    label: 'Ver Reclamos',
                    color: AppColors.secondary,
                    onTap: () => context.push('/reclamos'),
                  ).animate(delay: 450.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),

            // Recent reclamos section
            if (reclamosState.reclamos.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reclamos Recientes',
                    style: AppTextStyles.titleLarge(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => context.push('/reclamos'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('Ver todos'),
                  ),
                ],
              ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2, end: 0),
              SizedBox(height: AppSpacing.sm),
              ...reclamosState.reclamos.take(3).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final reclamo = entry.value;
                return Card(
                  margin: EdgeInsets.only(bottom: AppSpacing.xs),
                  child: InkWell(
                    onTap: () => context.push('/reclamos/${reclamo.id}'),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      child: Row(
                        children: [
                          Container(
                            width: AppSpacing.avatarMd,
                            height: AppSpacing.avatarMd,
                            decoration: BoxDecoration(
                              color: AppColors.getPrioridadColor(reclamo.prioridad),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: const Icon(
                              Icons.report_problem,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reclamo.titulo,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyMedium(
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: AppSpacing.xxxs),
                                Text(
                                  reclamo.estadoDisplayName,
                                  style: AppTextStyles.bodySmall(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate(delay: (550 + (index * 50)).ms).fadeIn().slideX(begin: 0.2, end: 0);
              }).toList(),
            ],
          ],
        ),
      ),
        loading: () => Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting skeleton
              SkeletonLoader(
                width: double.infinity,
                height: 120,
                isDark: isDark,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              SizedBox(height: AppSpacing.lg),
              // Statistics skeletons
              SkeletonLoader(
                width: 150,
                height: 24,
                isDark: isDark,
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(child: StatisticsCardSkeleton(isDark: isDark)),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(child: StatisticsCardSkeleton(isDark: isDark)),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(child: StatisticsCardSkeleton(isDark: isDark)),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(child: StatisticsCardSkeleton(isDark: isDark)),
                ],
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: AppSpacing.iconXxl,
                  color: AppColors.error,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Error al cargar',
                  style: AppTextStyles.titleLarge(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  error.toString(),
                  style: AppTextStyles.bodyMedium(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(reclamosStatsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ],
            ),
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
}
