import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_handling/core/services/notification/notification_permission_status.dart';

/// Dedicated handler for checking and requesting platform-specific notification permissions.
class NotificationPermissionHandler {
  NotificationPermissionHandler(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  /// Quick check if notification permission is granted.
  Future<bool> hasPermission() async {
    final status = await checkPermission();
    return status == NotificationPermissionStatus.granted;
  }

  /// Checks current notification permission status across platforms.
  Future<NotificationPermissionStatus> checkPermission() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final isEnabled = await androidPlugin?.areNotificationsEnabled();

        if (isEnabled == null) return NotificationPermissionStatus.notDetermined;
        return isEnabled
            ? NotificationPermissionStatus.granted
            : NotificationPermissionStatus.denied;
      }

      if (Platform.isIOS) {
        final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final settings = await iosPlugin?.checkPermissions();

        if (settings == null) return NotificationPermissionStatus.notDetermined;
        return settings.isEnabled
            ? NotificationPermissionStatus.granted
            : NotificationPermissionStatus.denied;
      }

      return NotificationPermissionStatus.unsupported;
    } catch (e, st) {
      debugPrint("Notification permission check error: $e");
      debugPrintStack(stackTrace: st);
      return NotificationPermissionStatus.error;
    }
  }

  /// Requests notification permission from user.
  Future<NotificationPermissionStatus> requestPermission() async {
    try {
      final currentStatus = await checkPermission();
      if (currentStatus == NotificationPermissionStatus.granted) {
        return NotificationPermissionStatus.granted;
      }

      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidPlugin?.requestNotificationsPermission();

        return granted == true
            ? NotificationPermissionStatus.granted
            : NotificationPermissionStatus.denied;
      }

      if (Platform.isIOS) {
        final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosPlugin?.requestPermissions(
          sound: true,
          alert: true,
          badge: true,
        );

        return granted == true
            ? NotificationPermissionStatus.granted
            : NotificationPermissionStatus.denied;
      }

      return NotificationPermissionStatus.unsupported;
    } catch (e, st) {
      debugPrint("Notification permission request error: $e");
      debugPrintStack(stackTrace: st);
      return NotificationPermissionStatus.error;
    }
  }

  /// Opens the application settings for notifications.
  Future<bool> openAppSettings() async {
    try {
      final opened = await _plugin.openAppNotificationSettings();
      return opened ?? false;
    } catch (e, st) {
      debugPrint("Error opening app settings: $e");
      debugPrintStack(stackTrace: st);
      return false;
    }
  }
}
