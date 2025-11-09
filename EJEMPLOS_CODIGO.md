# 💻 EJEMPLOS DE CÓDIGO - COPY & PASTE

## 🎯 IMPLEMENTACIÓN RÁPIDA

Esta guía contiene ejemplos completos de código que puedes **copiar y pegar directamente** en tu aplicación.

---

## 1️⃣ ACTUALIZAR ROUTER

### Opción A: Si usas GoRouter (Recomendado)

**Archivo**: `lib/core/config/router.dart`

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AGREGAR ESTOS IMPORTS:
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/kanban/presentation/screens/kanban_board_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/home' : '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }
      if (isAuthenticated && isLoginRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main Routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),

      // ✅ NUEVAS RUTAS ENTERPRISE
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/kanban',
        name: 'kanban',
        builder: (context, state) => const KanbanBoardScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Reclamos Routes
      GoRoute(
        path: '/reclamos',
        builder: (context, state) => const ReclamosListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ReclamoDetailScreen(reclamoId: id);
            },
          ),
          GoRoute(
            path: 'crear',
            builder: (context, state) => const CreateReclamoScreen(),
          ),
        ],
      ),

      // Perfil Route
      GoRoute(
        path: '/perfil',
        builder: (context, state) => const PerfilScreen(),
      ),

      // Notificaciones Route
      GoRoute(
        path: '/notificaciones',
        builder: (context, state) => const NotificacionesScreen(),
      ),
    ],
  );
});
```

---

## 2️⃣ AGREGAR NAVEGACIÓN EN DRAWER

**Archivo**: `lib/features/home/presentation/screens/home_screen.dart`

```dart
Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      // Header del Drawer
      UserAccountsDrawerHeader(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        accountName: Text(
          authState.user?.nombre ?? 'Usuario',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        accountEmail: Text(
          authState.user?.email ?? 'email@example.com',
        ),
      ),

      // Dashboard
      ListTile(
        leading: Icon(Icons.dashboard, color: AppColors.primary),
        title: Text('Dashboard'),
        onTap: () {
          Navigator.pop(context);
          context.go('/home');
        },
      ),

      // ✅ ANALYTICS (NUEVO)
      ListTile(
        leading: Icon(Icons.analytics, color: AppColors.info),
        title: Text('Analytics'),
        subtitle: Text('Reportes y métricas'),
        onTap: () {
          Navigator.pop(context);
          context.push('/analytics');
        },
      ),

      // Reclamos
      ListTile(
        leading: Icon(Icons.assignment, color: AppColors.warning),
        title: Text('Reclamos'),
        onTap: () {
          Navigator.pop(context);
          context.push('/reclamos');
        },
      ),

      // ✅ KANBAN (NUEVO)
      ListTile(
        leading: Icon(Icons.view_kanban, color: AppColors.success),
        title: Text('Kanban Board'),
        subtitle: Text('Vista de tablero'),
        onTap: () {
          Navigator.pop(context);
          context.push('/kanban');
        },
      ),

      // Notificaciones
      ListTile(
        leading: Icon(Icons.notifications, color: AppColors.secondary),
        title: Text('Notificaciones'),
        trailing: notificacionesNoLeidas > 0
            ? Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$notificacionesNoLeidas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () {
          Navigator.pop(context);
          context.push('/notificaciones');
        },
      ),

      Divider(),

      // Perfil
      ListTile(
        leading: Icon(Icons.person),
        title: Text('Mi Perfil'),
        onTap: () {
          Navigator.pop(context);
          context.push('/perfil');
        },
      ),

      // ✅ SETTINGS (NUEVO)
      ListTile(
        leading: Icon(Icons.settings),
        title: Text('Configuración'),
        onTap: () {
          Navigator.pop(context);
          context.push('/settings');
        },
      ),

      Divider(),

      // Cerrar Sesión
      ListTile(
        leading: Icon(Icons.logout, color: AppColors.error),
        title: Text(
          'Cerrar Sesión',
          style: TextStyle(color: AppColors.error),
        ),
        onTap: () {
          Navigator.pop(context);
          _showLogoutDialog(context, ref);
        },
      ),
    ],
  ),
)
```

---

## 3️⃣ AGREGAR BOTONES EN APPBAR

**Archivo**: `lib/features/home/presentation/screens/home_screen.dart`

```dart
AppBar(
  title: Text('Dashboard'),
  elevation: 0,
  actions: [
    // ✅ Botón de Analytics
    IconButton(
      icon: Icon(Icons.analytics),
      tooltip: 'Analytics',
      onPressed: () => context.push('/analytics'),
    ),

    // ✅ Botón de Kanban
    IconButton(
      icon: Icon(Icons.view_kanban),
      tooltip: 'Kanban',
      onPressed: () => context.push('/kanban'),
    ),

    // Notificaciones con badge
    Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () => context.push('/notificaciones'),
        ),
        if (notificacionesNoLeidas > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '$notificacionesNoLeidas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    ),

    // ✅ Botón de Settings
    IconButton(
      icon: Icon(Icons.settings),
      tooltip: 'Configuración',
      onPressed: () => context.push('/settings'),
    ),

    SizedBox(width: 8),
  ],
)
```

---

## 4️⃣ USAR ADVANCED SEARCH BAR

**Ejemplo en cualquier pantalla:**

```dart
import 'package:flutter/material.dart';
import '../../../../core/widgets/premium/advanced_search_bar.dart';

