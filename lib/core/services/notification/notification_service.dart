import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_handling/core/services/notification/notification_config.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialize = false;

  bool get isInitialize => _isInitialize;

  Future<void> initialize() async {
    if (_isInitialize) {
      debugPrint("Notification service is already initialized");
      return;
    }

    debugPrint("Notification service initializing");

    try {
      await _plugin.initialize(
        settings: NotificationConfig.initializationSettings,
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
}
