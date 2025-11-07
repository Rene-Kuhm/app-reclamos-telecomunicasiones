import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../config/app_config.dart';

/// Push notification service using OneSignal
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  bool _initialized = false;
  String? _playerId;
  String? _pushToken;

  // Stream controllers for notification events
  final _notificationReceivedController = StreamController<OSNotification>.broadcast();
  final _notificationOpenedController = StreamController<OSNotificationOpenedResult>.broadcast();
  final _permissionChangedController = StreamController<bool>.broadcast();

  // Streams
  Stream<OSNotification> get notificationReceived => _notificationReceivedController.stream;
  Stream<OSNotificationOpenedResult> get notificationOpened => _notificationOpenedController.stream;
  Stream<bool> get permissionChanged => _permissionChangedController.stream;

  // Getters
  String? get playerId => _playerId;
  String? get pushToken => _pushToken;
  bool get isInitialized => _initialized;

  /// Initialize OneSignal
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('[OneSignal] Already initialized');
      return;
    }

    try {
      debugPrint('[OneSignal] Initializing with App ID: ${AppConfig.oneSignalAppId}');

      // Initialize OneSignal
      OneSignal.initialize(AppConfig.oneSignalAppId);

      // Request notification permission
      await OneSignal.Notifications.requestPermission(true);

      // Set up notification handlers
      _setupNotificationHandlers();

      // Get player ID and push token
      final status = OneSignal.User.pushSubscription;
      _playerId = status.id;
      _pushToken = status.token;

      debugPrint('[OneSignal] Initialized successfully');
      debugPrint('[OneSignal] Player ID: $_playerId');
      debugPrint('[OneSignal] Push Token: $_pushToken');

      _initialized = true;
    } catch (e) {
      debugPrint('[OneSignal] Error initializing: $e');
      rethrow;
    }
  }

  /// Set up notification handlers
  void _setupNotificationHandlers() {
    // Notification received handler (while app is in foreground)
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('[OneSignal] Notification received: ${event.notification.notificationId}');
      _notificationReceivedController.add(event.notification);
      // Display the notification
      event.preventDefault();
      event.notification.display();
    });

    // Notification opened handler
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('[OneSignal] Notification opened: ${event.notification.notificationId}');
      _notificationOpenedController.add(event);
    });

    // Permission changed handler
    OneSignal.Notifications.addPermissionObserver((permission) {
      debugPrint('[OneSignal] Permission changed: $permission');
      _permissionChangedController.add(permission);
    });

    // Subscription changed handler
    OneSignal.User.pushSubscription.addObserver((state) {
      debugPrint('[OneSignal] Push subscription changed');
      debugPrint('[OneSignal] Player ID: ${state.current.id}');
      debugPrint('[OneSignal] Push Token: ${state.current.token}');
      _playerId = state.current.id;
      _pushToken = state.current.token;
    });
  }

  /// Set external user ID (for identifying users)
  Future<void> setExternalUserId(String userId) async {
    if (!_initialized) {
      debugPrint('[OneSignal] Not initialized, cannot set external user ID');
      return;
    }

    try {
      OneSignal.login(userId);
      debugPrint('[OneSignal] External user ID set: $userId');
    } catch (e) {
      debugPrint('[OneSignal] Error setting external user ID: $e');
    }
  }

  /// Remove external user ID
  Future<void> removeExternalUserId() async {
    if (!_initialized) {
      debugPrint('[OneSignal] Not initialized, cannot remove external user ID');
      return;
    }

    try {
      OneSignal.logout();
      debugPrint('[OneSignal] External user ID removed');
    } catch (e) {
      debugPrint('[OneSignal] Error removing external user ID: $e');
    }
  }

  /// Set notification tags (for segmentation)
  Future<void> setTags(Map<String, dynamic> tags) async {
    if (!_initialized) {
      debugPrint('[OneSignal] Not initialized, cannot set tags');
      return;
    }

    try {
      for (final entry in tags.entries) {
        OneSignal.User.addTag(entry.key, entry.value.toString());
      }
      debugPrint('[OneSignal] Tags set: $tags');
    } catch (e) {
      debugPrint('[OneSignal] Error setting tags: $e');
    }
  }

  /// Remove notification tags
  Future<void> removeTags(List<String> keys) async {
    if (!_initialized) {
      debugPrint('[OneSignal] Not initialized, cannot remove tags');
      return;
    }

    try {
      for (final key in keys) {
        OneSignal.User.removeTag(key);
      }
      debugPrint('[OneSignal] Tags removed: $keys');
    } catch (e) {
      debugPrint('[OneSignal] Error removing tags: $e');
    }
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    if (!_initialized) {
      debugPrint('[OneSignal] Not initialized, cannot request permission');
      return false;
    }

    try {
      final permission = await OneSignal.Notifications.requestPermission(true);
      debugPrint('[OneSignal] Permission requested: $permission');
      return permission;
    } catch (e) {
      debugPrint('[OneSignal] Error requesting permission: $e');
      return false;
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (!_initialized) {
      debugPrint('[OneSignal] Not initialized, cannot check permission');
      return false;
    }

    try {
      final permission = await OneSignal.Notifications.permission;
      return permission;
    } catch (e) {
      debugPrint('[OneSignal] Error checking permission: $e');
      return false;
    }
  }

  /// Opt in to push notifications
  Future<void> optIn() async {
    if (!_initialized) {
      debugPrint('[OneSignal] Not initialized, cannot opt in');
      return;
    }

    try {
      OneSignal.User.pushSubscription.optIn();
      debugPrint('[OneSignal] Opted in to push notifications');
    } catch (e) {
      debugPrint('[OneSignal] Error opting in: $e');
    }
  }

  /// Opt out of push notifications
  Future<void> optOut() async {
    if (!_initialized) {
      debugPrint('[OneSignal] Not initialized, cannot opt out');
      return;
    }

    try {
      OneSignal.User.pushSubscription.optOut();
      debugPrint('[OneSignal] Opted out of push notifications');
    } catch (e) {
      debugPrint('[OneSignal] Error opting out: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearNotifications() async {
    if (!_initialized) {
      debugPrint('[OneSignal] Not initialized, cannot clear notifications');
      return;
    }

    try {
      OneSignal.Notifications.clearAll();
      debugPrint('[OneSignal] All notifications cleared');
    } catch (e) {
      debugPrint('[OneSignal] Error clearing notifications: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _notificationReceivedController.close();
    _notificationOpenedController.close();
    _permissionChangedController.close();
  }
}
