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
        title: const Text('Mis Reclamos'),
        actions: [
          // Filter button
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilters,
              ),
              if (hasFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                // Implement search functionality
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
              'Error al cargar reclamos',
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
              onPressed: () => _handleRefresh(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.reclamos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay reclamos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer reclamo usando el botón de abajo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
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
