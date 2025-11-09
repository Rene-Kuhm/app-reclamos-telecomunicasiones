import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import '../../../../core/utils/responsive.dart';
import '../../../reclamos/presentation/screens/premium_reclamos_list_screen.dart';
import '../../../notificaciones/presentation/screens/notificaciones_list_screen.dart';
import '../../../notificaciones/presentation/providers/notificaciones_provider.dart';
import '../../../perfil/presentation/screens/perfil_screen.dart';
import 'enterprise_dashboard_screen.dart';
import 'desktop_layout.dart';

/// Adaptive home screen that changes layout based on screen size
class AdaptiveHomeScreen extends ConsumerStatefulWidget {
  const AdaptiveHomeScreen({super.key});

  @override
  ConsumerState<AdaptiveHomeScreen> createState() =>
      _AdaptiveHomeScreenState();
}

class _AdaptiveHomeScreenState extends ConsumerState<AdaptiveHomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    EnterpriseDashboardScreen(),
    PremiumReclamosListScreen(),
    NotificacionesListScreen(),
    PerfilScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificacionesProvider);
    final unreadCount =
        notifState.notificaciones.where((n) => !n.leida).length;

    // Desktop layout with sidebar
    if (Responsive.isDesktop(context)) {
      return DesktopLayout(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        child: _screens[_currentIndex],
      );
    }

    // Mobile/Tablet layout with bottom navigation
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.report_problem_outlined),
            selectedIcon: Icon(Icons.report_problem),
            label: 'Reclamos',
          ),
          NavigationDestination(
            icon: unreadCount > 0
                ? badges.Badge(
                    badgeContent: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    child: const Icon(Icons.notifications_outlined),
                  )
                : const Icon(Icons.notifications_outlined),
            selectedIcon: unreadCount > 0
                ? badges.Badge(
                    badgeContent: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    child: const Icon(Icons.notifications),
                  )
                : const Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
