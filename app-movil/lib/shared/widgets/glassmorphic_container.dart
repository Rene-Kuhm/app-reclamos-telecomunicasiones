import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_colors.dart';

/// Glassmorphic container with frosted glass effect
/// Modern UI trend for elevated surfaces
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = double.nan, // NaN means "shrink to fit content"
    this.padding,
    this.margin,
    this.borderRadius = AppSpacing.radiusLg,
    this.blur = 10.0,
    this.opacity = 0.15,
    this.color,
    this.border,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Only set height if it's not NaN (NaN means shrink to fit content)
    final double? containerHeight = height.isNaN ? null : height;

    return Container(
      width: width,
      height: containerHeight,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color ??
                  (isDark
                      ? Colors.white.withOpacity(opacity * 0.5)
                      : Colors.white.withOpacity(opacity)),
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(isDark ? 0.08 : 0.15),
                      Colors.white.withOpacity(isDark ? 0.03 : 0.05),
                    ],
                  ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: Colors.white.withOpacity(isDark ? 0.15 : 0.25),
                    width: 1.5,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Frosted glass app bar
class GlassmorphicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final double height;
  final Color? backgroundColor;
  final double blur;

  const GlassmorphicAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.height = kToolbarHeight,
    this.backgroundColor,
    this.blur = 10.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: AppBar(
          leading: leading,
          title: title,
          actions: actions,
          backgroundColor: backgroundColor ??
              (isDark
                  ? AppColors.surfaceDark.withOpacity(0.7)
                  : AppColors.surfaceLight.withOpacity(0.7)),
          elevation: 0,
          toolbarHeight: height,
        ),
      ),
    );
  }
}

/// Glassmorphic navigation bar
class GlassmorphicBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassmorphicNavItem> items;
  final double blur;
  final double height;

  const GlassmorphicBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.blur = 10.0,
    this.height = 70,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark.withOpacity(0.8)
                  : AppColors.surfaceLight.withOpacity(0.8),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                items.length,
                (index) => _NavBarItem(
                  item: items[index],
                  isSelected: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassmorphicNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const GlassmorphicNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

class _NavBarItem extends StatelessWidget {
  final GlassmorphicNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
