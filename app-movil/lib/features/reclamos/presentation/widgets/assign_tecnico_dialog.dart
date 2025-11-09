import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../providers/reclamo_detail_provider.dart';

/// Modelo simple de técnico
class TecnicoModel {
  final String id;
  final String nombre;
  final String email;
  final String? telefono;
  final String? especialidad;
  final bool disponible;

  const TecnicoModel({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    this.especialidad,
    this.disponible = true,
  });

  factory TecnicoModel.fromJson(Map<String, dynamic> json) {
    return TecnicoModel(
      id: json['id'] as String,
      nombre: '${json['nombre'] ?? ''} ${json['apellido'] ?? ''}'.trim(),
      email: json['email'] as String,
      telefono: json['telefono'] as String?,
      especialidad: json['especialidad'] as String?,
      disponible: json['activo'] as bool? ?? true,
    );
  }
}

/// Provider temporal para técnicos (mock data)
/// TODO: Reemplazar con llamada real al backend
final tecnicosProvider = FutureProvider<List<TecnicoModel>>((ref) async {
  // Simular delay de red
  await Future.delayed(const Duration(milliseconds: 500));

  // Mock data - en producción esto vendría del backend
  return [
    const TecnicoModel(
      id: '1f561116-5f2d-4908-8ac3-45818800a7fe',
      nombre: 'Carlos Ramírez',
      email: 'tecnico2@reclamos.com',
      telefono: '1234567893',
      especialidad: 'Fibra Óptica',
      disponible: true,
    ),
    const TecnicoModel(
      id: 'de248c43-41ff-409c-a07d-beff8e55df2a',
      nombre: 'Juan Pérez',
      email: 'tecnico1@reclamos.com',
      telefono: '1234567892',
      especialidad: 'ADSL y Telefonía',
      disponible: true,
    ),
    const TecnicoModel(
      id: '3a7c8e9f-1234-5678-9abc-def012345678',
      nombre: 'María González',
      email: 'tecnico3@reclamos.com',
      telefono: '1234567894',
      especialidad: 'TV y Cable',
      disponible: true,
    ),
    const TecnicoModel(
      id: '4b8d9f0a-2345-6789-0bcd-ef0123456789',
      nombre: 'Pedro Martínez',
      email: 'tecnico4@reclamos.com',
      telefono: '1234567895',
      especialidad: 'Redes Corporativas',
      disponible: false,
    ),
  ];
});

/// Diálogo para asignar técnico al reclamo
class AssignTecnicoDialog extends ConsumerStatefulWidget {
  final String reclamoId;
  final String? currentTecnicoId;
  final String? currentTecnicoNombre;

  const AssignTecnicoDialog({
    super.key,
    required this.reclamoId,
    this.currentTecnicoId,
    this.currentTecnicoNombre,
  });

  @override
  ConsumerState<AssignTecnicoDialog> createState() =>
      _AssignTecnicoDialogState();
}

class _AssignTecnicoDialogState extends ConsumerState<AssignTecnicoDialog> {
  TecnicoModel? _selectedTecnico;
  String _searchQuery = '';
  bool _isLoading = false;
  final _notasController = TextEditingController();

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _assignTecnico() async {
    if (_selectedTecnico == null) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implementar la llamada real al backend para asignar técnico
      // Por ahora solo simularemos el éxito
      await Future.delayed(const Duration(seconds: 1));

      // Aquí deberías llamar al provider para actualizar el reclamo
      // await ref.read(reclamoDetailProvider(widget.reclamoId).notifier)
      //     .assignTecnico(_selectedTecnico!.id, _notasController.text);

      if (mounted) {
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Técnico ${_selectedTecnico!.nombre} asignado correctamente',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al asignar técnico: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tecnicosAsync = ref.watch(tecnicosProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              _buildHeader(context, isDark),
              SizedBox(height: AppSpacing.lg),
              _buildSearchBar(isDark),
              SizedBox(height: AppSpacing.md),
              Expanded(
                child: tecnicosAsync.when(
                  data: (tecnicos) => _buildTecnicosList(tecnicos, isDark),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'Error al cargar técnicos',
                          style: AppTextStyles.titleMedium(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          error.toString(),
                          style: AppTextStyles.bodySmall(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_selectedTecnico != null) ...[
                SizedBox(height: AppSpacing.md),
                _buildNotasField(isDark),
              ],
              SizedBox(height: AppSpacing.lg),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(
            Icons.person_add_alt_1_rounded,
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
                'Asignar Técnico',
                style: AppTextStyles.headlineSmall(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              if (widget.currentTecnicoNombre != null)
                Text(
                  'Actual: ${widget.currentTecnicoNombre}',
                  style: AppTextStyles.bodySmall(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                )
              else
                Text(
                  'Sin asignar',
                  style: AppTextStyles.bodySmall(
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
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar técnico por nombre o especialidad...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        filled: true,
        fillColor: isDark
            ? AppColors.surfaceDark.withOpacity(0.5)
            : AppColors.surfaceLight.withOpacity(0.5),
      ),
      onChanged: (value) {
        setState(() => _searchQuery = value.toLowerCase());
      },
    );
  }

  Widget _buildTecnicosList(List<TecnicoModel> tecnicos, bool isDark) {
    final filteredTecnicos = tecnicos.where((tecnico) {
      if (_searchQuery.isEmpty) return true;
      return tecnico.nombre.toLowerCase().contains(_searchQuery) ||
          (tecnico.especialidad?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    if (filteredTecnicos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'No se encontraron técnicos',
              style: AppTextStyles.titleMedium(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: filteredTecnicos.length,
      separatorBuilder: (context, index) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final tecnico = filteredTecnicos[index];
        return _buildTecnicoCard(tecnico, isDark);
      },
    );
  }

  Widget _buildTecnicoCard(TecnicoModel tecnico, bool isDark) {
    final isSelected = _selectedTecnico?.id == tecnico.id;
    final isCurrent = widget.currentTecnicoId == tecnico.id;

    return GestureDetector(
      onTap: tecnico.disponible
          ? () => setState(() => _selectedTecnico = tecnico)
          : null,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                  .withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: tecnico.disponible
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              child: Text(
                tecnico.nombre.substring(0, 1).toUpperCase(),
                style: AppTextStyles.titleLarge(
                  color: tecnico.disponible ? AppColors.primary : Colors.grey,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tecnico.nombre,
                          style: AppTextStyles.titleMedium(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(
                              color: AppColors.info,
                            ),
                          ),
                          child: Text(
                            'ACTUAL',
                            style: AppTextStyles.labelSmall(
                              color: AppColors.info,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  if (tecnico.especialidad != null) ...[
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          size: 14,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        SizedBox(width: 4),
                        Text(
                          tecnico.especialidad!,
                          style: AppTextStyles.bodySmall(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tecnico.email,
                          style: AppTextStyles.bodySmall(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (tecnico.telefono != null) ...[
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        SizedBox(width: 4),
                        Text(
                          tecnico.telefono!,
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
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 28,
              )
            else if (!tecnico.disponible)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  'NO DISPONIBLE',
                  style: AppTextStyles.labelSmall(
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotasField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notas de asignación (opcional)',
          style: AppTextStyles.titleSmall(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _notasController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ej: Asignado por urgencia, cliente preferencial...',
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
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ModernButton.outlined(
            label: 'Cancelar',
            onPressed: _isLoading ? null : () => Navigator.pop(context),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ModernButton.primary(
            label: 'Asignar',
            icon: Icons.check_circle_outline,
            onPressed: _isLoading || _selectedTecnico == null
                ? null
                : _assignTecnico,
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }
}
