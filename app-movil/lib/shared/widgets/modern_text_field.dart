import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_text_styles.dart';

/// Modern text field with advanced features and animations
/// Enterprise-grade input component
class ModernTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool hasFloatingLabel;
  final bool hasBorder;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;

  const ModernTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.hasFloatingLabel = true,
    this.hasBorder = true,
    this.fillColor,
    this.contentPadding,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _borderAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label (if not floating)
        if (widget.label != null && !widget.hasFloatingLabel) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelLarge(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: AppSpacing.xxs),
        ],

        // Text field
        AnimatedBuilder(
          animation: _borderAnimation,
          builder: (context, child) {
            return TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              maxLength: widget.maxLength,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              autofocus: widget.autofocus,
              validator: widget.validator,
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.onSubmitted,
              onTap: widget.onTap,
              inputFormatters: widget.inputFormatters,
              textCapitalization: widget.textCapitalization,
              style: AppTextStyles.bodyLarge(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                labelText: widget.hasFloatingLabel ? widget.label : null,
                hintText: widget.hint,
                helperText: widget.helperText,
                errorText: widget.errorText,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _getIconColor(isDark),
                      )
                    : null,
                prefix: widget.prefix,
                suffix: widget.suffix,
                suffixIcon: widget.suffixIcon != null
                    ? IconButton(
                        icon: Icon(
                          widget.suffixIcon,
                          color: _getIconColor(isDark),
                        ),
                        onPressed: widget.onSuffixIconTap,
                      )
                    : null,
                filled: true,
                fillColor: widget.fillColor ??
                    (isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceLight),
                contentPadding: widget.contentPadding ??
                    EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                border: _buildBorder(isDark, false, false),
                enabledBorder: _buildBorder(isDark, false, false),
                focusedBorder: _buildBorder(isDark, true, false),
                errorBorder: _buildBorder(isDark, false, true),
                focusedErrorBorder: _buildBorder(isDark, true, true),
                disabledBorder: _buildBorder(isDark, false, false),
                labelStyle: AppTextStyles.bodyMedium(
                  color: _isFocused
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
                hintStyle: AppTextStyles.bodyMedium(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
                helperStyle: AppTextStyles.bodySmall(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
                errorStyle: AppTextStyles.bodySmall(
                  color: AppColors.error,
                ),
                counterStyle: AppTextStyles.bodySmall(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getIconColor(bool isDark) {
    if (!widget.enabled) {
      return isDark
          ? AppColors.textDisabledDark
          : AppColors.textDisabledLight;
    }

    if (_isFocused) {
      return AppColors.primary;
    }

    return isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
  }

  InputBorder _buildBorder(bool isDark, bool isFocused, bool hasError) {
    if (!widget.hasBorder) {
      return InputBorder.none;
    }

    Color borderColor;
    if (hasError) {
      borderColor = AppColors.error;
    } else if (isFocused) {
      borderColor = AppColors.primary;
    } else {
      borderColor = isDark ? AppColors.outlineDark : AppColors.outlineLight;
    }

    final borderWidth = isFocused ? _borderAnimation.value : 1.0;

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: BorderSide(
        color: borderColor,
        width: borderWidth,
      ),
    );
  }
}

/// Modern search field with clear button and search icon
class ModernSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const ModernSearchField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  @override
  State<ModernSearchField> createState() => _ModernSearchFieldState();
}

class _ModernSearchFieldState extends State<ModernSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleTextChange);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_handleTextChange);
    }
    super.dispose();
  }

  void _handleTextChange() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return ModernTextField(
      controller: _controller,
      hint: widget.hint ?? 'Buscar...',
      prefixIcon: Icons.search,
      suffixIcon: _hasText ? Icons.clear : null,
      onSuffixIconTap: _hasText ? _handleClear : null,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.1, end: 0);
  }
}

/// Modern password field with show/hide toggle
class ModernPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool autofocus;

  const ModernPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  @override
  State<ModernPasswordField> createState() => _ModernPasswordFieldState();
}

class _ModernPasswordFieldState extends State<ModernPasswordField> {
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModernTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      errorText: widget.errorText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
      obscureText: _obscureText,
      prefixIcon: Icons.lock_outline,
      suffixIcon: _obscureText
          ? Icons.visibility_outlined
          : Icons.visibility_off_outlined,
      onSuffixIconTap: _toggleObscureText,
      textInputAction: TextInputAction.done,
    );
  }
}
