import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/loading_button.dart';
import '../providers/reclamo_detail_provider.dart';

/// Edit reclamo screen
class EditReclamoScreen extends ConsumerStatefulWidget {
  final String reclamoId;

  const EditReclamoScreen({
    super.key,
    required this.reclamoId,
  });

  @override
  ConsumerState<EditReclamoScreen> createState() => _EditReclamoScreenState();
}

class _EditReclamoScreenState extends ConsumerState<EditReclamoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;

  late String _selectedCategoria;
  late String _selectedPrioridad;

  bool _isSubmitting = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController();
    _descripcionController = TextEditingController();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await ref
        .read(reclamoDetailProvider(widget.reclamoId).notifier)
        .updateReclamo(
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          categoria: _selectedCategoria,
          prioridad: _selectedPrioridad,
        );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reclamo actualizado')),
      );
      context.pop();
    } else {
      final error = ref.read(reclamoDetailProvider(widget.reclamoId)).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al actualizar reclamo'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reclamoDetailProvider(widget.reclamoId));

    if (state.reclamo != null && !_isInitialized) {
      _tituloController.text = state.reclamo!.titulo;
      _descripcionController.text = state.reclamo!.descripcion;
      _selectedCategoria = state.reclamo!.categoria;
      _selectedPrioridad = state.reclamo!.prioridad;
      _isInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Reclamo'),
      ),
      body: state.reclamo == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CustomTextField(
                    controller: _tituloController,
                    label: 'Título',
                    validator: (value) => Validators.validateRequired(value, 'El título'),
                    textInputAction: TextInputAction.next,
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (value) =>
                        Validators.validateRequired(value, 'La descripción'),
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedCategoria,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'INTERNET_ADSL',
                        child: Text('Internet ADSL'),
                      ),
                      DropdownMenuItem(
                        value: 'INTERNET_FIBRA',
                        child: Text('Internet Fibra'),
                      ),
                      DropdownMenuItem(
                        value: 'TELEFONO_ADSL',
                        child: Text('Teléfono ADSL'),
                      ),
                      DropdownMenuItem(
                        value: 'TELEFONO_FIBRA',
                        child: Text('Teléfono Fibra'),
                      ),
                      DropdownMenuItem(
                        value: 'TV_SENSA',
                        child: Text('TV Sensa'),
                      ),
                    ],
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            setState(() => _selectedCategoria = value!);
                          },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedPrioridad,
                    decoration: const InputDecoration(
                      labelText: 'Prioridad',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'BAJA', child: Text('Baja')),
                      DropdownMenuItem(value: 'MEDIA', child: Text('Media')),
                      DropdownMenuItem(value: 'ALTA', child: Text('Alta')),
                      DropdownMenuItem(value: 'URGENTE', child: Text('Urgente')),
                    ],
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            setState(() => _selectedPrioridad = value!);
                          },
                  ),
                  const SizedBox(height: 24),

                  LoadingButton(
                    onPressed: _handleSubmit,
                    isLoading: _isSubmitting,
                    child: const Text('Guardar Cambios'),
                  ),
                ],
              ),
            ),
    );
  }
}
