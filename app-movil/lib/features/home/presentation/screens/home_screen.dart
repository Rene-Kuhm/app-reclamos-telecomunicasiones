import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:badges/badges.dart' as badges;
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../../../reclamos/presentation/screens/premium_reclamos_list_screen.dart';
import '../../../notificaciones/presentation/screens/notificaciones_list_screen.dart';
import '../../../notificaciones/presentation/providers/notificaciones_provider.dart';
import '../../../perfil/presentation/screens/perfil_screen.dart';
import 'enterprise_dashboard_screen.dart';

/// Modern home screen with glassmorphic bottom navigation
/// Enterprise-grade UI with smooth transitions
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  final _screens = const [
    EnterpriseDashboardScreen(),
    PremiumReclamosListScreen(),
    NotificacionesListScreen(),
    PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (index != _currentIndex) {
      _animationController.forward(from: 0);
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificacionesProvider);
    final unreadCount = notifState.notificaciones.where((n) => !n.leida).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Screens
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Fade transition overlay
          FadeTransition(
            opacity: _animationController,
            child: Container(
              color: (isDark ? AppColors.backgroundDark : AppColors.backgroundLight)
                  .withOpacity(0.3),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ModernBottomNav(
        currentIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        unreadCount: unreadCount,
      ).animate().fadeIn(delay: 100.ms).slideY(begin: 1, end: 0),
    );
  }
}

/// Modern glassmorphic bottom navigation bar
class _ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final int unreadCount;

  const _ModernBottomNav({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.all(AppSpacing.sm),
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: GlassmorphicContainer(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          margin: EdgeInsets.zero,
          borderRadius: AppSpacing.radiusXl,
          blur: 15,
          opacity: isDark ? 0.05 : 0.2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Inicio',
                isSelected: currentIndex == 0,
                onTap: () => onDestinationSelected(0),
              ),
              _NavBarItem(
                icon: Icons.description_outlined,
                selectedIcon: Icons.description,
                label: 'Reclamos',
                isSelected: currentIndex == 1,
                onTap: () => onDestinationSelected(1),
              ),
              _NavBarItem(
                icon: Icons.notifications_outlined,
                selectedIcon: Icons.notifications,
                label: 'Notificaciones',
                isSelected: currentIndex == 2,
                onTap: () => onDestinationSelected(2),
                badge: unreadCount > 0 ? unreadCount : null,
              ),
              _NavBarItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Perfil',
                isSelected: currentIndex == 3,
                onTap: () => onDestinationSelected(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom navigation bar item with animations
class _NavBarItem extends StatefulWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  const _NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(
                        widget.isSelected ? widget.selectedIcon : widget.icon,
                        color: widget.isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                        size: 24,
                      ),
                    ),
                  ),

                  // Badge
                  if (widget.badge != null && widget.badge! > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.badge! > 9 ? 5 : 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          border: Border.all(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.surfaceLight,
                            width: 2,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          widget.badge! > 99 ? '99+' : '${widget.badge}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: widget.badge! > 9 ? 9 : 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().scale(duration: 300.ms),
                    ),
                ],
              ),

              SizedBox(height: AppSpacing.xxxs),

              // Label
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: widget.isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
