import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationConfig {
  NotificationConfig._();

  //==> channel setup
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    "general.notification.service",
    "General Notification Service",
    description: "General notification service is for just testing purpose",
    importance: Importance.high,
  );

  //==> android settings
  static const AndroidInitializationSettings android =
      AndroidInitializationSettings("@mipmap/ic_launcher");

  //==> ios settings
  static const DarwinInitializationSettings ios = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  //==> initialization settings
  static const InitializationSettings initializationSettings =
      InitializationSettings(android: android, iOS: ios);
}
