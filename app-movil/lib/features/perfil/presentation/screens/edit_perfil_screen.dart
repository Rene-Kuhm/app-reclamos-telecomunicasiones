import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/loading_button.dart';
import '../providers/perfil_provider.dart';

/// Edit perfil screen
class EditPerfilScreen extends ConsumerStatefulWidget {
  const EditPerfilScreen({super.key});

  @override
  ConsumerState<EditPerfilScreen> createState() => _EditPerfilScreenState();
}

class _EditPerfilScreenState extends ConsumerState<EditPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _dniController;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _telefonoController = TextEditingController();
    _direccionController = TextEditingController();
    _dniController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(perfilProvider.notifier).updateProfile(
          nombre: _nombreController.text.trim(),
          telefono: _telefonoController.text.trim(),
          direccion: _direccionController.text.trim(),
          dni: _dniController.text.trim().isEmpty ? null : _dniController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
      context.pop();
    } else {
      final error = ref.read(perfilProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al actualizar perfil'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final perfilState = ref.watch(perfilProvider);
    final user = perfilState.user ?? authState.user;

    if (user != null && !_isInitialized) {
      _nombreController.text = user.nombre;
      _telefonoController.text = user.telefono;
      _direccionController.text = user.direccion;
      _dniController.text = user.dni ?? '';
      _isInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _nombreController,
              label: 'Nombre completo',
              prefixIcon: Icons.person,
              validator: (value) => Validators.validateRequired(value, 'El nombre'),
              textInputAction: TextInputAction.next,
              enabled: !perfilState.isLoading,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _telefonoController,
              label: 'Teléfono',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
              textInputAction: TextInputAction.next,
              enabled: !perfilState.isLoading,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _direccionController,
              label: 'Dirección',
              prefixIcon: Icons.home,
              validator: (value) => Validators.validateRequired(value, 'La dirección'),
              textInputAction: TextInputAction.next,
              enabled: !perfilState.isLoading,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _dniController,
              label: 'DNI (opcional)',
              prefixIcon: Icons.badge,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              enabled: !perfilState.isLoading,
              onSubmitted: (_) => _handleSubmit(),
            ),
            const SizedBox(height: 24),

            LoadingButton(
              onPressed: _handleSubmit,
              isLoading: perfilState.isLoading,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
