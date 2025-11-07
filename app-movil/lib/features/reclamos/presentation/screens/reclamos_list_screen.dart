import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_animations.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../providers/reclamos_provider.dart';
import '../widgets/reclamo_card.dart';
import '../widgets/filter_bottom_sheet.dart';

/// Reclamos list screen
class ReclamosListScreen extends ConsumerStatefulWidget {
  const ReclamosListScreen({super.key});

  @override
  ConsumerState<ReclamosListScreen> createState() => _ReclamosListScreenState();
}

class _ReclamosListScreenState extends ConsumerState<ReclamosListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();

    // Load reclamos on init
    Future.microtask(() {
      ref.read(reclamosProvider.notifier).loadReclamos(refresh: true);
    });

    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(reclamosProvider.notifier).loadReclamos();
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reclamosProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasFilters = state.estadoFilter != null ||
        state.categoriaFilter != null ||
        state.prioridadFilter != null;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mis Reclamos',
              style: AppTextStyles.titleMedium(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            if (state.reclamos.isNotEmpty)
              Text(
                '${state.reclamos.length} reclamo${state.reclamos.length != 1 ? 's' : ''}',
                style: AppTextStyles.bodySmall(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
          ],
        ),
        actions: [
          // Filter button with badge
          Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: hasFilters
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: hasFilters
                      ? Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: hasFilters
                        ? AppColors.primary
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  ),
                  onPressed: _showFilters,
                ),
              ),
              if (hasFilters)
                Positioned(
                  right: 12,
                  top: 16,
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.xxxs),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${(state.estadoFilter != null ? 1 : 0) + (state.categoriaFilter != null ? 1 : 0) + (state.prioridadFilter != null ? 1 : 0)}',
                      style: AppTextStyles.bodySmall(color: Colors.white).copyWith(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar reclamos...',
                hintStyle: AppTextStyles.bodyMedium(
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                filled: true,
              ),
              onChanged: (value) {
                _onSearchChanged(value);
                setState(() {});
              },
            ).animate().fadeIn(delay: 50.ms).slideY(begin: -0.2, end: 0),
          ),

          // Active filters display
          if (hasFilters)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  if (state.estadoFilter != null)
                    Chip(
                      label: Text(
                        'Estado: ${state.estadoFilter}',
                        style: AppTextStyles.bodySmall(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      deleteIconColor: AppColors.primary,
                      onDeleted: () {
                        ref.read(reclamosProvider.notifier).setEstadoFilter(null);
                      },
                    ),
                  if (state.categoriaFilter != null)
                    Chip(
                      label: Text(
                        'Categoría: ${state.categoriaFilter}',
                        style: AppTextStyles.bodySmall(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      backgroundColor: AppColors.secondary.withOpacity(0.1),
                      deleteIconColor: AppColors.secondary,
                      onDeleted: () {
                        ref.read(reclamosProvider.notifier).setCategoriaFilter(null);
                      },
                    ),
                  if (state.prioridadFilter != null)
                    Chip(
                      label: Text(
                        'Prioridad: ${state.prioridadFilter}',
                        style: AppTextStyles.bodySmall(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      backgroundColor: AppColors.warning.withOpacity(0.1),
                      deleteIconColor: AppColors.warning,
                      onDeleted: () {
                        ref.read(reclamosProvider.notifier).setPrioridadFilter(null);
                      },
                    ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1, end: 0),

          // Reclamos list
          Expanded(
            child: _buildContent(state),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reclamos/create'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Reclamo'),
      ),
    );
  }

  Widget _buildContent(ReclamosState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.isLoading && state.reclamos.isEmpty) {
      return ListSkeleton(itemCount: 5, isDark: isDark);
    }

    if (state.error != null && state.reclamos.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: AppSpacing.iconXxl,
                  color: AppColors.error,
                ),
              ).animate().scale(begin: const Offset(0.8, 0.8)),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Error al cargar reclamos',
                style: AppTextStyles.titleLarge(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),
              SizedBox(height: AppSpacing.sm),
              Text(
                state.error!,
                style: AppTextStyles.bodyMedium(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 150.ms).fadeIn(),
              SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: () => _handleRefresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
            ],
          ),
        ),
      );
    }

    if (state.reclamos.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.08),
                      AppColors.primary.withOpacity(0.02),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isDark ? AppColors.outlineDark : AppColors.outlineLight).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.inbox_outlined,
                  size: AppSpacing.iconXxl,
                  color: AppColors.primary,
                ),
              ).animate().scale(begin: const Offset(0.8, 0.8)),
              SizedBox(height: AppSpacing.lg),
              Text(
                'No hay reclamos',
                style: AppTextStyles.titleLarge(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Crea tu primer reclamo usando el botón de abajo',
                style: AppTextStyles.bodyMedium(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 150.ms).fadeIn(),
              SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: () => context.push('/reclamos/create'),
                icon: const Icon(Icons.add),
                label: const Text('Crear Reclamo'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: AppSpacing.xxl * 2),
        itemCount: state.reclamos.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.reclamos.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: const CircularProgressIndicator(),
              ),
            );
          }

          final reclamo = state.reclamos[index];
          return ReclamoCard(
            reclamo: reclamo,
            onTap: () => context.push('/reclamos/${reclamo.id}'),
          ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }
}
