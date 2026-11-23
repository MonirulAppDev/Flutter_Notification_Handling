import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_handling/core/services/notification/notification_config.dart';
import 'package:notification_handling/core/services/notification/notification_navigation.dart';
import 'package:notification_handling/core/services/notification/notification_permission_handler.dart';
import 'package:notification_handling/core/services/notification/notification_permission_status.dart';

/// Central Notification Service managing notification lifecycle, channels,
/// notification display, and launch payload handling.
class NotificationService {
  NotificationService._() {
    _permissionHandler = NotificationPermissionHandler(_plugin);
  }

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  late final NotificationPermissionHandler _permissionHandler;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Backward-compatible getter
  bool get isInitialize => _isInitialized;

  /// Access dedicated permission handler
  NotificationPermissionHandler get permission => _permissionHandler;

  /// Initialize notification plugin and create notification channels safely.
  Future<void> initialize({
    void Function(NotificationResponse details)? onNotificationTap,
  }) async {
    if (_isInitialized) {
      debugPrint("NotificationService is already initialized");
      return;
    }

    try {
      await _plugin.initialize(
        settings: NotificationConfig.initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap ??
            (details) {
              NotificationNavigation.handleNotificationNavigations(
                details.payload,
              );
            },
      );

      await _createAndroidChannel();

      _isInitialized = true;
      debugPrint("NotificationService initialized successfully!");
    } catch (e, st) {
      _isInitialized = false;
      debugPrint("Notification initialization error: $e");
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  /// Create Android Notification Channel safely.
  Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;

    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(
        NotificationConfig.channel,
      );
      debugPrint("Android notification channel created");
    } catch (e, st) {
      debugPrint("Android notification channel creation failed: $e");
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  /// Shows a notification with the specified details.
  Future<void> showNotification({
    required int id,
    required String title,
    required String description,
    String? payload,
    NotificationDetails? notificationDetails,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await _plugin.show(
        id: id,
        title: title,
        body: description,
        notificationDetails:
            notificationDetails ?? NotificationConfig.notificationDetails,
        payload: payload,
      );
    } catch (e, st) {
      debugPrint("Notification showing error: $e");
      debugPrintStack(stackTrace: st);
    }
  }

  /// Retrieves launch notification details if the app was opened via a notification.
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async {
    return await _plugin.getNotificationAppLaunchDetails();
  }

  /// Retrieves launch payload directly if the app was opened via a notification.
  Future<String?> getLaunchPayload() async {
    final details = await getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details?.notificationResponse?.payload;
    }
    return null;
  }

  /// Backward-compatible method to inspect launch notification
  Future<void> checkForLaunchNotification() async {
    final payload = await getLaunchPayload();
    if (payload != null) {
      debugPrint("Notification launch payload: $payload");
    }
  }

  // --- Permission Delegations ---

  Future<bool> hasPermission() => _permissionHandler.hasPermission();

  Future<NotificationPermissionStatus> checkNotificationPermission() =>
      _permissionHandler.checkPermission();

  Future<NotificationPermissionStatus> requestPermission() =>
      _permissionHandler.requestPermission();

  Future<bool> openAppSettings() => _permissionHandler.openAppSettings();
}
