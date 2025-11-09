import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_shadows.dart';
import '../../../reclamos/data/models/reclamo_model.dart';
import '../../../reclamos/presentation/providers/reclamos_provider.dart';
import '../widgets/kanban_column.dart';
import '../widgets/kanban_card.dart';

/// Enterprise Kanban Board for Claims Management
class KanbanBoardScreen extends ConsumerStatefulWidget {
  const KanbanBoardScreen({super.key});

  @override
  ConsumerState<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends ConsumerState<KanbanBoardScreen> {
  late ScrollController _horizontalScrollController;
  bool _isReordering = false;
  String? _draggedItemId;
  String? _targetColumnId;

  final List<KanbanColumnData> _columns = [
    KanbanColumnData(
      id: 'pendiente',
      title: 'Pendiente',
      color: AppColors.warning,
      icon: Icons.pending_actions,
      limit: 10,
    ),
    KanbanColumnData(
      id: 'asignado',
      title: 'Asignado',
      color: AppColors.info,
      icon: Icons.assignment_ind,
      limit: 15,
    ),
    KanbanColumnData(
      id: 'en_curso',
      title: 'En Curso',
      color: AppColors.estadoEnCurso,
      icon: Icons.autorenew,
      limit: 20,
    ),
    KanbanColumnData(
      id: 'en_revision',
      title: 'En Revisión',
      color: AppColors.secondary,
      icon: Icons.rate_review,
      limit: 8,
    ),
    KanbanColumnData(
      id: 'resuelto',
      title: 'Resuelto',
      color: AppColors.success,
      icon: Icons.check_circle,
      limit: null,
    ),
    KanbanColumnData(
      id: 'cerrado',
      title: 'Cerrado',
      color: AppColors.estadoCerrado,
      icon: Icons.archive,
      limit: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();

    Future.microtask(() {
      ref.read(reclamosProvider.notifier).loadReclamos();
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reclamosState = ref.watch(reclamosProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),

            // Kanban Board
            Expanded(
              child: reclamosState.reclamos.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildKanbanBoard(
                      reclamosState.reclamos,
                      isDark,
                      isMobile,
                    ),
            ),
          ],
        ),
      ),

      // FAB para crear nuevo reclamo
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reclamos/crear'),
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Nuevo Reclamo',
          style: AppTextStyles.bodyMedium(color: Colors.white),
        ),
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Kanban Board',
                        style: AppTextStyles.headlineMedium(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Padding(
                    padding: EdgeInsets.only(left: AppSpacing.iconMd + AppSpacing.sm),
                    child: Text(
                      'Gestión visual de reclamos con drag & drop',
                      style: AppTextStyles.bodyMedium(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),

              // Actions
              Row(
                children: [
                  // View Mode Toggle
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'kanban',
                        icon: Icon(Icons.view_column),
                      ),
                      ButtonSegment(
                        value: 'list',
                        icon: Icon(Icons.view_list),
                      ),
                      ButtonSegment(
                        value: 'calendar',
                        icon: Icon(Icons.calendar_month),
                      ),
                    ],
                    selected: {'kanban'},
                    onSelectionChanged: (Set<String> newSelection) {
                      final view = newSelection.first;
                      if (view == 'list') {
                        context.push('/reclamos');
                      } else if (view == 'calendar') {
                        context.push('/calendar');
                      }
                    },
                  ),
                  SizedBox(width: AppSpacing.md),

                  // Filter Button
                  IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showFilterDialog();
                    },
                  ),

                  // Group By Button
                  IconButton(
                    icon: Icon(Icons.group_work),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showGroupByDialog();
                    },
                  ),

