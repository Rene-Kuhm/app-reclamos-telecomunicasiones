import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final hasFilters = state.estadoFilter != null ||
        state.categoriaFilter != null ||
        state.prioridadFilter != null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mis Reclamos'),
            if (state.reclamos.isNotEmpty)
              Text(
                '${state.reclamos.length} reclamo${state.reclamos.length != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
          ],
        ),
        actions: [
          // Filter button with badge
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: hasFilters
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: hasFilters
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: hasFilters
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: _showFilters,
                ),
              ),
              if (hasFilters)
                Positioned(
                  right: 12,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${(state.estadoFilter != null ? 1 : 0) + (state.categoriaFilter != null ? 1 : 0) + (state.prioridadFilter != null ? 1 : 0)}',
                      style: const TextStyle(
                        color: Colors.white,
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
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar reclamos...',
                prefixIcon: const Icon(Icons.search),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                _onSearchChanged(value);
                setState(() {});
              },
            ),
          ),

          // Active filters display
          if (hasFilters)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (state.estadoFilter != null)
                    Chip(
                      label: Text('Estado: ${state.estadoFilter}'),
                      onDeleted: () {
                        ref.read(reclamosProvider.notifier).setEstadoFilter(null);
                      },
                    ),
                  if (state.categoriaFilter != null)
                    Chip(
                      label: Text('Categoría: ${state.categoriaFilter}'),
                      onDeleted: () {
                        ref.read(reclamosProvider.notifier).setCategoriaFilter(null);
                      },
                    ),
                  if (state.prioridadFilter != null)
                    Chip(
                      label: Text('Prioridad: ${state.prioridadFilter}'),
                      onDeleted: () {
                        ref.read(reclamosProvider.notifier).setPrioridadFilter(null);
                      },
                    ),
                ],
              ),
            ),

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
    if (state.isLoading && state.reclamos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.reclamos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Error al cargar reclamos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                state.error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _handleRefresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.reclamos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      Theme.of(context).colorScheme.primary.withOpacity(0.02),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No hay reclamos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Crea tu primer reclamo usando el botón de abajo',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.push('/reclamos/create'),
                icon: const Icon(Icons.add),
                label: const Text('Crear Reclamo'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: state.reclamos.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.reclamos.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final reclamo = state.reclamos[index];
          return ReclamoCard(
            reclamo: reclamo,
            onTap: () => context.push('/reclamos/${reclamo.id}'),
          );
        },
      ),
    );
  }
}
