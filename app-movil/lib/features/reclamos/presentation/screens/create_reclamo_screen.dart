import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/loading_button.dart';
import '../providers/reclamos_provider.dart';

/// Create reclamo screen
class CreateReclamoScreen extends ConsumerStatefulWidget {
  const CreateReclamoScreen({super.key});

  @override
  ConsumerState<CreateReclamoScreen> createState() => _CreateReclamoScreenState();
}

class _CreateReclamoScreenState extends ConsumerState<CreateReclamoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  String _selectedCategoria = 'INTERNET_FIBRA';
  String _selectedPrioridad = 'MEDIA';

  bool _isSubmitting = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await ref.read(reclamosProvider.notifier).createReclamo(
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          categoria: _selectedCategoria,
          prioridad: _selectedPrioridad,
        );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reclamo creado exitosamente')),
      );
      context.pop();
    } else {
      final error = ref.read(reclamosProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al crear reclamo'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Reclamo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Titulo
            CustomTextField(
              controller: _tituloController,
              label: 'Título',
              hint: 'Resumen breve del problema',
              validator: (value) => Validators.validateRequired(value, 'El título'),
              textInputAction: TextInputAction.next,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),

            // Descripcion
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe el problema en detalle',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) => Validators.validateRequired(value, 'La descripción'),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),

            // Categoria
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

            // Prioridad
            DropdownButtonFormField<String>(
              value: _selectedPrioridad,
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'BAJA',
                  child: Text('Baja'),
                ),
                DropdownMenuItem(
                  value: 'MEDIA',
                  child: Text('Media'),
                ),
                DropdownMenuItem(
                  value: 'ALTA',
                  child: Text('Alta'),
                ),
                DropdownMenuItem(
                  value: 'URGENTE',
                  child: Text('Urgente'),
                ),
              ],
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      setState(() => _selectedPrioridad = value!);
                    },
            ),
            const SizedBox(height: 24),

            // Submit button
            LoadingButton(
              onPressed: _handleSubmit,
              isLoading: _isSubmitting,
              child: const Text('Crear Reclamo'),
            ),
          ],
        ),
      ),
    );
  }
}
