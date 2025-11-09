import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_animations.dart';
import '../../../../core/design/app_shadows.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/widgets/index.dart';
import '../providers/reclamo_detail_provider.dart';
import '../widgets/estado_chip.dart';
import '../widgets/prioridad_indicator.dart';
import '../widgets/comentario_item.dart';
import '../widgets/archivo_item.dart';
import '../widgets/change_estado_dialog_premium.dart';
import '../widgets/assign_tecnico_dialog.dart';
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
    if (archivo.tipo.startsWith('image/')) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(archivo.nombre),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.createGradient(AppColors.primaryGradient),
            boxShadow: AppShadows.card,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detalle del Reclamo',
          style: AppTextStyles.titleLarge(color: Colors.white)
              .copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (state.reclamo != null && !state.reclamo!.isClosed)
            Container(
              margin: EdgeInsets.only(right: AppSpacing.xs),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: IconButton(
                icon: const Icon(Icons.published_with_changes, color: Colors.white),
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => ChangeEstadoDialogPremium(
                      reclamoId: widget.reclamoId,
                      currentEstado: state.reclamo!.estado,
                    ),
                  );

                  if (result == true) {
                    ref.invalidate(reclamoDetailProvider(widget.reclamoId));
                  }
                },
              ),
            ).animate().fadeIn(delay: 100.ms),
          if (state.reclamo != null && !state.reclamo!.isClosed)
            Container(
              margin: EdgeInsets.only(right: AppSpacing.xs),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: IconButton(
                icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
                tooltip: 'Asignar técnico',
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => AssignTecnicoDialog(
                      reclamoId: widget.reclamoId,
                      currentTecnicoId: state.reclamo!.tecnicoAsignadoId,
                    ),
                  );

                  if (result == true) {
                    ref.invalidate(reclamoDetailProvider(widget.reclamoId));
                  }
                },
              ),
            ).animate().fadeIn(delay: 125.ms),
          if (state.reclamo != null && !state.reclamo!.isClosed)
            Container(
              margin: EdgeInsets.only(right: AppSpacing.xs),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => context.push('/reclamos/${widget.reclamoId}/edit'),
              ),
            ).animate().fadeIn(delay: 150.ms),
          Container(
            margin: EdgeInsets.only(right: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () => _showOptionsMenu(context),
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
      body: state.isLoading && state.reclamo == null
          ? Center(
              child: ModernLoading(
                message: 'Cargando detalle...',
                color: AppColors.primary,
              ),
            )
          : state.error != null && state.reclamo == null
              ? ModernEmptyState.error(
                  title: 'Error al cargar',
                  description: state.error!,
                  actionLabel: 'Reintentar',
                  onAction: _handleRefresh,
                )
              : _buildContent(state),
      floatingActionButton: state.reclamo != null && !state.reclamo!.isClosed
          ? FloatingActionButton.extended(
              onPressed: _uploadArchivo,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: Text(
                'Adjuntar',
                style: AppTextStyles.labelLarge(color: Colors.white),
              ),
            ).animate().fadeIn(delay: 300.ms).scale()
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          // Spacer for AppBar
          SliverToBoxAdapter(
            child: SizedBox(height: kToolbarHeight + AppSpacing.xxl),
          ),

          // Reclamo Header Card
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: ModernCard.elevated(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Numero + Estado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (reclamo.numero != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.createGradient(
                                AppColors.primaryGradient,
                              ),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: Text(
                              '#${reclamo.numero}',
                              style: AppTextStyles.titleMedium(color: Colors.white)
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ).animate().fadeIn().scale(),
                        EstadoChip(estado: reclamo.estado)
                            .animate(delay: 100.ms).fadeIn().slideX(),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Title
                    Text(
                      reclamo.titulo,
                      style: AppTextStyles.headlineSmall(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ).animate(delay: 150.ms).fadeIn(),
                    SizedBox(height: AppSpacing.md),

                    // Metadata Chips
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _buildMetadataChip(
                          Icons.category_outlined,
                          reclamo.categoriaDisplayName,
                          AppColors.info,
                          isDark,
                        ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.1),
                        PrioridadIndicator(prioridad: reclamo.prioridad)
                            .animate(delay: 250.ms).fadeIn().slideX(begin: -0.1),
                        _buildMetadataChip(
                          Icons.calendar_today,
                          DateFormatter.formatDate(reclamo.createdAt),
                          AppColors.secondary,
                          isDark,
                        ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.1),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Description Section
                    Divider(
                      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: AppColors.primary,
                          size: AppSpacing.iconSm,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Descripción',
                          style: AppTextStyles.titleMedium(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      reclamo.descripcion,
                      style: AppTextStyles.bodyMedium(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ).animate(delay: 350.ms).fadeIn(),

                    // Técnico Asignado Section
                    if (reclamo.tecnicoAsignado != null || reclamo.tecnicoAsignadoId != null) ...[
                      SizedBox(height: AppSpacing.md),
                      Divider(
                        color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                      ),
                      SizedBox(height: AppSpacing.md),
                      _buildTecnicoAsignado(reclamo, isDark),
                    ],
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.2),
            ),
          ),

          // Tabs
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                labelStyle: AppTextStyles.labelLarge(color: AppColors.primary)
                    .copyWith(fontWeight: FontWeight.w600),
                indicator: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.comment_outlined),
                    text: 'Comentarios',
                  ),
                  Tab(
                    icon: Icon(Icons.attach_file),
                    text: 'Archivos',
                  ),
                ],
              ),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
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

  Widget _buildMetadataChip(
    IconData icon,
    String label,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTextStyles.bodySmall(color: color)
                .copyWith(fontWeight: FontWeight.w600),
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

  Widget _buildTecnicoAsignado(ReclamoModel reclamo, bool isDark) {
    final tecnico = reclamo.tecnicoAsignado;
    final tecnicoNombre = tecnico != null
        ? '${tecnico['nombre'] ?? ''} ${tecnico['apellido'] ?? ''}'.trim()
        : 'Sin asignar';
    final tecnicoEmail = tecnico?['email'] as String?;
    final tecnicoTelefono = tecnico?['telefono'] as String?;
    final tecnicoEspecialidad = tecnico?['especialidad'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.engineering_outlined,
              color: AppColors.primary,
              size: AppSpacing.iconSm,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              'Técnico Asignado',
              style: AppTextStyles.titleMedium(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),

        // Técnico Card
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.createGradient(AppColors.primaryGradient),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    tecnico != null && tecnicoNombre.isNotEmpty
                        ? tecnicoNombre.substring(0, 1).toUpperCase()
                        : '?',
                    style: AppTextStyles.headlineSmall(color: Colors.white)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),

              // Técnico Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tecnicoNombre,
                      style: AppTextStyles.titleMedium(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (tecnicoEspecialidad != null) ...[
                      SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: AppSpacing.xxs),
                          Text(
                            tecnicoEspecialidad,
                            style: AppTextStyles.bodySmall(
                              color: AppColors.primary,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                    if (tecnicoEmail != null) ...[
                      SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          SizedBox(width: AppSpacing.xxs),
                          Expanded(
                            child: Text(
                              tecnicoEmail,
                              style: AppTextStyles.bodySmall(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (tecnicoTelefono != null) ...[
                      SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          SizedBox(width: AppSpacing.xxs),
                          Text(
                            tecnicoTelefono,
                            style: AppTextStyles.bodySmall(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.1),
      ],
    );
  }

  Widget _buildComentariosTab(state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Comentarios list
        Expanded(
          child: state.isLoadingComentarios && state.comentarios.isEmpty
              ? Center(
                  child: ModernLoading(
                    message: 'Cargando comentarios...',
                  ),
                )
              : state.comentarios.isEmpty
                  ? ModernEmptyState(
                      icon: Icons.comment_outlined,
                      title: 'Sin comentarios',
                      description: 'Se el primero en comentar en este reclamo',
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(AppSpacing.md),
                      itemCount: state.comentarios.length,
                      itemBuilder: (context, index) {
                        return ComentarioItem(
                          comentario: state.comentarios[index],
                        ).animate(delay: (index * 50).ms).fadeIn().slideX();
                      },
                    ),
        ),

        // Add comentario input
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            boxShadow: AppShadows.elevation4,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ModernTextField(
                    controller: _comentarioController,
                    hint: 'Escribe un comentario...',
                    maxLines: 3,
                    minLines: 1,
                    prefixIcon: Icons.comment_outlined,
                    fillColor: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.createGradient(AppColors.primaryGradient),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _handleAddComentario,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArchivosTab(state) {
    return state.isLoadingArchivos && state.archivos.isEmpty
        ? Center(
            child: ModernLoading(
              message: 'Cargando archivos...',
            ),
          )
        : state.archivos.isEmpty
            ? ModernEmptyState(
                icon: Icons.attach_file,
                title: 'Sin archivos adjuntos',
                description: 'Usa el botón inferior para adjuntar archivos',
              )
            : GridView.builder(
                padding: EdgeInsets.all(AppSpacing.md),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.2,
                ),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Archivo eliminado'
                                    : 'Error al eliminar archivo',
                              ),
                              backgroundColor: success
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                  ).animate(delay: (index * 50).ms).fadeIn().scale();
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
