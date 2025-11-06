import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_button.dart';

/// Register screen
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _dniController = TextEditingController();

  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      _showErrorSnackBar('Debes aceptar los términos y condiciones');
      return;
    }

    final success = await ref.read(authProvider.notifier).register(
      nombre: _nombreController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      telefono: _telefonoController.text.trim(),
      direccion: _direccionController.text.trim(),
      dni: _dniController.text.trim().isEmpty ? null : _dniController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      final error = ref.read(authProvider).error;
      _showErrorSnackBar(error ?? 'Error al registrarse');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Registro',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completa tus datos para crear una cuenta',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 32),

                // Nombre completo field
                CustomTextField(
                  controller: _nombreController,
                  label: 'Nombre completo',
                  hint: 'Juan Pérez',
                  prefixIcon: Icons.person_outline,
                  validator: (value) => Validators.validateRequired(value, 'El nombre'),
                  textInputAction: TextInputAction.next,
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 16),

                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'tu@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  textInputAction: TextInputAction.next,
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 16),

                // Password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  hint: 'Mínimo 6 caracteres',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  validator: Validators.validatePassword,
                  textInputAction: TextInputAction.next,
                  enabled: !authState.isLoading,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar contraseña',
                  hint: 'Repite tu contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  textInputAction: TextInputAction.next,
                  enabled: !authState.isLoading,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Teléfono field
                CustomTextField(
                  controller: _telefonoController,
                  label: 'Teléfono',
                  hint: '2645123456',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                  textInputAction: TextInputAction.next,
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 16),

                // Dirección field
                CustomTextField(
                  controller: _direccionController,
                  label: 'Dirección',
                  hint: 'Av. Libertador 123',
                  prefixIcon: Icons.home_outlined,
                  validator: (value) => Validators.validateRequired(value, 'La dirección'),
                  textInputAction: TextInputAction.next,
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 16),

                // DNI field (optional)
                CustomTextField(
                  controller: _dniController,
                  label: 'DNI (opcional)',
                  hint: '12345678',
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  enabled: !authState.isLoading,
                  onSubmitted: (_) => _handleRegister(),
                ),
                const SizedBox(height: 24),

                // Terms and conditions checkbox
                CheckboxListTile(
                  value: _acceptedTerms,
                  onChanged: authState.isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Acepto los términos y condiciones',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),

                // Register button
                LoadingButton(
                  onPressed: _handleRegister,
                  isLoading: authState.isLoading,
                  child: const Text('Crear Cuenta'),
                ),
                const SizedBox(height: 16),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes cuenta?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => context.go('/login'),
                      child: const Text('Iniciar Sesión'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