class MiPantalla extends StatefulWidget {
  @override
  State<MiPantalla> createState() => _MiPantallaState();
}

class _MiPantallaState extends State<MiPantalla> {
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mi Pantalla')),
      body: Column(
        children: [
          // ✅ ADVANCED SEARCH BAR
          AdvancedSearchBar(
            hint: 'Buscar reclamos, clientes, técnicos...',
            onSearch: (query) {
              setState(() => _searchQuery = query);
              // Aquí ejecutas tu lógica de búsqueda
              print('Buscando: $query');
            },
            onFiltersChanged: (filters) {
              setState(() => _activeFilters = filters);
              // Aquí aplicas los filtros
              print('Filtros activos: $filters');
            },
            filters: [
              SearchFilter(
                key: 'estado',
                label: 'Estado',
                type: FilterType.chips,
                options: ['Pendiente', 'En Curso', 'Resuelto', 'Cerrado'],
              ),
              SearchFilter(
                key: 'prioridad',
                label: 'Prioridad',
                type: FilterType.dropdown,
                options: ['Alta', 'Media', 'Baja'],
              ),
              SearchFilter(
                key: 'categoria',
                label: 'Categoría',
                type: FilterType.chips,
                options: ['Internet', 'Telefonía', 'Cable', 'Otros'],
              ),
              SearchFilter(
                key: 'fecha',
                label: 'Fecha',
                type: FilterType.dateRange,
              ),
            ],
            suggestions: [
              SearchSuggestion(
                title: 'Reclamos de internet',
                subtitle: '15 resultados',
                icon: Icons.wifi,
              ),
              SearchSuggestion(
                title: 'Reclamos urgentes',
                subtitle: '3 resultados',
                icon: Icons.priority_high,
              ),
            ],
            showVoiceSearch: true,
            showQRScanner: true,
          ),

          // Resultados
          Expanded(
            child: ListView(
              children: [
                // Tus resultados filtrados aquí
                Text('Query: $_searchQuery'),
                Text('Filtros: $_activeFilters'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 5️⃣ USAR KPI COMPARISON CARD

**Ejemplo en Dashboard:**

```dart
import '../../../../features/analytics/presentation/widgets/kpi_comparison_card.dart';
import '../../../../features/analytics/presentation/screens/analytics_screen.dart';

// En tu build method:
GridView.count(
  crossAxisCount: 2,
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  children: [
    // ✅ KPI Card 1
    KPIComparisonCard(
      data: KPIData(
        title: 'Total Reclamos',
        value: '${stats.total}',
        change: 12.5,
        icon: Icons.analytics,
        color: AppColors.primary,
        previousValue: '${stats.total - 100}',
      ),
      isComparing: true,
    ),

    // ✅ KPI Card 2
    KPIComparisonCard(
      data: KPIData(
        title: 'Tiempo Resolución',
        value: '2.4h',
        change: -15.3, // Negativo es bueno aquí
        icon: Icons.timer,
        color: AppColors.success,
        previousValue: '2.8h',
      ),
      isComparing: true,
    ),

    // ✅ KPI Card 3
    KPIComparisonCard(
      data: KPIData(
        title: 'Satisfacción',
        value: '94.5%',
        change: 5.2,
        icon: Icons.sentiment_satisfied,
        color: AppColors.warning,
        previousValue: '89.8%',
      ),
      isComparing: false, // Sin comparación
    ),

    // ✅ KPI Card 4
    KPIComparisonCard(
      data: KPIData(
        title: 'SLA Cumplido',
        value: '87%',
        change: -2.1,
        icon: Icons.check_circle,
        color: AppColors.info,
        previousValue: '89%',
      ),
      isComparing: true,
    ),
  ],
)
```

---

## 6️⃣ DIALOG DE LOGOUT

**Helper function para mostrar confirmación:**

```dart
void _showLogoutDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.logout, color: AppColors.error),
          SizedBox(width: 8),
          Text('Cerrar Sesión'),
        ],
      ),
      content: Text(
        '¿Estás seguro que deseas cerrar sesión?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Cerrar sesión
            ref.read(authProvider.notifier).logout();
            context.go('/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: Text('Cerrar Sesión'),
        ),
      ],
    ),
  );
}
```

---

## 7️⃣ FLOATING ACTION MENU (Speed Dial)

**Para agregar múltiples acciones rápidas:**

```dart
// Agregar esta dependencia a pubspec.yaml:
// flutter_speed_dial: ^7.0.0

import 'package:flutter_speed_dial/flutter_speed_dial.dart';

// En tu Scaffold:
floatingActionButton: SpeedDial(
  icon: Icons.add,
  activeIcon: Icons.close,
  backgroundColor: AppColors.primary,
  foregroundColor: Colors.white,
  activeBackgroundColor: AppColors.error,
  activeForegroundColor: Colors.white,
  visible: true,
  closeManually: false,
  curve: Curves.bounceIn,
  overlayColor: Colors.black,
  overlayOpacity: 0.5,
  children: [
    SpeedDialChild(
      child: Icon(Icons.assignment),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      label: 'Nuevo Reclamo',
      labelStyle: TextStyle(fontSize: 14),
      onTap: () => context.push('/reclamos/crear'),
    ),
    SpeedDialChild(
      child: Icon(Icons.analytics),
      backgroundColor: AppColors.info,
      foregroundColor: Colors.white,
      label: 'Ver Analytics',
      onTap: () => context.push('/analytics'),
    ),
    SpeedDialChild(
      child: Icon(Icons.view_kanban),
      backgroundColor: AppColors.success,
      foregroundColor: Colors.white,
      label: 'Abrir Kanban',
      onTap: () => context.push('/kanban'),
    ),
  ],
)
```

---

## 8️⃣ BOTTOM NAVIGATION BAR (Alternativa)

**Si prefieres navegación inferior:**

```dart
class MainNavigationScreen extends StatefulWidget {
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ReclamosListScreen(),
    KanbanBoardScreen(),
    AnalyticsScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment),
            label: 'Reclamos',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_kanban),
            label: 'Kanban',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
```

---

## 9️⃣ CUSTOMIZAR COLORES DEL THEME

**Archivo**: `lib/core/design/app_colors.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  // ✅ CAMBIA ESTOS COLORES A TU MARCA
  static const Color primary = Color(0xFF2196F3);      // Azul
  static const Color secondary = Color(0xFF4CAF50);    // Verde
  static const Color accent = Color(0xFFFF9800);       // Naranja

  // Estados
  static const Color success = Color(0xFF4CAF50);      // Verde
  static const Color warning = Color(0xFFFF9800);      // Naranja
  static const Color error = Color(0xFFF44336);        // Rojo
  static const Color info = Color(0xFF2196F3);         // Azul

  // Estados de Reclamos (personalizar según tu negocio)
  static const Color estadoPendiente = Color(0xFFFF9800);
  static const Color estadoEnCurso = Color(0xFF2196F3);
  static const Color estadoResuelto = Color(0xFF4CAF50);
  static const Color estadoCerrado = Color(0xFF9E9E9E);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);

  // Cards
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Borders
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);

  // ✅ AGREGAR TUS PROPIOS COLORES AQUÍ
  static const Color miColorCustom = Color(0xFF9C27B0);  // Ejemplo
}
```

---

## 🔟 CONECTAR CON API REAL

**Ejemplo para Analytics Provider:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../screens/analytics_screen.dart';
import '../../../../core/network/dio_client.dart'; // Tu cliente HTTP

part 'analytics_provider.g.dart';

@riverpod
class Analytics extends _$Analytics {
  @override
  Future<AnalyticsData> build() async {
    return await _loadAnalytics('month');
  }

  Future<AnalyticsData> _loadAnalytics(String period) async {
    // ✅ CONECTAR CON TU API REAL
    try {
      final client = ref.read(dioClientProvider);

      final response = await client.get('/api/analytics', queryParameters: {
        'period': period,
      });

      // Parsear respuesta a tu modelo
      return AnalyticsData.fromJson(response.data);

    } catch (e) {
      // Error handling
      throw Exception('Error al cargar analytics: ${e.toString()}');
    }
  }

  Future<void> loadAnalytics(String period) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadAnalytics(period));
  }

  Future<void> applyFilters(Map<String, dynamic> filters) async {
    state = const AsyncValue.loading();

    try {
      final client = ref.read(dioClientProvider);

      final response = await client.post('/api/analytics/filter', data: filters);

      state = AsyncValue.data(AnalyticsData.fromJson(response.data));

    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
```

---

## 1️⃣1️⃣ SNIPPETS ÚTILES

### Show SnackBar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 8),
        Expanded(child: Text('Operación exitosa')),
      ],
    ),
    backgroundColor: AppColors.success,
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 3),
    action: SnackBarAction(
      label: 'Deshacer',
      textColor: Colors.white,
      onPressed: () {
        // Deshacer acción
      },
    ),
  ),
);
```

### Show Loading Dialog
```dart
void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando...'),
          ],
        ),
      ),
    ),
  );
}

// Para cerrar:
Navigator.of(context).pop();
```

### Confirm Dialog Genérico
```dart
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirmar',
  String cancelText = 'Cancelar',
  Color? confirmColor,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? AppColors.primary,
          ),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}

// Uso:
final confirmed = await showConfirmDialog(
  context,
  title: 'Eliminar Reclamo',
  message: '¿Estás seguro?',
  confirmText: 'Eliminar',
  confirmColor: AppColors.error,
);

if (confirmed == true) {
  // Ejecutar acción
}
```

---

## 📝 NOTAS FINALES

### ✅ Checklist de Implementación

```
□ Agregar rutas en router.dart
□ Agregar navegación en Drawer/AppBar
□ Ejecutar flutter pub get
□ Ejecutar build_runner build
□ Probar Analytics Screen
□ Probar Kanban Board
□ Probar Settings Screen
□ Personalizar colores
□ Conectar con API real
□ Testing en dispositivo real
```

### 🚀 Comandos Útiles

```bash
# Instalar dependencias
flutter pub get

# Generar código
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (regenea automáticamente)
flutter pub run build_runner watch

# Limpiar y rebuilar
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Run en release mode
flutter run --release

# Analizar código
flutter analyze

# Formatear código
dart format lib/

# Verificar versión de Flutter
flutter --version
```

---

**¡Listo para implementar!** 🎉

Usa estos ejemplos como base y personalízalos según tu necesidad.

