import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_shadows.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/index.dart';
import '../providers/reclamos_provider.dart';

/// Professional create reclamo screen with enterprise design
class CreateReclamoScreen extends ConsumerStatefulWidget {
  const CreateReclamoScreen({super.key});

  @override
  ConsumerState<CreateReclamoScreen> createState() => _CreateReclamoScreenState();
}

class _CreateReclamoScreenState extends ConsumerState<CreateReclamoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _nombreClienteController = TextEditingController();
  final _telefonoClienteController = TextEditingController();
  final _direccionController = TextEditingController();

  String _selectedCategoria = 'INTERNET_FIBRA';
  String _selectedPrioridad = 'MEDIA';
  String? _selectedSubcategoria;

  bool _isSubmitting = false;
  bool _hasUnsavedChanges = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _nombreClienteController.dispose();
    _telefonoClienteController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar cambios'),
        content: const Text(
            '¿Estás seguro de que deseas descartar los cambios realizados?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ModernButton(
            onPressed: () => Navigator.pop(context, true),
            label: 'Descartar',
            color: AppColors.error,
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final Map<String, dynamic>? infoContacto =
        _nombreClienteController.text.trim().isNotEmpty ||
                _telefonoClienteController.text.trim().isNotEmpty
            ? {
                if (_nombreClienteController.text.trim().isNotEmpty)
                  'nombreCliente': _nombreClienteController.text.trim(),
                if (_telefonoClienteController.text.trim().isNotEmpty)
                  'telefonoCliente': _telefonoClienteController.text.trim(),
              }
            : null;

    final success = await ref.read(reclamosProvider.notifier).createReclamo(
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          categoria: _selectedCategoria,
          subcategoria: _selectedSubcategoria,
          prioridad: _selectedPrioridad,
          direccion: _direccionController.text.trim().isNotEmpty
              ? _direccionController.text.trim()
              : null,
          infoContacto: infoContacto,
        );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      if (success) _hasUnsavedChanges = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reclamo creado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      final error = ref.read(reclamosProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al crear reclamo'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
            onPressed: () async {
              if (await _onWillPop()) {
                if (mounted) context.pop();
              }
            },
          ),
          title: Text(
            'Nuevo Reclamo',
            style: AppTextStyles.titleLarge(color: Colors.white)
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              // Título section
              Text(
                'Información General',
                style: AppTextStyles.titleMedium(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.w600),
              ).animate().fadeIn(),
              SizedBox(height: AppSpacing.sm),

              ModernCard.elevated(
                child: Column(
                  children: [
                    ModernTextField(
                      controller: _tituloController,
                      label: 'Título del Reclamo',
                      hint: 'Resumen breve del problema',
                      prefixIcon: Icons.title,
                      validator: (value) =>
                          Validators.validateRequired(value, 'El título'),
                      onChanged: (_) => _onFieldChanged(),
                      enabled: !_isSubmitting,
                    ),
                    SizedBox(height: AppSpacing.md),
                    ModernTextField(
                      controller: _descripcionController,
                      label: 'Descripción',
                      hint: 'Describe el problema en detalle',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 5,
                      minLines: 3,
                      validator: (value) =>
                          Validators.validateRequired(value, 'La descripción'),
                      onChanged: (_) => _onFieldChanged(),
                      enabled: !_isSubmitting,
                    ),
                  ],
                ),
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
              SizedBox(height: AppSpacing.lg),

              // Categorización section
              Text(
                'Categorización',
                style: AppTextStyles.titleMedium(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.w600),
              ).animate(delay: 150.ms).fadeIn(),
              SizedBox(height: AppSpacing.sm),

              ModernCard.elevated(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categoría
                    Text(
                      'Categoría',
                      style: AppTextStyles.labelLarge(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    _buildCategorySelector(isDark),
                    SizedBox(height: AppSpacing.md),

                    // Prioridad
                    Text(
                      'Prioridad',
                      style: AppTextStyles.labelLarge(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    _buildPrioritySelector(isDark),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
              SizedBox(height: AppSpacing.lg),

              // Información del Cliente section
              Text(
                'Información del Cliente',
                style: AppTextStyles.titleMedium(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.w600),
              ).animate(delay: 250.ms).fadeIn(),
              SizedBox(height: AppSpacing.sm),

              ModernCard.elevated(
                child: Column(
                  children: [
                    ModernTextField(
                      controller: _nombreClienteController,
                      label: 'Nombre del Cliente',
                      hint: 'Nombre completo del cliente',
                      prefixIcon: Icons.person_outline,
                      onChanged: (_) => _onFieldChanged(),
                      enabled: !_isSubmitting,
                    ),
                    SizedBox(height: AppSpacing.md),
                    ModernTextField(
                      controller: _telefonoClienteController,
                      label: 'Teléfono del Cliente',
                      hint: 'Ej: 0981234567',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => _onFieldChanged(),
                      enabled: !_isSubmitting,
                    ),
                    SizedBox(height: AppSpacing.md),
                    ModernTextField(
                      controller: _direccionController,
                      label: 'Dirección',
                      hint: 'Dirección donde se presenta el problema',
                      prefixIcon: Icons.location_on_outlined,
                      maxLines: 2,
                      minLines: 1,
                      onChanged: (_) => _onFieldChanged(),
                      enabled: !_isSubmitting,
                    ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
              SizedBox(height: AppSpacing.xxl),

              // Submit button
              ModernButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                label: _isSubmitting ? 'Creando...' : 'Crear Reclamo',
                size: ModernButtonSize.large,
                icon: _isSubmitting ? null : Icons.add_circle_outline,
                isLoading: _isSubmitting,
                isFullWidth: true,
              ).animate(delay: 350.ms).fadeIn().scale(),
              SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    final categories = [
      {'value': 'INTERNET_ADSL', 'label': 'Internet ADSL', 'icon': Icons.wifi},
      {'value': 'INTERNET_FIBRA', 'label': 'Internet Fibra', 'icon': Icons.router},
      {'value': 'TELEFONO_ADSL', 'label': 'Teléfono ADSL', 'icon': Icons.phone},
      {'value': 'TELEFONO_FIBRA', 'label': 'Teléfono Fibra', 'icon': Icons.phone_in_talk},
      {'value': 'TV_SENSA', 'label': 'TV Sensa', 'icon': Icons.tv},
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: categories.map((cat) {
        final isSelected = _selectedCategoria == cat['value'];
        return _buildChipButton(
          label: cat['label'] as String,
          icon: cat['icon'] as IconData,
          isSelected: isSelected,
          onTap: _isSubmitting
              ? null
              : () {
                  setState(() {
                    _selectedCategoria = cat['value'] as String;
                    _onFieldChanged();
                  });
                },
          color: AppColors.info,
          isDark: isDark,
        );
      }).toList(),
    );
  }

  Widget _buildPrioritySelector(bool isDark) {
    final priorities = [
      {'value': 'BAJA', 'label': 'Baja', 'color': AppColors.success},
      {'value': 'MEDIA', 'label': 'Media', 'color': AppColors.info},
      {'value': 'ALTA', 'label': 'Alta', 'color': AppColors.warning},
      {'value': 'URGENTE', 'label': 'Urgente', 'color': AppColors.error},
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: priorities.map((priority) {
        final isSelected = _selectedPrioridad == priority['value'];
        return _buildChipButton(
          label: priority['label'] as String,
          icon: Icons.flag,
          isSelected: isSelected,
          onTap: _isSubmitting
              ? null
              : () {
                  setState(() {
                    _selectedPrioridad = priority['value'] as String;
                    _onFieldChanged();
                  });
                },
          color: priority['color'] as Color,
          isDark: isDark,
        );
      }).toList(),
    );
  }

  Widget _buildChipButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onTap,
    required Color color,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? AppShadows.card : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : color,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.labelLarge(
                  color: isSelected ? Colors.white : color,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
