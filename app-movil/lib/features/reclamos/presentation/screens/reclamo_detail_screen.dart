import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/reclamo_detail_provider.dart';
import '../widgets/estado_chip.dart';
import '../widgets/prioridad_indicator.dart';
import '../widgets/comentario_item.dart';
import '../widgets/archivo_item.dart';

/// Reclamo detail screen
class ReclamoDetailScreen extends ConsumerStatefulWidget {
  final String reclamoId;

  const ReclamoDetailScreen({
    super.key,
    required this.reclamoId,
  });

  @override
  ConsumerState<ReclamoDetailScreen> createState() => _ReclamoDetailScreenState();
}

class _ReclamoDetailScreenState extends ConsumerState<ReclamoDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _comentarioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data on init
    Future.microtask(() {
      final notifier = ref.read(reclamoDetailProvider(widget.reclamoId).notifier);
      notifier.loadReclamo();
      notifier.loadComentarios();
      notifier.loadArchivos();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await ref.read(reclamoDetailProvider(widget.reclamoId).notifier).refresh();
  }

  Future<void> _handleAddComentario() async {
    if (_comentarioController.text.trim().isEmpty) return;

    final success = await ref
        .read(reclamoDetailProvider(widget.reclamoId).notifier)
        .createComentario(_comentarioController.text.trim());

    if (!mounted) return;

    if (success) {
      _comentarioController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario agregado')),
      );
    } else {
      final error = ref.read(reclamoDetailProvider(widget.reclamoId)).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al agregar comentario'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reclamoDetailProvider(widget.reclamoId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Reclamo'),
        actions: [
          if (state.reclamo != null && !state.reclamo!.isClosed)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/reclamos/${widget.reclamoId}/edit'),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: state.isLoading && state.reclamo == null
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.reclamo == null
              ? _buildErrorView(state.error!)
              : _buildContent(state),
    );
  }

  Widget _buildErrorView(String error) {
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
            'Error al cargar reclamo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
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

  Widget _buildContent(state) {
    final reclamo = state.reclamo!;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        slivers: [
          // Reclamo info section
          SliverToBoxAdapter(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (reclamo.numero != null)
                          Text(
                            '#${reclamo.numero}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        EstadoChip(estado: reclamo.estado),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      reclamo.titulo,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Metadata
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(
                          Icons.category_outlined,
                          reclamo.categoriaDisplayName,
                        ),
                        PrioridadIndicator(prioridad: reclamo.prioridad),
                        _buildInfoChip(
                          Icons.calendar_today,
                          DateFormatter.formatDate(reclamo.createdAt),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Descripción',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reclamo.descripcion,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tabs
          SliverToBoxAdapter(
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Comentarios'),
                Tab(text: 'Archivos'),
              ],
            ),
          ),

          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildComentariosTab(state),
                _buildArchivosTab(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildComentariosTab(state) {
    return Column(
      children: [
        // Comentarios list
        Expanded(
          child: state.isLoadingComentarios && state.comentarios.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.comentarios.isEmpty
                  ? const Center(child: Text('No hay comentarios'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.comentarios.length,
                      itemBuilder: (context, index) {
                        return ComentarioItem(
                          comentario: state.comentarios[index],
                        );
                      },
                    ),
        ),

        // Add comentario
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _comentarioController,
                  decoration: const InputDecoration(
                    hintText: 'Escribe un comentario...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.send),
                onPressed: _handleAddComentario,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArchivosTab(state) {
    return state.isLoadingArchivos && state.archivos.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : state.archivos.isEmpty
            ? const Center(child: Text('No hay archivos adjuntos'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.archivos.length,
                itemBuilder: (context, index) {
                  final archivo = state.archivos[index];
                  return ArchivoItem(
                    archivo: archivo,
                    onTap: () {
                      // Open archivo
                    },
                    onDelete: () async {
                      final confirmed = await _showDeleteDialog(context);
                      if (confirmed == true) {
                        final success = await ref
                            .read(reclamoDetailProvider(widget.reclamoId).notifier)
                            .deleteArchivo(archivo.id);

                        if (mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Archivo eliminado')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Error al eliminar archivo'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        }
                      }
                    },
                  );
                },
              );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Eliminar reclamo'),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await _showDeleteDialog(context);
              if (confirmed == true && mounted) {
                // Delete reclamo logic
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este elemento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
