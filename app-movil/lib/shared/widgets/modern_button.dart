import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_text_styles.dart';
import '../../core/design/app_shadows.dart';

/// Modern button with multiple variants and animations
/// Enterprise-grade button component
enum ModernButtonVariant {
  filled,
  outlined,
  text,
  gradient,
  glassmorphism,
}

enum ModernButtonSize {
  small,
  medium,
  large,
}

class ModernButton extends StatefulWidget {
  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final ModernButtonVariant variant;
  final ModernButtonSize size;
  final IconData? icon;
  final IconData? suffixIcon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? color;
  final Gradient? gradient;
  final double? width;
  final double? height;

  const ModernButton({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.variant = ModernButtonVariant.filled,
    this.size = ModernButtonSize.medium,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.color,
    this.gradient,
    this.width,
    this.height,
  }) : assert(label != null || child != null, 'Either label or child must be provided');

  /// Primary filled button
  factory ModernButton.primary({
    String? label,
    Widget? child,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = false,
    ModernButtonSize size = ModernButtonSize.medium,
  }) {
    return ModernButton(
      label: label,
      child: child,
      onPressed: onPressed,
      variant: ModernButtonVariant.filled,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      color: AppColors.primary,
    );
  }

  /// Secondary outlined button
  factory ModernButton.secondary({
    String? label,
    Widget? child,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = false,
    ModernButtonSize size = ModernButtonSize.medium,
  }) {
    return ModernButton(
      label: label,
      child: child,
      onPressed: onPressed,
      variant: ModernButtonVariant.outlined,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      color: AppColors.primary,
    );
  }

  /// Gradient button with smooth color transitions
  factory ModernButton.gradient({
    String? label,
    Widget? child,
    required VoidCallback? onPressed,
    required Gradient gradient,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = false,
    ModernButtonSize size = ModernButtonSize.medium,
  }) {
    return ModernButton(
      label: label,
      child: child,
      onPressed: onPressed,
      variant: ModernButtonVariant.gradient,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      gradient: gradient,
    );
  }

  /// Text button (minimal style)
  factory ModernButton.text({
    String? label,
    Widget? child,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    ModernButtonSize size = ModernButtonSize.medium,
  }) {
    return ModernButton(
      label: label,
      child: child,
      onPressed: onPressed,
      variant: ModernButtonVariant.text,
      size: size,
      icon: icon,
      isLoading: isLoading,
      color: AppColors.primary,
    );
  }

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: isEnabled ? _handleTapDown : null,
        onTapUp: isEnabled ? _handleTapUp : null,
        onTapCancel: isEnabled ? _handleTapCancel : null,
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.isFullWidth ? double.infinity : widget.width,
          height: widget.height ?? _getHeight(),
          decoration: _buildDecoration(isDark, isEnabled),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? widget.onPressed : null,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _getHorizontalPadding(),
                  vertical: _getVerticalPadding(),
                ),
                child: _buildContent(isDark, isEnabled),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(bool isDark, bool isEnabled) {
    final opacity = isEnabled ? 1.0 : 0.5;

    switch (widget.variant) {
      case ModernButtonVariant.filled:
        return BoxDecoration(
          color: (widget.color ?? AppColors.primary).withOpacity(opacity),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: isEnabled ? AppShadows.button : null,
        );

      case ModernButtonVariant.gradient:
        return BoxDecoration(
          gradient: widget.gradient ??
              LinearGradient(
                colors: AppColors.primaryGradient
                    .map((c) => c.withOpacity(opacity))
                    .toList(),
              ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: isEnabled ? AppShadows.button : null,
        );

      case ModernButtonVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: (widget.color ?? AppColors.primary).withOpacity(opacity),
            width: 2,
          ),
        );

      case ModernButtonVariant.text:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        );

      case ModernButtonVariant.glassmorphism:
        return BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark.withOpacity(0.3)
              : AppColors.surfaceLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
            width: 1.5,
          ),
        );
    }
  }

  Widget _buildContent(bool isDark, bool isEnabled) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: _getIconSize(),
          height: _getIconSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getTextColor(isDark, isEnabled),
            ),
          ),
        ),
      );
    }

    List<Widget> children = [];

    // Leading icon
    if (widget.icon != null) {
      children.add(
        Icon(
          widget.icon,
          size: _getIconSize(),
          color: _getTextColor(isDark, isEnabled),
        ),
      );
      if (widget.label != null || widget.child != null) {
        children.add(SizedBox(width: AppSpacing.xs));
      }
    }

    // Label or child
    if (widget.label != null) {
      children.add(
        Text(
          widget.label!,
          style: _getTextStyle(isDark, isEnabled),
          textAlign: TextAlign.center,
        ),
      );
    } else if (widget.child != null) {
      children.add(
        DefaultTextStyle(
          style: _getTextStyle(isDark, isEnabled),
          child: widget.child!,
        ),
      );
    }

    // Suffix icon
    if (widget.suffixIcon != null) {
      if (widget.label != null || widget.child != null) {
        children.add(SizedBox(width: AppSpacing.xs));
      }
      children.add(
        Icon(
          widget.suffixIcon,
          size: _getIconSize(),
          color: _getTextColor(isDark, isEnabled),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Color _getTextColor(bool isDark, bool isEnabled) {
    final opacity = isEnabled ? 1.0 : 0.5;

    switch (widget.variant) {
      case ModernButtonVariant.filled:
      case ModernButtonVariant.gradient:
        return Colors.white.withOpacity(opacity);

      case ModernButtonVariant.outlined:
      case ModernButtonVariant.text:
        return (widget.color ?? AppColors.primary).withOpacity(opacity);

      case ModernButtonVariant.glassmorphism:
        return (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
            .withOpacity(opacity);
    }
  }

  TextStyle _getTextStyle(bool isDark, bool isEnabled) {
    final baseStyle = widget.size == ModernButtonSize.small
        ? AppTextStyles.labelMedium()
        : widget.size == ModernButtonSize.large
            ? AppTextStyles.labelLarge()
            : AppTextStyles.button();

    return baseStyle.copyWith(
      color: _getTextColor(isDark, isEnabled),
      fontWeight: FontWeight.w600,
    );
  }

  double _getHeight() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return AppSpacing.buttonHeightSm;
      case ModernButtonSize.large:
        return AppSpacing.buttonHeightLg;
      case ModernButtonSize.medium:
      default:
        return AppSpacing.buttonHeight;
    }
  }

  double _getHorizontalPadding() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return AppSpacing.sm;
      case ModernButtonSize.large:
        return AppSpacing.xl;
      case ModernButtonSize.medium:
      default:
        return AppSpacing.lg;
    }
  }

  double _getVerticalPadding() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return AppSpacing.xs;
      case ModernButtonSize.large:
        return AppSpacing.sm;
      case ModernButtonSize.medium:
      default:
        return AppSpacing.sm;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return AppSpacing.iconSm;
      case ModernButtonSize.large:
        return AppSpacing.iconLg;
      case ModernButtonSize.medium:
      default:
        return AppSpacing.iconMd;
    }
  }
}