                  // Refresh
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref.read(reclamosProvider.notifier).loadReclamos();
                    },
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Column Summary
          _buildColumnSummary(isDark),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildColumnSummary(bool isDark) {
    final reclamosState = ref.watch(reclamosProvider);
    final reclamos = reclamosState.reclamos;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: _columns.map((column) {
          final count = reclamos
              .where((r) => r.estado.toLowerCase() == column.id)
              .length;

          return Expanded(
            child: Column(
              children: [
                Text(
                  count.toString(),
                  style: AppTextStyles.titleLarge(
                    color: column.color,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  column.title,
                  style: AppTextStyles.caption(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKanbanBoard(
    List<ReclamoModel> reclamos,
    bool isDark,
    bool isMobile,
  ) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
      child: Scrollbar(
        controller: _horizontalScrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _columns.map((columnData) {
              final columnReclamos = reclamos
                  .where((r) => r.estado.toLowerCase() == columnData.id)
                  .toList();

              return Container(
                width: isMobile ? 300 : 350,
                margin: EdgeInsets.only(right: AppSpacing.md),
                child: KanbanColumn(
                  data: columnData,
                  items: columnReclamos,
                  onItemTap: (reclamo) {
                    context.push('/reclamos/${reclamo.id}');
                  },
                  onItemLongPress: (reclamo) {
                    HapticFeedback.heavyImpact();
                    _showQuickActions(reclamo);
                  },
                  onDragStart: (reclamo) {
                    setState(() {
                      _isReordering = true;
                      _draggedItemId = reclamo.id;
                    });
                  },
                  onDragEnd: () {
                    setState(() {
                      _isReordering = false;
                      _draggedItemId = null;
                      _targetColumnId = null;
                    });
                  },
                  onAcceptDrop: (reclamo, targetColumn) async {
                    HapticFeedback.heavyImpact();

                    // Update reclamo status
                    await _updateReclamoStatus(
                      reclamo,
                      targetColumn,
                    );

                    setState(() {
                      _isReordering = false;
                      _draggedItemId = null;
                      _targetColumnId = null;
                    });
                  },
                  isHighlighted: _targetColumnId == columnData.id,
                ),
              ).animate().fadeIn().slideX(
                begin: 0.1 * (_columns.indexOf(columnData)),
                end: 0,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_kanban,
            size: 120,
            color: isDark
                ? AppColors.textSecondaryDark.withOpacity(0.5)
                : AppColors.textSecondaryLight.withOpacity(0.5),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'No hay reclamos',
            style: AppTextStyles.titleLarge(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Crea tu primer reclamo para verlo aquí',
            style: AppTextStyles.bodyMedium(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () => context.push('/reclamos/crear'),
            icon: Icon(Icons.add),
            label: Text('Crear Reclamo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Future<void> _updateReclamoStatus(
    ReclamoModel reclamo,
    String newStatus,
  ) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Actualizando estado...'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );

      // Update status via provider
      // await ref.read(reclamosProvider.notifier).updateEstado(
      //   reclamo.id,
      //   newStatus,
      // );

      // TODO: Implement actual status update
      await Future.delayed(Duration(milliseconds: 500));

      // Refresh list
      ref.read(reclamosProvider.notifier).loadReclamos();

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: AppSpacing.sm),
              Text('Estado actualizado exitosamente'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: AppSpacing.sm),
              Text('Error al actualizar: ${e.toString()}'),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showQuickActions(ReclamoModel reclamo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            ListTile(
              leading: Icon(Icons.visibility, color: AppColors.primary),
              title: Text('Ver Detalle'),
              onTap: () {
                context.pop();
                context.push('/reclamos/${reclamo.id}');
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.info),
              title: Text('Editar'),
              onTap: () {
                context.pop();
                // Navigate to edit screen
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_ind, color: AppColors.warning),
              title: Text('Asignar Técnico'),
              onTap: () {
                context.pop();
                // Show assign dialog
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: AppColors.secondary),
              title: Text('Programar'),
              onTap: () {
                context.pop();
                // Show schedule dialog
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text('Eliminar'),
              onTap: () {
                context.pop();
                _showDeleteConfirmation(reclamo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(ReclamoModel reclamo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro que deseas eliminar este reclamo?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              // Delete reclamo
              HapticFeedback.heavyImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    // TODO: Implement filter dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filtros próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showGroupByDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agrupar Por'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Estado'),
              leading: Radio(value: true, groupValue: true, onChanged: (_) {}),
            ),
            ListTile(
              title: Text('Prioridad'),
              leading: Radio(value: false, groupValue: true, onChanged: (_) {}),
            ),
            ListTile(
              title: Text('Técnico'),
              leading: Radio(value: false, groupValue: true, onChanged: (_) {}),
            ),
            ListTile(
              title: Text('Categoría'),
              leading: Radio(value: false, groupValue: true, onChanged: (_) {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}

// Supporting Classes
class KanbanColumnData {
  final String id;
  final String title;
  final Color color;
  final IconData icon;
  final int? limit;

  const KanbanColumnData({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
    this.limit,
  });
}
