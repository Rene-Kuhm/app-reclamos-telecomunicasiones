import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/router.dart';
import 'core/config/theme_new.dart';
import 'core/config/theme_provider.dart';
import 'core/storage/local_storage.dart';
import 'core/providers/push_notification_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await LocalStorage.instance.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize app services
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check auth status
      ref.read(authProvider.notifier).checkAuthStatus();

      // Initialize push notifications
      ref.read(pushNotificationProvider);

      // Listen to auth changes to sync user ID with OneSignal
      ref.listen<AuthState>(authProvider, (previous, next) {
        if (next.isAuthenticated && next.user != null) {
          // User logged in - set OneSignal user ID
          ref.read(pushNotificationProvider.notifier).setUserId(next.user!.id);

          // Set tags for segmentation
          ref.read(pushNotificationProvider.notifier).setTags({
            'user_id': next.user!.id,
            'email': next.user!.email,
            'rol': next.user!.rol,
          });
        } else if (previous?.isAuthenticated == true && !next.isAuthenticated) {
          // User logged out - remove OneSignal user ID
          ref.read(pushNotificationProvider.notifier).removeUserId();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Reclamos Telco',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
