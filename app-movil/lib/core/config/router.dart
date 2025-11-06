import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/reclamos/presentation/screens/reclamos_list_screen.dart';
import '../../features/reclamos/presentation/screens/reclamo_detail_screen.dart';
import '../../features/reclamos/presentation/screens/create_reclamo_screen.dart';
import '../../features/reclamos/presentation/screens/edit_reclamo_screen.dart';
import '../../features/notificaciones/presentation/screens/notificaciones_list_screen.dart';
import '../../features/perfil/presentation/screens/perfil_screen.dart';
import '../../features/perfil/presentation/screens/edit_perfil_screen.dart';
import '../../features/perfil/presentation/screens/change_password_screen.dart';

/// Router configuration
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';

      // If not authenticated and trying to access protected routes
      if (!isAuthenticated && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      // If authenticated and trying to access login/register
      if (isAuthenticated && (isLoggingIn || isRegistering)) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Home route
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Reclamos routes
      GoRoute(
        path: '/reclamos',
        builder: (context, state) => const ReclamosListScreen(),
      ),
      GoRoute(
        path: '/reclamos/create',
        builder: (context, state) => const CreateReclamoScreen(),
      ),
      GoRoute(
        path: '/reclamos/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReclamoDetailScreen(reclamoId: id);
        },
      ),
      GoRoute(
        path: '/reclamos/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditReclamoScreen(reclamoId: id);
        },
      ),

      // Notificaciones routes
      GoRoute(
        path: '/notificaciones',
        builder: (context, state) => const NotificacionesListScreen(),
      ),

      // Perfil routes
      GoRoute(
        path: '/perfil',
        builder: (context, state) => const PerfilScreen(),
      ),
      GoRoute(
        path: '/perfil/edit',
        builder: (context, state) => const EditPerfilScreen(),
      ),
      GoRoute(
        path: '/perfil/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],
  );
});
