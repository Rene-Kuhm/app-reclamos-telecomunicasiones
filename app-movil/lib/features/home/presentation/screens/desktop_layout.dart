import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_shadows.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notificaciones/presentation/providers/notificaciones_provider.dart';

/// Desktop layout with sidebar navigation
class DesktopLayout extends ConsumerStatefulWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const DesktopLayout({
    super.key,
    required this.child,
    this.selectedIndex = 0,
    required this.onDestinationSelected,
  });

  @override
  ConsumerState<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends ConsumerState<DesktopLayout> {
  bool _isSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final notifState = ref.watch(notificacionesProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Row(
        children: [
          // Sidebar - Dark minimalist style
          Container(
            width: _isSidebarExpanded ? 260 : 80,
            decoration: const BoxDecoration(
              color: AppColors.secondary, // Dark slate sidebar
            ),
            child: Column(
              children: [
                // Header - Minimalist logo area with DrawerHeader style
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.support_agent_rounded,
                        color: AppColors.primary,
                        size: 48,
                      ),
                      if (_isSidebarExpanded) ...[
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'COSPEC',
                          style: AppTextStyles.titleLarge(
                            color: Colors.white,
                          ).copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'Comunicaciones',
                          style: AppTextStyles.bodySmall(
                            color: AppColors.primary,
                          ).copyWith(
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Navigation items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                      horizontal: AppSpacing.md,
                    ),
                    children: [
                      _NavItem(
                        icon: Icons.dashboard_outlined,
                        label: 'Dashboard',
                        isSelected: widget.selectedIndex == 0,
                        isExpanded: _isSidebarExpanded,
                        onTap: () => widget.onDestinationSelected(0),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      _NavItem(
                        icon: Icons.report_problem_outlined,
                        label: 'Reclamos',
                        isSelected: widget.selectedIndex == 1,
                        isExpanded: _isSidebarExpanded,
                        onTap: () => widget.onDestinationSelected(1),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      _NavItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notificaciones',
                        isSelected: widget.selectedIndex == 2,
                        isExpanded: _isSidebarExpanded,
                        badge: notifState.unreadCount > 0
                            ? notifState.unreadCount.toString()
                            : null,
                        onTap: () => widget.onDestinationSelected(2),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      _NavItem(
                        icon: Icons.person_outline,
                        label: 'Perfil',
                        isSelected: widget.selectedIndex == 3,
                        isExpanded: _isSidebarExpanded,
                        onTap: () => widget.onDestinationSelected(3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final String? badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white54,
                size: 24,
              ),
              if (isExpanded) ...[
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium(
                      color: isSelected ? Colors.white : Colors.white54,
                    ).copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
              if (badge != null && isExpanded)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
