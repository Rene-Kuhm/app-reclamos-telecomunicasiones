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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (mounted && !success) {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al iniciar sesion'),
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
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background with animated effect
          AnimatedGradientBackground(
            colors: const [
              Color(0xFF2697FF), // Primary Blue
              Color(0xFF1565C0), // Darker Blue
              Color(0xFF0D47A1), // Deep Blue
            ],
            duration: const Duration(seconds: 8),
            child: const SizedBox.expand(),
          ),

          // Decorative circles (glassmorphism effect)
          Positioned(
            top: -100,
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
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? AppSpacing.xxxl : AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 500 : (isTablet ? 450 : 600),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo Section with modern design
                        _buildLogoSection()
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1.0, 1.0),
                              curve: Curves.easeOutBack,
                            ),

                        SizedBox(height: AppSpacing.xxxl),

                        // Welcome Text
                        _buildWelcomeText()
                            .animate(delay: 200.ms)
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.3, end: 0),

                        SizedBox(height: AppSpacing.xxxl),

                        // Glassmorphic Form Container
                        GlassmorphicContainer(
                          padding: EdgeInsets.all(
                            isDesktop ? AppSpacing.xxl : AppSpacing.lg,
                          ),
                          blur: 20,
                          opacity: 0.15,
                          child: Column(
                            children: [
                              // Email Field
                              ModernTextField(
                                controller: _emailController,
                                label: 'Correo electronico',
                                hint: 'tu@ejemplo.com',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.email_outlined,
                                validator: Validators.validateEmail,
                                enabled: !authState.isLoading,
                                textInputAction: TextInputAction.next,
                              )
                                  .animate(delay: 300.ms)
                                  .fadeIn(duration: 500.ms)
                                  .slideX(begin: -0.2, end: 0),

                              SizedBox(height: AppSpacing.md),

                              // Password Field
                              ModernPasswordField(
                                controller: _passwordController,
                                label: 'Contrasena',
                                hint: 'Ingresa tu contrasena',
                                validator: Validators.validatePassword,
                                onSubmitted: (_) => _handleLogin(),
                              )
                                  .animate(delay: 400.ms)
                                  .fadeIn(duration: 500.ms)
                                  .slideX(begin: -0.2, end: 0),

                              SizedBox(height: AppSpacing.sm),

                              // Remember Me Switch
                              Row(
                                children: [
                                  Switch(
                                    value: _rememberMe,
                                    onChanged: authState.isLoading
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _rememberMe = value;
                                            });
                                          },
                                    activeColor: AppColors.primary,
                                  ),
                                  SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'Recordarme',
                                    style: AppTextStyles.bodyMedium(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              )
                                  .animate(delay: 500.ms)
                                  .fadeIn(duration: 500.ms),
                            ],
                          ),
                        )
                            .animate(delay: 250.ms)
                            .fadeIn(duration: 600.ms)
                            .scale(begin: const Offset(0.9, 0.9)),

                        SizedBox(height: AppSpacing.xl),

                        // Login Button with gradient
                        ModernButton.gradient(
                          label: 'Iniciar Sesion',
                          icon: Icons.login_rounded,
                          onPressed: authState.isLoading ? null : _handleLogin,
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
                            .animate(delay: 600.ms)
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.3, end: 0)
                            .shimmer(
                              delay: 1200.ms,
                              duration: 1500.ms,
                              color: Colors.white.withOpacity(0.3),
                            ),

                        SizedBox(height: AppSpacing.md),

                        // Forgot Password Link
                        _buildForgotPasswordLink(authState)
                            .animate(delay: 700.ms)
                            .fadeIn(duration: 500.ms),

                        SizedBox(height: AppSpacing.lg),

                        // Divider with text
                        _buildDivider()
                            .animate(delay: 800.ms)
                            .fadeIn(duration: 500.ms),

                        SizedBox(height: AppSpacing.lg),

                        // Register Link
                        _buildRegisterLink(authState)
                            .animate(delay: 900.ms)
                            .fadeIn(duration: 500.ms),

                        SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo with glassmorphic background
        Container(
          padding: EdgeInsets.all(AppSpacing.xl),
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
            size: 64,
            color: Colors.white,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        // Company Name
        Text(
          'COSPEC',
          style: AppTextStyles.displaySmall(
            color: Colors.white,
          ).copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            fontSize: 42,
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
        SizedBox(height: AppSpacing.xxs),
        Text(
          'Comunicaciones',
          style: AppTextStyles.titleLarge(
            color: Colors.white,
          ).copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.w300,
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
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Bienvenido de nuevo',
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
          'Inicia sesion para gestionar tus reclamos',
          style: AppTextStyles.bodyLarge(
            color: Colors.white.withOpacity(0.95),
          ).copyWith(
            fontSize: 16,
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'o',
              style: AppTextStyles.bodyMedium(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink(AuthState authState) {
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
            'No tienes cuenta?',
            style: AppTextStyles.bodyMedium(
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: authState.isLoading ? null : () => context.push('/register'),
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
                'Registrate',
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

  Widget _buildForgotPasswordLink(AuthState authState) {
    return Center(
      child: GestureDetector(
        onTap: authState.isLoading
            ? null
            : () => context.push('/forgot-password'),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            'Olvidaste tu contrasena?',
            style: AppTextStyles.bodyMedium(
              color: Colors.white.withOpacity(0.95),
            ).copyWith(
              decoration: TextDecoration.underline,
              decorationColor: Colors.white.withOpacity(0.95),
            ),
          ),
        ),
      ),
    );
  }
}
