import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../services/push_notification_service.dart';

/// Push notification state
class PushNotificationState {
  final bool isInitialized;
  final bool hasPermission;
  final String? playerId;
  final String? pushToken;
  final OSNotification? lastNotification;
  final OSNotificationOpenedResult? lastOpenedNotification;

  const PushNotificationState({
    this.isInitialized = false,
    this.hasPermission = false,
    this.playerId,
    this.pushToken,
    this.lastNotification,
    this.lastOpenedNotification,
  });

  PushNotificationState copyWith({
    bool? isInitialized,
    bool? hasPermission,
    String? playerId,
    String? pushToken,
    OSNotification? lastNotification,
    OSNotificationOpenedResult? lastOpenedNotification,
  }) {
    return PushNotificationState(
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
      playerId: playerId ?? this.playerId,
      pushToken: pushToken ?? this.pushToken,
      lastNotification: lastNotification ?? this.lastNotification,
      lastOpenedNotification: lastOpenedNotification ?? this.lastOpenedNotification,
    );
  }
}

/// Push notification notifier
class PushNotificationNotifier extends StateNotifier<PushNotificationState> {
  final PushNotificationService _pushService;

  PushNotificationNotifier(this._pushService) : super(const PushNotificationState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      await _pushService.initialize();

      // Listen to notification events
      _pushService.notificationReceived.listen((notification) {
        state = state.copyWith(lastNotification: notification);
      });

      _pushService.notificationOpened.listen((openedResult) {
        state = state.copyWith(lastOpenedNotification: openedResult);
      });

      _pushService.permissionChanged.listen((hasPermission) {
        state = state.copyWith(hasPermission: hasPermission);
      });

      // Update initial state
      final hasPermission = await _pushService.areNotificationsEnabled();
      state = state.copyWith(
        isInitialized: true,
        hasPermission: hasPermission,
        playerId: _pushService.playerId,
        pushToken: _pushService.pushToken,
      );
    } catch (e) {
      print('[PushNotificationProvider] Error initializing: $e');
    }
  }

  /// Set user ID for targeted notifications
  Future<void> setUserId(String userId) async {
    await _pushService.setExternalUserId(userId);
    state = state.copyWith(playerId: _pushService.playerId);
  }

  /// Remove user ID
  Future<void> removeUserId() async {
    await _pushService.removeExternalUserId();
  }

  /// Set tags for segmentation
  Future<void> setTags(Map<String, dynamic> tags) async {
    await _pushService.setTags(tags);
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    final granted = await _pushService.requestPermission();
    state = state.copyWith(hasPermission: granted);
    return granted;
  }

  /// Opt in to notifications
  Future<void> optIn() async {
    await _pushService.optIn();
    state = state.copyWith(hasPermission: true);
  }

  /// Opt out of notifications
  Future<void> optOut() async {
    await _pushService.optOut();
    state = state.copyWith(hasPermission: false);
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _pushService.clearNotifications();
  }

  @override
  void dispose() {
    _pushService.dispose();
    super.dispose();
  }
}

/// Push notification service provider
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService();
});

/// Push notification provider
final pushNotificationProvider =
    StateNotifierProvider<PushNotificationNotifier, PushNotificationState>((ref) {
  final pushService = ref.watch(pushNotificationServiceProvider);
  return PushNotificationNotifier(pushService);
});
