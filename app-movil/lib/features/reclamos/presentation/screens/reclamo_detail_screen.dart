import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/config/app_config.dart';
import '../providers/reclamo_detail_provider.dart';
import '../widgets/estado_chip.dart';
import '../widgets/prioridad_indicator.dart';
import '../widgets/comentario_item.dart';
import '../widgets/archivo_item.dart';
import '../widgets/change_estado_dialog.dart';
import '../../data/models/archivo_model.dart';

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

  Future<void> _viewArchivo(Archivo archivo) async {
    final url = '${AppConfig.baseUrl}/archivos/${archivo.id}';

    // Si es imagen, mostrar en dialog
    if (archivo.tipoArchivo.startsWith('image/')) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(archivo.nombreArchivo),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: url,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Para otros archivos, abrir en navegador
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se puede abrir el archivo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _uploadArchivo() async {
    // Mostrar opciones
    final source = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subir archivo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Desde galería'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Archivo'),
              onTap: () => Navigator.pop(context, 'file'),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    File? file;
    String? fileName;

    if (source == 'camera') {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;
      file = File(photo.path);
      fileName = photo.name;
    } else if (source == 'gallery') {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.gallery);
      if (photo == null) return;
      file = File(photo.path);
      fileName = photo.name;
    } else {
      final result = await FilePicker.platform.pickFiles();
      if (result == null) return;
      file = File(result.files.single.path!);
      fileName = result.files.single.name;
    }

    if (!mounted) return;

    // Mostrar progress
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await ref
        .read(reclamoDetailProvider(widget.reclamoId).notifier)
        .uploadArchivo(file.path, fileName);

    if (mounted) {
      Navigator.pop(context); // Cerrar progress

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Archivo subido correctamente'
              : 'Error al subir archivo'),
          backgroundColor: success ? Colors.green : Colors.red,
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
              icon: const Icon(Icons.published_with_changes),
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => ChangeEstadoDialog(
                    reclamoId: widget.reclamoId,
                    currentEstado: state.reclamo!.estado,
                  ),
                );

                if (result == true) {
                  // Refrescar detalle
                  ref.invalidate(reclamoDetailProvider(widget.reclamoId));
                }
              },
            ),
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
      floatingActionButton: state.reclamo != null && !state.reclamo!.isClosed
          ? FloatingActionButton(
              onPressed: _uploadArchivo,
              child: const Icon(Icons.upload_file),
            )
          : null,
    );
  }

  Widget _buildErrorView(String error) {
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
              'Error al cargar reclamo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _handleRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
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
                    onTap: () => _viewArchivo(archivo),
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
