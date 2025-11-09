import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../shared/widgets/modern_text_field.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../shared/widgets/gradient_container.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../providers/auth_provider.dart';

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
  double _passwordStrength = 0.0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_calculatePasswordStrength);
  }

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

  void _calculatePasswordStrength() {
    final password = _passwordController.text;
    double strength = 0.0;

    if (password.isEmpty) {
      setState(() => _passwordStrength = 0.0);
      return;
    }

    // Length check
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.25;

    // Character variety checks
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.1;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.1;

    setState(() => _passwordStrength = strength.clamp(0.0, 1.0));
  }

  Color _getPasswordStrengthColor() {
    if (_passwordStrength < 0.3) return AppColors.error;
    if (_passwordStrength < 0.6) return AppColors.warning;
    return AppColors.success;
  }

  String _getPasswordStrengthLabel() {
    if (_passwordStrength < 0.3) return 'Debil';
    if (_passwordStrength < 0.6) return 'Media';
    if (_passwordStrength < 0.8) return 'Fuerte';
    return 'Muy fuerte';
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      _showErrorSnackBar('Debes aceptar los terminos y condiciones');
      return;
    }

    final success = await ref.read(authProvider.notifier).register(
          nombre: _nombreController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          telefono: _telefonoController.text.trim(),
          direccion: _direccionController.text.trim(),
          dni: _dniController.text.trim().isEmpty
              ? null
              : _dniController.text.trim(),
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
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Background (Orange theme)
          AnimatedGradientBackground(
            colors: const [
              Color(0xFFE65100), // Accent Orange
              Color(0xFFFF6F00), // Lighter Orange
              Color(0xFFAC1900), // Darker Orange
            ],
            duration: const Duration(seconds: 8),
            child: const SizedBox.expand(),
          ),

          // Decorative circles
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Back Button
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      ModernButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onPressed: () => context.pop(),
                        variant: ModernButtonVariant.glassmorphism,
                        size: ModernButtonSize.small,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.3, end: 0),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? AppSpacing.xxxl : AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop
                              ? 550
                              : (isTablet ? 500 : double.infinity),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Logo Section
                              _buildLogoSection()
                                  .animate()
                                  .fadeIn(duration: 600.ms)
                                  .scale(
                                    begin: const Offset(0.8, 0.8),
                                    curve: Curves.easeOutBack,
                                  ),

                              SizedBox(height: AppSpacing.xl),

                              // Header
                              _buildHeaderText()
                                  .animate(delay: 200.ms)
                                  .fadeIn(duration: 500.ms)
                                  .slideY(begin: 0.3, end: 0),

                              SizedBox(height: AppSpacing.xl),

                              // Glassmorphic Form Container
                              GlassmorphicContainer(
                                padding: EdgeInsets.all(
                                  isDesktop ? AppSpacing.xxl : AppSpacing.lg,
                                ),
                                blur: 20,
                                opacity: 0.15,
                                child: Column(
                                  children: [
                                    // Row with two fields on desktop/tablet
                                    if (isTablet || isDesktop) ...[
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ModernTextField(
                                              controller: _nombreController,
                                              label: 'Nombre completo',
                                              hint: 'Juan Perez',
                                              prefixIcon: Icons.person_outline,
                                              validator: (value) =>
                                                  Validators.validateRequired(
                                                      value, 'El nombre'),
                                              textInputAction:
                                                  TextInputAction.next,
                                              enabled: !authState.isLoading,
                                            )
                                                .animate(delay: 300.ms)
                                                .fadeIn()
                                                .slideX(begin: -0.2, end: 0),
                                          ),
                                          SizedBox(width: AppSpacing.md),
                                          Expanded(
                                            child: ModernTextField(
                                              controller: _emailController,
                                              label: 'Email',
                                              hint: 'tu@email.com',
                                              prefixIcon: Icons.email_outlined,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              validator:
                                                  Validators.validateEmail,
                                              textInputAction:
                                                  TextInputAction.next,
                                              enabled: !authState.isLoading,
                                            )
                                                .animate(delay: 350.ms)
                                                .fadeIn()
                                                .slideX(begin: -0.2, end: 0),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: AppSpacing.sm),
                                    ] else ...[
                                      // Mobile: stacked fields
                                      ModernTextField(
                                        controller: _nombreController,
                                        label: 'Nombre completo',
                                        hint: 'Juan Perez',
                                        prefixIcon: Icons.person_outline,
                                        validator: (value) =>
                                            Validators.validateRequired(
                                                value, 'El nombre'),
                                        textInputAction: TextInputAction.next,
                                        enabled: !authState.isLoading,
                                      )
                                          .animate(delay: 300.ms)
                                          .fadeIn()
                                          .slideX(begin: -0.2, end: 0),
                                      SizedBox(height: AppSpacing.sm),
                                      ModernTextField(
                                        controller: _emailController,
                                        label: 'Email',
                                        hint: 'tu@email.com',
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: Validators.validateEmail,
                                        textInputAction: TextInputAction.next,
                                        enabled: !authState.isLoading,
                                      )
                                          .animate(delay: 350.ms)
                                          .fadeIn()
                                          .slideX(begin: -0.2, end: 0),
                                      SizedBox(height: AppSpacing.sm),
                                    ],

                                    // Password field with strength indicator
                                    ModernPasswordField(
                                      controller: _passwordController,
                                      label: 'Contrasena',
                                      hint: 'Minimo 6 caracteres',
                                      validator: Validators.validatePassword,
                                    )
                                        .animate(delay: 400.ms)
                                        .fadeIn()
                                        .slideX(begin: -0.2, end: 0),

                                    // Password strength indicator
                                    if (_passwordController.text.isNotEmpty) ...[
                                      SizedBox(height: AppSpacing.xs),
                                      _buildPasswordStrengthIndicator()
                                          .animate()
                                          .fadeIn()
                                          .slideX(begin: -0.1, end: 0),
                                    ],

                                    SizedBox(height: AppSpacing.sm),

                                    // Confirm Password field
                                    ModernPasswordField(
                                      controller: _confirmPasswordController,
                                      label: 'Confirmar contrasena',
                                      hint: 'Repite tu contrasena',
                                      validator: (value) =>
                                          Validators.validateConfirmPassword(
                                        value,
                                        _passwordController.text,
                                      ),
                                    )
                                        .animate(delay: 450.ms)
                                        .fadeIn()
                                        .slideX(begin: -0.2, end: 0),

                                    SizedBox(height: AppSpacing.sm),

                                    // Telefono and Direccion
                                    if (isTablet || isDesktop) ...[
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ModernTextField(
                                              controller: _telefonoController,
                                              label: 'Telefono',
                                              hint: '2645123456',
                                              prefixIcon: Icons.phone_outlined,
                                              keyboardType: TextInputType.phone,
                                              validator:
                                                  Validators.validatePhone,
                                              textInputAction:
                                                  TextInputAction.next,
                                              enabled: !authState.isLoading,
                                            )
                                                .animate(delay: 500.ms)
                                                .fadeIn()
                                                .slideX(begin: -0.2, end: 0),
                                          ),
                                          SizedBox(width: AppSpacing.md),
                                          Expanded(
                                            child: ModernTextField(
                                              controller: _direccionController,
                                              label: 'Direccion',
                                              hint: 'Av. Libertador 123',
                                              prefixIcon: Icons.home_outlined,
                                              validator: (value) =>
                                                  Validators.validateRequired(
                                                      value, 'La direccion'),
                                              textInputAction:
                                                  TextInputAction.next,
                                              enabled: !authState.isLoading,
                                            )
                                                .animate(delay: 550.ms)
                                                .fadeIn()
                                                .slideX(begin: -0.2, end: 0),
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      ModernTextField(
                                        controller: _telefonoController,
                                        label: 'Telefono',
                                        hint: '2645123456',
                                        prefixIcon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                        validator: Validators.validatePhone,
                                        textInputAction: TextInputAction.next,
                                        enabled: !authState.isLoading,
                                      )
                                          .animate(delay: 500.ms)
                                          .fadeIn()
                                          .slideX(begin: -0.2, end: 0),
                                      SizedBox(height: AppSpacing.sm),
                                      ModernTextField(
                                        controller: _direccionController,
                                        label: 'Direccion',
                                        hint: 'Av. Libertador 123',
                                        prefixIcon: Icons.home_outlined,
                                        validator: (value) =>
                                            Validators.validateRequired(
                                                value, 'La direccion'),
                                        textInputAction: TextInputAction.next,
                                        enabled: !authState.isLoading,
                                      )
                                          .animate(delay: 550.ms)
                                          .fadeIn()
                                          .slideX(begin: -0.2, end: 0),
                                    ],

                                    SizedBox(height: AppSpacing.sm),

                                    // DNI field (optional)
                                    ModernTextField(
                                      controller: _dniController,
                                      label: 'DNI (opcional)',
                                      hint: '12345678',
                                      prefixIcon: Icons.badge_outlined,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.done,
                                      enabled: !authState.isLoading,
                                      onSubmitted: (_) => _handleRegister(),
                                    )
                                        .animate(delay: 600.ms)
                                        .fadeIn()
                                        .slideX(begin: -0.2, end: 0),
                                  ],
                                ),
                              )
                                  .animate(delay: 250.ms)
                                  .fadeIn(duration: 600.ms)
                                  .scale(begin: const Offset(0.95, 0.95)),

                              SizedBox(height: AppSpacing.lg),

                              // Terms and conditions checkbox
                              _buildTermsCheckbox(authState)
                                  .animate(delay: 650.ms)
                                  .fadeIn()
                                  .slideX(begin: -0.1, end: 0),

                              SizedBox(height: AppSpacing.xl),

                              // Register button
                              ModernButton.gradient(
                                label: 'Crear Cuenta',
                                icon: Icons.person_add_rounded,
                                onPressed: authState.isLoading
                                    ? null
                                    : _handleRegister,
                                isLoading: authState.isLoading,
                                isFullWidth: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.95),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                size: ModernButtonSize.large,
                              )
                                  .animate(delay: 700.ms)
                                  .fadeIn(duration: 500.ms)
                                  .slideY(begin: 0.3, end: 0)
                                  .shimmer(
                                    delay: 1200.ms,
                                    duration: 1500.ms,
                                    color: Colors.white.withOpacity(0.3),
                                  ),

                              SizedBox(height: AppSpacing.lg),

                              // Login link
                              _buildLoginLink(authState)
                                  .animate(delay: 750.ms)
                                  .fadeIn(duration: 500.ms),

                              SizedBox(height: AppSpacing.md),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.support_agent_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'COSPEC',
          style: AppTextStyles.displaySmall(
            color: Colors.white,
          ).copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            fontSize: 36,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(0, 4),
                blurRadius: 20,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHeaderText() {
    return Column(
      children: [
        Text(
          'Crear Cuenta',
          style: AppTextStyles.headlineMedium(
            color: Colors.white,
          ).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          'Completa tus datos para empezar',
          style: AppTextStyles.bodyLarge(
            color: Colors.white.withOpacity(0.95),
          ).copyWith(
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 1),
                blurRadius: 5,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: LinearProgressIndicator(
                  value: _passwordStrength,
                  minHeight: 6,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getPasswordStrengthColor(),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              _getPasswordStrengthLabel(),
              style: AppTextStyles.bodySmall(
                color: Colors.white.withOpacity(0.9),
              ).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox(AuthState authState) {
    return GlassmorphicContainer(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      blur: 15,
      opacity: 0.1,
      child: Row(
        children: [
          Checkbox(
            value: _acceptedTerms,
            onChanged: authState.isLoading
                ? null
                : (value) {
                    setState(() {
                      _acceptedTerms = value ?? false;
                    });
                  },
            activeColor: Colors.white,
            checkColor: AppColors.accent,
            side: BorderSide(
              color: Colors.white.withOpacity(0.5),
              width: 2,
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Acepto los ',
                style: AppTextStyles.bodyMedium(
                  color: Colors.white.withOpacity(0.95),
                ),
                children: [
                  TextSpan(
                    text: 'terminos y condiciones',
                    style: AppTextStyles.bodyMedium(
                      color: Colors.white,
                    ).copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink(AuthState authState) {
    return GlassmorphicContainer(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      blur: 15,
      opacity: 0.1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Ya tienes cuenta?',
            style: AppTextStyles.bodyMedium(
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: authState.isLoading ? null : () => context.go('/login'),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Text(
                'Iniciar Sesion',
                style: AppTextStyles.labelLarge(
                  color: Colors.white,
                ).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
