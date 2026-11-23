import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_handling/core/services/notification/notification_config.dart';
import 'package:notification_handling/core/services/notification/notification_permission_status.dart';
import 'package:notification_handling/features/message/screens/message_screen.dart';
import 'package:notification_handling/main.dart';

class NotificationService {
  NotificationService._();

  //==> variables
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialize = false;

  bool get isInitialize => _isInitialize;

  //==> check notification permissions
  Future<bool> hasPermission() async {
    final status = await checkNotificationPermission();
    debugPrint("Permission check: $status");

    return status == NotificationPermissionStatus.granted;
  }

  //==> initialize method
  Future<void> initialize() async {
    if (_isInitialize) {
      debugPrint("Notification service is already initialized");
      return;
    }

    debugPrint("Notification service initializing");

    try {
      await _plugin.initialize(
        settings: NotificationConfig.initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          final payload = details.payload;

          debugPrint("Notification clicked!");

          if (payload?.startsWith("message ") ?? false) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) {
                  return MessageScreen(
                    messageId: payload?.replaceFirst("message ", ""),
                  );
                },
              ),
            );
          } else {
            debugPrint("Response: ${details.payload}");
          }
        },
      );

      await _createAndroidChannel();

      _isInitialize = true;

      debugPrint("Notification service initialized successfully!");
    } catch (e, st) {
      _isInitialize = false;

      debugPrint("Notification initialization error: $e");
      debugPrintStack(stackTrace: st);

      rethrow;
    }
  }

  //==> android channel creation
  Future<void> _createAndroidChannel() async {
    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin == null) {
        debugPrint("Android plugin not available");
      }

      await androidPlugin!.createNotificationChannel(
        NotificationConfig.channel,
      );

      debugPrint("Notification channel created");
    } catch (e, st) {
      debugPrint("Channel creation failed: $e");
      debugPrintStack(stackTrace: st);

      rethrow;
    }
  }

  //==> check notification permission
  Future<NotificationPermissionStatus> checkNotificationPermission() async {
    try {
      if (!_isInitialize) {
        await initialize();
      }

      if (!_isInitialize) {
        return NotificationPermissionStatus.error;
      }

      if (Platform.isAndroid) {
        final isNotificationEnable = await _checkPermissionGranted();

        return isNotificationEnable
            ? NotificationPermissionStatus.granted
            : NotificationPermissionStatus.denied;
      }

      if (Platform.isIOS) {
        final isNotificationEnable = await _checkPermissionGranted();

        if (isNotificationEnable) {
          return NotificationPermissionStatus.granted;
        }

        if (!isNotificationEnable) {
          return NotificationPermissionStatus.denied;
        }

        return NotificationPermissionStatus.notDetermined;
      }

      return NotificationPermissionStatus.unsupported;
    } catch (e, st) {
      debugPrint("Notification permission error: $e");
      debugPrintStack(stackTrace: st);

      return NotificationPermissionStatus.error;
    }
  }

  //==> request permission
  Future<NotificationPermissionStatus> requestPermission() async {
    try {
      if (!_isInitialize) {
        await initialize();
      }

      if (!_isInitialize) {
        return NotificationPermissionStatus.error;
      }

      final currentStatus = await checkNotificationPermission();

      if (currentStatus == NotificationPermissionStatus.granted) {
        return NotificationPermissionStatus.granted;
      }

      if (Platform.isAndroid) {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        final granted = await androidPlugin?.requestNotificationsPermission();

        debugPrint("Notification Permission: $granted");

        return granted == true
            ? NotificationPermissionStatus.granted
            : NotificationPermissionStatus.denied;
      }

      if (Platform.isIOS) {
        final iosPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

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
      debugPrint("Notification request  error: $e");
      debugPrintStack(stackTrace: st);

      return NotificationPermissionStatus.error;
    }
  }

  //==> open app settings
  Future<bool> openAppSettings() async {
    try {
      if (!_isInitialize) {
        await initialize();
      }

      final opened = await _plugin.openAppNotificationSettings();
      debugPrint("App settings $opened");

      return opened == true;
    } catch (e, st) {
      debugPrint("App settings error while opening: $e");
      debugPrintStack(stackTrace: st);

      return false;
    }
  }

  //==> show notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String description,
    required String payload,
  }) async {
    try {
      debugPrint("Notification showing");

      // await _plugin.cancelAll();

      await _plugin.show(
        id: id,
        title: title,
        body: description,
        notificationDetails: NotificationConfig.notificationDetails,
        payload: payload,
      );

      debugPrint("Notification showed");
    } catch (e, st) {
      debugPrint("Notification showing error: $e");
      debugPrintStack(stackTrace: st);
    }
  }

  //==> granted permission
  Future<bool> _checkPermissionGranted() async {
    try {
      if (!_isInitialize) {
        await initialize();
      }

      if (Platform.isAndroid) {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        final isEnabled = await androidPlugin?.areNotificationsEnabled();

        return isEnabled ?? false;
      }

      if (Platform.isIOS) {
        final iosPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

        final isEnabled = await iosPlugin?.checkPermissions();

        return isEnabled?.isEnabled ?? false;
      }

      return false;
    } catch (e, s) {
      debugPrint("Permission granted error: $e");
      debugPrintStack(stackTrace: s);

      return false;
    }
  }

  //==> launch app via notification while it's terminated
  Future<void> checkForLaunchNotification() async {
    try {
      final notificationDetails = await _plugin
          .getNotificationAppLaunchDetails();

      if (notificationDetails?.didNotificationLaunchApp ?? false) {
        final payload = notificationDetails?.notificationResponse?.payload;
        debugPrint("Notification payload: $payload");
      }
    } catch (e, s) {
      debugPrint("Notification launch error: $e");
      debugPrintStack(stackTrace: s);
    }
  }
}
