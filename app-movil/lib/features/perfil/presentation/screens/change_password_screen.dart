import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/loading_button.dart';
import '../providers/perfil_provider.dart';

/// Change password screen
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(perfilProvider.notifier).changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña cambiada exitosamente')),
      );
      context.pop();
    } else {
      final error = ref.read(perfilProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al cambiar contraseña'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(perfilProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _currentPasswordController,
              label: 'Contraseña actual',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureCurrentPassword,
              validator: Validators.validatePassword,
              textInputAction: TextInputAction.next,
              enabled: !state.isLoading,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureCurrentPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureCurrentPassword = !_obscureCurrentPassword;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _newPasswordController,
              label: 'Nueva contraseña',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureNewPassword,
              validator: Validators.validatePassword,
              textInputAction: TextInputAction.next,
              enabled: !state.isLoading,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _confirmPasswordController,
              label: 'Confirmar nueva contraseña',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              validator: (value) => Validators.validateConfirmPassword(
                value,
                _newPasswordController.text,
              ),
              textInputAction: TextInputAction.done,
              enabled: !state.isLoading,
              onSubmitted: (_) => _handleSubmit(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            LoadingButton(
              onPressed: _handleSubmit,
              isLoading: state.isLoading,
              child: const Text('Cambiar Contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}
