import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_animations.dart';
import '../../../../core/design/app_shadows.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../reclamos/presentation/providers/reclamos_provider.dart';
import '../../../reclamos/presentation/providers/reclamos_stats_provider.dart';
import '../../../notificaciones/presentation/providers/notificaciones_provider.dart';
import '../widgets/advanced_metric_card.dart';
import '../widgets/trend_chart_card.dart';
import '../widgets/donut_chart_card.dart';
import '../widgets/recent_claims_table.dart';
import '../widgets/dashboard_header.dart';

/// Enterprise-grade professional admin dashboard
class EnterpriseDashboardScreen extends ConsumerStatefulWidget {
  const EnterpriseDashboardScreen({super.key});

  @override
  ConsumerState<EnterpriseDashboardScreen> createState() =>
      _EnterpriseDashboardScreenState();
}

class _EnterpriseDashboardScreenState
    extends ConsumerState<EnterpriseDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificacionesProvider.notifier).loadNotificaciones();
      ref.read(reclamosProvider.notifier).loadReclamos();
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
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Professional Header
            const DashboardHeader(),

            // Main Content
            Expanded(
              child: statsAsync.when(
                data: (stats) => RefreshIndicator(
                  onRefresh: () async {
                    await Future.wait([
                      ref.refresh(reclamosStatsProvider.future),
                      ref.read(notificacionesProvider.notifier).refresh(),
                      ref.read(reclamosProvider.notifier).loadReclamos(),
                    ]);
                  },
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                // KPI Metrics Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isLargeScreen = constraints.maxWidth > 1200;
                    final isMediumScreen = constraints.maxWidth > 800;
                    final crossAxisCount = isLargeScreen ? 4 : (isMediumScreen ? 2 : 1);

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1.5,
                      children: [
                        AdvancedMetricCard(
                          title: 'Total Reclamos',
                          value: stats.total.toString(),
                          subtitle: 'Todos los estados',
                          icon: Icons.analytics,
                          color: AppColors.info,
                          percentChange: 12.5,
                          isPositiveTrend: true,
                          progress: stats.total > 0 ? 0.85 : 0.0,
                          onTap: () => context.push('/reclamos'),
                        ).animate(delay: 100.ms).fadeIn().scale(),
                        AdvancedMetricCard(
                          title: 'Pendientes',
                          value: stats.pendientes.toString(),
                          subtitle: 'Requieren atención',
                          icon: Icons.pending_actions,
                          color: AppColors.warning,
                          percentChange: -5.2,
                          isPositiveTrend: false,
                          progress: stats.total > 0 ? stats.pendientes / stats.total : 0.0,
                        ).animate(delay: 150.ms).fadeIn().scale(),
                        AdvancedMetricCard(
                          title: 'En Progreso',
                          value: stats.enProgreso.toString(),
                          subtitle: 'En resolución',
                          icon: Icons.autorenew,
                          color: AppColors.estadoEnCurso,
                          percentChange: 8.3,
                          isPositiveTrend: true,
                          progress: stats.total > 0 ? stats.enProgreso / stats.total : 0.0,
                        ).animate(delay: 200.ms).fadeIn().scale(),
                        AdvancedMetricCard(
                          title: 'Resueltos',
                          value: stats.resueltos.toString(),
                          subtitle: 'Completados',
                          icon: Icons.check_circle,
                          color: AppColors.success,
                          percentChange: 15.7,
                          isPositiveTrend: true,
                          progress: stats.total > 0 ? stats.resueltos / stats.total : 0.0,
                        ).animate(delay: 250.ms).fadeIn().scale(),
                      ],
                    );
                  },
                ),

                SizedBox(height: AppSpacing.lg),

                // Charts Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 1000) {
                      // Desktop: side by side
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TrendChartCard(
                              title: 'Tendencia de Reclamos',
                              subtitle: 'Últimos 7 días',
                              lineColor: AppColors.primary,
                              maxY: 50,
                              dataPoints: [
                                const FlSpot(0, 12),
                                const FlSpot(1, 18),
                                const FlSpot(2, 15),
                                const FlSpot(3, 25),
                                const FlSpot(4, 22),
                                const FlSpot(5, 30),
                                const FlSpot(6, 28),
                              ],
                            ).animate(delay: 300.ms).fadeIn().slideX(),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: DonutChartCard(
                              title: 'Distribución por Estado',
                              subtitle: 'Vista general',
                              data: [
                                ChartData(
                                  label: 'Pendientes',
                                  value: stats.pendientes.toDouble(),
                                  color: AppColors.warning,
                                ),
                                ChartData(
                                  label: 'En Progreso',
                                  value: stats.enProgreso.toDouble(),
                                  color: AppColors.estadoEnCurso,
                                ),
                                ChartData(
                                  label: 'Resueltos',
                                  value: stats.resueltos.toDouble(),
                                  color: AppColors.success,
                                ),
                                ChartData(
                                  label: 'Cerrados',
                                  value: stats.cerrados.toDouble(),
                                  color: AppColors.estadoCerrado,
                                ),
                              ],
                            ).animate(delay: 350.ms).fadeIn().slideX(),
                          ),
                        ],
                      );
                    } else {
                      // Mobile/Tablet: stacked
                      return Column(
                        children: [
                          TrendChartCard(
                            title: 'Tendencia de Reclamos',
                            subtitle: 'Últimos 7 días',
                            lineColor: AppColors.primary,
                            maxY: 50,
                            dataPoints: [
                              const FlSpot(0, 12),
                              const FlSpot(1, 18),
                              const FlSpot(2, 15),
                              const FlSpot(3, 25),
                              const FlSpot(4, 22),
                              const FlSpot(5, 30),
                              const FlSpot(6, 28),
                            ],
                          ).animate(delay: 300.ms).fadeIn().slideY(),
                          SizedBox(height: AppSpacing.md),
                          DonutChartCard(
                            title: 'Distribución por Estado',
                            subtitle: 'Vista general',
                            data: [
                              ChartData(
                                label: 'Pendientes',
                                value: stats.pendientes.toDouble(),
                                color: AppColors.warning,
                              ),
                              ChartData(
                                label: 'En Progreso',
                                value: stats.enProgreso.toDouble(),
                                color: AppColors.estadoEnCurso,
                              ),
                              ChartData(
                                label: 'Resueltos',
                                value: stats.resueltos.toDouble(),
                                color: AppColors.success,
                              ),
                              ChartData(
                                label: 'Cerrados',
                                value: stats.cerrados.toDouble(),
                                color: AppColors.estadoCerrado,
                              ),
                            ],
                          ).animate(delay: 350.ms).fadeIn().slideY(),
                        ],
                      );
                    }
                  },
                ),

                SizedBox(height: AppSpacing.lg),

                // Recent Claims Table
                if (reclamosState.reclamos.isNotEmpty)
                  RecentClaimsTable(
                    reclamos: reclamosState.reclamos.take(10).toList(),
                    onRowTap: (id) => context.push('/reclamos/$id'),
                  ).animate(delay: 400.ms).fadeIn().slideY(),
                      ],
                    ),
                  ),
                ),
                loading: () => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Cargando dashboard...',
                        style: AppTextStyles.bodyMedium(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: AppSpacing.iconXxl * 2,
                        color: AppColors.error,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Error al cargar el dashboard',
                        style: AppTextStyles.titleLarge(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        error.toString(),
                        style: AppTextStyles.bodyMedium(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
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
          ],
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
