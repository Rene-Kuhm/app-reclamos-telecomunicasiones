import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_shadows.dart';
import '../providers/reclamos_provider.dart';
import '../widgets/premium_reclamo_card.dart';
import '../widgets/filter_bottom_sheet.dart';

/// Premium reclamos list screen with enterprise design
class PremiumReclamosListScreen extends ConsumerStatefulWidget {
  const PremiumReclamosListScreen({super.key});

  @override
  ConsumerState<PremiumReclamosListScreen> createState() =>
      _PremiumReclamosListScreenState();
}

class _PremiumReclamosListScreenState
    extends ConsumerState<PremiumReclamosListScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  late TabController _tabController;

  final List<String> _estadoTabs = [
    'TODOS',
    'ABIERTO',
    'EN_CURSO',
    'EN_REVISION',
    'CERRADO',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _estadoTabs.length, vsync: this);

    Future.microtask(() {
      ref.read(reclamosProvider.notifier).loadReclamos(refresh: true);
    });

    _scrollController.addListener(_onScroll);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(reclamosProvider.notifier).loadReclamos();
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final estado = _estadoTabs[_tabController.index];
      if (estado == 'TODOS') {
        ref.read(reclamosProvider.notifier).setEstadoFilter(null);
      } else {
        ref.read(reclamosProvider.notifier).setEstadoFilter(estado);
      }
    }
  }

  Future<void> _handleRefresh() async {
    await ref.read(reclamosProvider.notifier).refresh();
  }

  void _onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(reclamosProvider.notifier).searchReclamos(query);
    });
  }

  void _showFilters() {
    final state = ref.read(reclamosProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        child: FilterBottomSheet(
          estadoFilter: state.estadoFilter,
          categoriaFilter: state.categoriaFilter,
          prioridadFilter: state.prioridadFilter,
          onApplyFilters: (estado, categoria, prioridad) {
            if (estado != null) {
              ref.read(reclamosProvider.notifier).setEstadoFilter(estado);
            }
            if (categoria != null) {
              ref.read(reclamosProvider.notifier).setCategoriaFilter(categoria);
            }
            if (prioridad != null) {
              ref.read(reclamosProvider.notifier).setPrioridadFilter(prioridad);
            }
            if (estado == null && categoria == null && prioridad == null) {
              ref.read(reclamosProvider.notifier).clearFilters();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reclamosProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasFilters = state.categoriaFilter != null || state.prioridadFilter != null;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // App bar with gradient
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
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
                    'Mis Reclamos',
                    style: AppTextStyles.titleLarge(color: Colors.white)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (state.reclamos.isNotEmpty)
                    Text(
                      '${state.reclamos.length} reclamo${state.reclamos.length != 1 ? 's' : ''}',
                      style: AppTextStyles.bodySmall(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                ],
              ),
              actions: [
                // Filter button
                Container(
                  margin: EdgeInsets.only(right: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: hasFilters
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: hasFilters
                        ? Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          )
                        : null,
                  ),
                  child: IconButton(
                    icon: Icon(
                      hasFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                      color: Colors.white,
                    ),
                    onPressed: _showFilters,
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(110),
                child: Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: AppTextStyles.bodyMedium(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Buscar reclamos...',
                            hintStyle: AppTextStyles.bodyMedium(
                              color: Colors.white.withOpacity(0.6),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Tabs
                    Container(
                      color: Colors.transparent,
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorColor: Colors.white,
                        indicatorWeight: 3,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white.withOpacity(0.6),
                        labelStyle: AppTextStyles.bodyMedium(color: Colors.white)
                            .copyWith(fontWeight: FontWeight.w600),
                        unselectedLabelStyle:
                            AppTextStyles.bodySmall(color: Colors.white),
                        tabs: _estadoTabs.map((estado) {
                          final count = estado == 'TODOS'
                              ? state.reclamos.length
                              : state.reclamos
                                  .where((r) => r.estado == estado)
                                  .length;
                          return Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_formatEstado(estado)),
                                if (count > 0) ...[
                                  SizedBox(width: AppSpacing.xxxs),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xxs,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusSm),
                                    ),
                                    child: Text(
                                      count.toString(),
                                      style: AppTextStyles.bodyXSmall(
                                        color: Colors.white,
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: state.isLoading && state.reclamos.isEmpty
              ? _buildLoadingState(isDark)
              : state.error != null && state.reclamos.isEmpty
                  ? _buildErrorState(isDark, state.error!)
                  : state.reclamos.isEmpty
                      ? _buildEmptyState(isDark)
                      : _buildReclamosList(state, isDark),
        ),
      ),

      // FAB for creating new reclamo
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reclamos/create'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Nuevo Reclamo',
          style: AppTextStyles.labelLarge(color: Colors.white),
        ),
        elevation: 8,
      ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }

  Widget _buildReclamosList(ReclamosState state, bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: state.reclamos.length + (state.isLoading && state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.reclamos.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        final reclamo = state.reclamos[index];
        return PremiumReclamoCard(
          reclamo: reclamo,
          index: index,
          onTap: () => context.push('/reclamos/${reclamo.id}'),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Cargando reclamos...',
            style: AppTextStyles.bodyMedium(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
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
              'Error al cargar',
              style: AppTextStyles.titleLarge(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              error,
              style: AppTextStyles.bodyMedium(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _handleRefresh,
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
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: AppSpacing.iconXxl * 3,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'No hay reclamos',
              style: AppTextStyles.titleLarge(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Crea tu primer reclamo usando el botón de abajo',
              style: AppTextStyles.bodyMedium(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatEstado(String estado) {
    switch (estado) {
      case 'TODOS':
        return 'Todos';
      case 'ABIERTO':
        return 'Abiertos';
      case 'EN_CURSO':
        return 'En Curso';
      case 'EN_REVISION':
        return 'En Revisión';
      case 'CERRADO':
        return 'Cerrados';
      default:
        return estado;
    }
  }
}
