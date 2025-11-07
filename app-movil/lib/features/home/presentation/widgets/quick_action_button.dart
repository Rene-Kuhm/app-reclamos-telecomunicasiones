import 'package:flutter/material.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_animations.dart';

/// Enterprise-grade Quick action button widget with hover effect
class QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        curve: AppAnimations.emphasized,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: _isHovered
                ? widget.color.withOpacity(0.4)
                : (isDark ? AppColors.outlineDark : AppColors.outlineLight).withOpacity(0.2),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color.withOpacity(0.15),
                          widget.color.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: AppSpacing.iconLg,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.label,
                    style: AppTextStyles.bodyMedium(
                      color: _isHovered
                          ? widget.color
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
