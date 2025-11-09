import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../providers/reclamo_detail_provider.dart';

/// Estados mejorados para reclamos
enum EstadoReclamoPremium {
  pendiente,
  enProgreso,
  resuelto,
  cerrado;

  String get value {
    switch (this) {
      case EstadoReclamoPremium.pendiente:
        return 'ABIERTO'; // Mapea al backend existente
      case EstadoReclamoPremium.enProgreso:
        return 'EN_CURSO';
      case EstadoReclamoPremium.resuelto:
        return 'EN_REVISION';
      case EstadoReclamoPremium.cerrado:
        return 'CERRADO';
    }
  }

  String get displayName {
    switch (this) {
      case EstadoReclamoPremium.pendiente:
        return 'Pendiente';
      case EstadoReclamoPremium.enProgreso:
        return 'En Progreso';
      case EstadoReclamoPremium.resuelto:
        return 'Resuelto';
      case EstadoReclamoPremium.cerrado:
        return 'Cerrado';
    }
  }

  IconData get icon {
    switch (this) {
      case EstadoReclamoPremium.pendiente:
        return Icons.hourglass_empty_rounded;
      case EstadoReclamoPremium.enProgreso:
        return Icons.engineering_rounded;
      case EstadoReclamoPremium.resuelto:
        return Icons.check_circle_outline_rounded;
      case EstadoReclamoPremium.cerrado:
        return Icons.lock_outline_rounded;
    }
  }

  Color get color {
    switch (this) {
      case EstadoReclamoPremium.pendiente:
        return Colors.orange;
      case EstadoReclamoPremium.enProgreso:
        return Colors.blue;
      case EstadoReclamoPremium.resuelto:
        return Colors.green;
      case EstadoReclamoPremium.cerrado:
        return Colors.grey;
    }
  }

  String get description {
    switch (this) {
      case EstadoReclamoPremium.pendiente:
        return 'El reclamo está esperando atención';
      case EstadoReclamoPremium.enProgreso:
        return 'Se está trabajando en la solución';
      case EstadoReclamoPremium.resuelto:
        return 'El problema ha sido solucionado';
      case EstadoReclamoPremium.cerrado:
        return 'El reclamo está cerrado definitivamente';
    }
  }

  static EstadoReclamoPremium? fromBackendValue(String value) {
    switch (value.toUpperCase()) {
      case 'ABIERTO':
      case 'ASIGNADO':
        return EstadoReclamoPremium.pendiente;
      case 'EN_CURSO':
        return EstadoReclamoPremium.enProgreso;
      case 'EN_REVISION':
        return EstadoReclamoPremium.resuelto;
      case 'CERRADO':
        return EstadoReclamoPremium.cerrado;
      default:
        return EstadoReclamoPremium.pendiente;
    }
  }
}

/// Diálogo premium para cambiar el estado de un reclamo
class ChangeEstadoDialogPremium extends ConsumerStatefulWidget {
  final String reclamoId;
  final String currentEstado;

  const ChangeEstadoDialogPremium({
    super.key,
    required this.reclamoId,
    required this.currentEstado,
  });

  @override
  ConsumerState<ChangeEstadoDialogPremium> createState() =>
      _ChangeEstadoDialogPremiumState();
}

