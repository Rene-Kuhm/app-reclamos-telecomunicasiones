import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_shadows.dart';
import '../../../reclamos/data/models/reclamo_model.dart';
import '../screens/kanban_board_screen.dart';
import 'kanban_card.dart';

class KanbanColumn extends StatefulWidget {
  final KanbanColumnData data;
  final List<ReclamoModel> items;
  final Function(ReclamoModel) onItemTap;
  final Function(ReclamoModel) onItemLongPress;
  final Function(ReclamoModel) onDragStart;
  final VoidCallback onDragEnd;
  final Function(ReclamoModel, String) onAcceptDrop;
  final bool isHighlighted;

  const KanbanColumn({
    super.key,
    required this.data,
    required this.items,
    required this.onItemTap,
    required this.onItemLongPress,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onAcceptDrop,
    this.isHighlighted = false,
  });

  @override
  State<KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends State<KanbanColumn> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverLimit = widget.data.limit != null &&
        widget.items.length >= widget.data.limit!;

    return DragTarget<ReclamoModel>(
      onWillAccept: (data) {
        setState(() => _isDragOver = true);
        return data != null;
      },
      onLeave: (data) {
        setState(() => _isDragOver = false);
      },
      onAccept: (reclamo) {
        setState(() => _isDragOver = false);
        widget.onAcceptDrop(reclamo, widget.data.id);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: _isDragOver || widget.isHighlighted
                  ? widget.data.color
                  : isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
              width: _isDragOver ? 3 : 1,
            ),
            boxShadow: _isDragOver
                ? [
                    BoxShadow(
                      color: widget.data.color.withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                  ]
                : AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column Header
              _buildColumnHeader(isDark, isOverLimit),

              // Items List
              Expanded(
                child: widget.items.isEmpty
                    ? _buildEmptyColumn(isDark)
                    : ListView.separated(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        itemCount: widget.items.length,
                        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final reclamo = widget.items[index];
                          return Draggable<ReclamoModel>(
                            data: reclamo,
                            feedback: Material(
                              elevation: 8,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                              child: Container(
                                width: 320,
                                child: KanbanCard(
                                  reclamo: reclamo,
                                  isDragging: true,
                                  onTap: () {},
                                  onLongPress: () {},
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: KanbanCard(
                                reclamo: reclamo,
                                onTap: () {},
                                onLongPress: () {},
                              ),
                            ),
                            onDragStarted: () => widget.onDragStart(reclamo),
                            onDragEnd: (_) => widget.onDragEnd(),
                            child: KanbanCard(
                              reclamo: reclamo,
                              onTap: () => widget.onItemTap(reclamo),
                              onLongPress: () => widget.onItemLongPress(reclamo),
                            ).animate().fadeIn(
                              delay: (50 * index).ms,
                            ).slideY(begin: 0.1, end: 0),
                          );
                        },
                      ),
              ),

              // Add Button
              if (!isOverLimit) _buildAddButton(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColumnHeader(bool isDark, bool isOverLimit) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: widget.data.color.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusLg),
          topRight: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: widget.data.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  widget.data.icon,
                  color: widget.data.color,
                  size: AppSpacing.iconSm,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.data.title,
                  style: AppTextStyles.titleMedium(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: isOverLimit
                      ? AppColors.error.withOpacity(0.1)
                      : widget.data.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  widget.items.length.toString(),
                  style: AppTextStyles.titleSmall(
                    color: isOverLimit ? AppColors.error : widget.data.color,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // WIP Limit Warning
          if (widget.data.limit != null) ...[
            SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: widget.items.length / widget.data.limit!,
                    backgroundColor: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOverLimit ? AppColors.error : widget.data.color,
                    ),
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '${widget.items.length}/${widget.data.limit}',
                  style: AppTextStyles.caption(
                    color: isOverLimit
                        ? AppColors.error
                        : isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyColumn(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 48,
              color: isDark
                  ? AppColors.textSecondaryDark.withOpacity(0.5)
                  : AppColors.textSecondaryLight.withOpacity(0.5),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Sin reclamos',
              style: AppTextStyles.bodyMedium(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Arrastra aquí',
              style: AppTextStyles.caption(
                color: isDark
                    ? AppColors.textSecondaryDark.withOpacity(0.7)
                    : AppColors.textSecondaryLight.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildAddButton(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle add new item to this column
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Crear reclamo en ${widget.data.title}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: AppSpacing.iconSm,
                  color: widget.data.color,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Agregar',
                  style: AppTextStyles.bodyMedium(
                    color: widget.data.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
