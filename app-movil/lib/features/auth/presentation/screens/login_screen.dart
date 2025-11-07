import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_animations.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      _shakeController.forward(from: 0);
      return;
    }

    final success = await ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (mounted && !success) {
      _shakeController.forward(from: 0);
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al iniciar sesión'),
          backgroundColor: AppColors.error,
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
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.backgroundDark,
                    AppColors.surfaceVariantDark,
                  ]
                : [
                    AppColors.backgroundLight,
                    AppColors.primaryLight.withOpacity(0.05),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final offset = AppAnimations.createShakeAnimation(_shakeController).value;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo Container with gradient background
                      _buildLogoSection(isDark)
                          .animate()
                          .fadeIn(duration: AppAnimations.normal)
                          .scale(begin: const Offset(0.8, 0.8)),

                      SizedBox(height: AppSpacing.xl),

                      // Welcome Text
                      _buildWelcomeText(context, isDark)
                          .animate(delay: 100.ms)
                          .fadeIn()
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: AppSpacing.xxxl),

                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'tucorreo@ejemplo.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: Validators.validateEmail,
                        enabled: !authState.isLoading,
                      ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.2, end: 0),

                      SizedBox(height: AppSpacing.sm),

                      // Password Field
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Contraseña',
                        hint: 'Ingresa tu contraseña',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: Validators.validatePassword,
                        enabled: !authState.isLoading,
                      ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.2, end: 0),

                      SizedBox(height: AppSpacing.lg),

                      // Login Button
                      LoadingButton(
                        onPressed: _handleLogin,
                        isLoading: authState.isLoading,
                        child: const Text('Iniciar Sesión'),
                      ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3, end: 0),

                      SizedBox(height: AppSpacing.md),

                      // Divider
                      _buildDivider(context, isDark)
                          .animate(delay: 500.ms)
                          .fadeIn(),

                      SizedBox(height: AppSpacing.md),

                      // Register Link
                      _buildRegisterLink(context, authState, isDark)
                          .animate(delay: 600.ms)
                          .fadeIn(),

                      SizedBox(height: AppSpacing.xs),

                      // Forgot Password Link
                      _buildForgotPasswordLink(context, authState, isDark)
                          .animate(delay: 700.ms)
                          .fadeIn(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.createGradient(
          AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.phone_in_talk_rounded,
            size: AppSpacing.iconXxl,
            color: Colors.white,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Reclamos Telco',
            style: AppTextStyles.headlineMedium(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context, bool isDark) {
    return Column(
      children: [
        Text(
          'Bienvenido de nuevo',
          style: AppTextStyles.headlineSmall(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          'Inicia sesión para continuar',
          style: AppTextStyles.bodyLarge(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            'o',
            style: AppTextStyles.bodySmall(
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink(BuildContext context, AuthState authState, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes cuenta? ',
          style: AppTextStyles.bodyMedium(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        TextButton(
          onPressed: authState.isLoading
              ? null
              : () => context.push('/register'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
          ),
          child: Text(
            'Regístrate',
            style: AppTextStyles.labelLarge(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink(BuildContext context, AuthState authState, bool isDark) {
    return TextButton(
      onPressed: authState.isLoading
          ? null
          : () => context.push('/forgot-password'),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      child: Text(
        '¿Olvidaste tu contraseña?',
        style: AppTextStyles.bodyMedium(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