class _ChangeEstadoDialogPremiumState
    extends ConsumerState<ChangeEstadoDialogPremium> {
  EstadoReclamoPremium? _selectedEstado;
  final _solucionController = TextEditingController();
  final _comentarioController = TextEditingController();
  final List<XFile> _imagenes = [];
  final _imagePicker = ImagePicker();
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _solucionController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  List<EstadoReclamoPremium> _getAvailableEstados() {
    final currentEstado =
        EstadoReclamoPremium.fromBackendValue(widget.currentEstado);

    // Flujo de estados: Pendiente → En Progreso → Resuelto → Cerrado
    switch (currentEstado) {
      case EstadoReclamoPremium.pendiente:
        return [
          EstadoReclamoPremium.enProgreso,
          EstadoReclamoPremium.cerrado, // Puede cerrar directamente si es spam
        ];
      case EstadoReclamoPremium.enProgreso:
        return [
          EstadoReclamoPremium.resuelto,
          EstadoReclamoPremium.pendiente, // Volver si falta información
        ];
      case EstadoReclamoPremium.resuelto:
        return [
          EstadoReclamoPremium.cerrado,
          EstadoReclamoPremium.enProgreso, // Reapertura si el cliente no confirma
        ];
      case EstadoReclamoPremium.cerrado:
        return []; // No se puede cambiar desde cerrado
      default:
        return [];
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagenes.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagenes.removeAt(index);
    });
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Selección de estado
        return _selectedEstado != null;
      case 1: // Detalles
        // Si es Resuelto, requiere descripción de solución
        if (_selectedEstado == EstadoReclamoPremium.resuelto) {
          return _solucionController.text.trim().isNotEmpty;
        }
        return true;
      case 2: // Confirmación
        return true;
      default:
        return false;
    }
  }

  Future<void> _cambiarEstado() async {
    if (_selectedEstado == null) return;

    setState(() => _isLoading = true);

    // TODO: Implementar envío de imágenes y comentarios al backend
    final success = await ref
        .read(reclamoDetailProvider(widget.reclamoId).notifier)
        .cambiarEstado(_selectedEstado!.value);

    if (mounted) {
      Navigator.pop(context, success);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  success
                      ? 'Estado actualizado a ${_selectedEstado!.displayName}'
                      : 'Error al cambiar estado',
                ),
              ),
            ],
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableEstados = _getAvailableEstados();
    final currentEstadoEnum =
        EstadoReclamoPremium.fromBackendValue(widget.currentEstado);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (availableEstados.isEmpty) {
      return _buildNoChangesDialog(context, currentEstadoEnum, isDark);
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: GlassmorphicContainer(
          padding: EdgeInsets.all(AppSpacing.xl),
          blur: 20,
          opacity: 0.1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, currentEstadoEnum, isDark),
              SizedBox(height: AppSpacing.lg),
              _buildStepper(availableEstados, isDark),
              SizedBox(height: AppSpacing.lg),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoChangesDialog(
    BuildContext context,
    EstadoReclamoPremium? currentEstado,
    bool isDark,
  ) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      title: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Estado Cerrado',
            style: AppTextStyles.titleLarge(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Este reclamo está cerrado y no puede cambiar de estado.',
            style: AppTextStyles.bodyLarge(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: currentEstado?.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: currentEstado?.color.withOpacity(0.3) ?? Colors.grey,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  currentEstado?.icon ?? Icons.lock,
                  color: currentEstado?.color,
                  size: 32,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentEstado?.displayName ?? 'Cerrado',
                        style: AppTextStyles.titleMedium(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        currentEstado?.description ??
                            'El reclamo está cerrado',
                        style: AppTextStyles.bodySmall(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ModernButton.outlined(
          label: 'Entendido',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    EstadoReclamoPremium? currentEstado,
    bool isDark,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                Icons.swap_horizontal_circle_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cambiar Estado',
                    style: AppTextStyles.headlineSmall(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Actualiza el estado del reclamo',
                    style: AppTextStyles.bodyMedium(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: currentEstado?.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: currentEstado?.color.withOpacity(0.3) ?? Colors.grey,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                currentEstado?.icon ?? Icons.help_outline,
                color: currentEstado?.color,
                size: 16,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Estado actual: ${currentEstado?.displayName ?? widget.currentEstado}',
                style: AppTextStyles.bodySmall(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepper(
    List<EstadoReclamoPremium> availableEstados,
    bool isDark,
  ) {
    return Expanded(
      child: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_validateCurrentStep()) {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _cambiarEstado();
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        controlsBuilder: (context, details) => const SizedBox.shrink(),
        steps: [
          Step(
            title: Text('Seleccionar Estado'),
            content: _buildEstadoSelector(availableEstados, isDark),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text('Detalles'),
            content: _buildDetallesForm(isDark),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text('Confirmar'),
            content: _buildConfirmacion(isDark),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoSelector(
    List<EstadoReclamoPremium> availableEstados,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona el nuevo estado del reclamo:',
          style: AppTextStyles.bodyMedium(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        ...availableEstados.map((estado) => _buildEstadoCard(estado, isDark)),
      ],
    );
  }

  Widget _buildEstadoCard(EstadoReclamoPremium estado, bool isDark) {
    final isSelected = _selectedEstado == estado;

    return GestureDetector(
      onTap: _isLoading ? null : () => setState(() => _selectedEstado = estado),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? estado.color.withOpacity(0.15)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                  .withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected
                ? estado.color
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: estado.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(
                estado.icon,
                color: estado.color,
                size: 24,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    estado.displayName,
                    style: AppTextStyles.titleMedium(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    estado.description,
                    style: AppTextStyles.bodySmall(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: estado.color,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetallesForm(bool isDark) {
    final requiresSolution = _selectedEstado == EstadoReclamoPremium.resuelto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (requiresSolution) ...[
          Text(
            'Descripción de la Solución *',
            style: AppTextStyles.titleSmall(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Describe detalladamente cómo se resolvió el problema',
            style: AppTextStyles.bodySmall(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _solucionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Ej: Se reemplazó el cable de fibra óptica dañado y se reinició el router...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              filled: true,
              fillColor: isDark
                  ? AppColors.surfaceDark.withOpacity(0.5)
                  : AppColors.surfaceLight.withOpacity(0.5),
            ),
            enabled: !_isLoading,
          ),
          SizedBox(height: AppSpacing.md),
        ],
        Text(
          'Comentario Adicional (opcional)',
          style: AppTextStyles.titleSmall(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _comentarioController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Agrega cualquier información adicional...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.surfaceDark.withOpacity(0.5)
                : AppColors.surfaceLight.withOpacity(0.5),
          ),
          enabled: !_isLoading,
        ),
        SizedBox(height: AppSpacing.md),
        _buildImageSection(isDark),
      ],
    );
  }

  Widget _buildImageSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.image_outlined, size: 20, color: AppColors.primary),
            SizedBox(width: AppSpacing.xs),
            Text(
              'Evidencia Fotográfica (opcional)',
              style: AppTextStyles.titleSmall(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          'Adjunta imágenes del problema o la solución aplicada',
          style: AppTextStyles.bodySmall(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        if (_imagenes.isNotEmpty)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _imagenes.asMap().entries.map((entry) {
              return _buildImagePreview(entry.key, entry.value, isDark);
            }).toList(),
          ),
        SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _pickImage,
          icon: const Icon(Icons.add_photo_alternate),
          label: Text(_imagenes.isEmpty ? 'Agregar Imagen' : 'Agregar Más'),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(int index, XFile image, bool isDark) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Image.network(
            image.path,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 100,
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                child: Icon(Icons.error, color: AppColors.error),
              );
            },
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmacion(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: _selectedEstado?.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: _selectedEstado?.color.withOpacity(0.3) ?? Colors.grey,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _selectedEstado?.icon ?? Icons.help_outline,
                    color: _selectedEstado?.color,
                    size: 28,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Nuevo Estado: ${_selectedEstado?.displayName ?? 'N/A'}',
                    style: AppTextStyles.titleMedium(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (_solucionController.text.isNotEmpty) ...[
                SizedBox(height: AppSpacing.md),
                Divider(),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Solución:',
                  style: AppTextStyles.labelLarge(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  _solucionController.text,
                  style: AppTextStyles.bodyMedium(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
              if (_comentarioController.text.isNotEmpty) ...[
                SizedBox(height: AppSpacing.md),
                Divider(),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Comentario:',
                  style: AppTextStyles.labelLarge(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  _comentarioController.text,
                  style: AppTextStyles.bodyMedium(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
              if (_imagenes.isNotEmpty) ...[
                SizedBox(height: AppSpacing.md),
                Divider(),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Imágenes adjuntas: ${_imagenes.length}',
                  style: AppTextStyles.labelLarge(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: AppColors.info),
            SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Esta acción se registrará en el historial del reclamo',
                style: AppTextStyles.bodySmall(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          ModernButton.outlined(
            label: 'Atrás',
            icon: Icons.arrow_back,
            onPressed: _isLoading ? null : () => setState(() => _currentStep--),
          )
        else
          const SizedBox.shrink(),
        Row(
          children: [
            ModernButton.outlined(
              label: 'Cancelar',
              onPressed: _isLoading ? null : () => Navigator.pop(context),
            ),
            SizedBox(width: AppSpacing.sm),
            ModernButton.primary(
              label: _currentStep < 2 ? 'Siguiente' : 'Confirmar',
              icon: _currentStep < 2
                  ? Icons.arrow_forward
                  : Icons.check_circle_outline,
              onPressed: _isLoading || !_validateCurrentStep()
                  ? null
                  : () {
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        _cambiarEstado();
                      }
                    },
              isLoading: _isLoading,
            ),
          ],
        ),
      ],
    );
  }
}
