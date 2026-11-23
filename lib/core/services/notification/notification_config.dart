import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationConfig {
  NotificationConfig._();

  //==> variables
  static const String _channelId = "general.notification.service";

  static const String _channelName = "General Notification Service";

  static const String _description =
      "General notification service is for just testing purpose";

  //==> notification android channel setup
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _description,
    importance: Importance.high,
  );

  //==> android settings
  static const AndroidInitializationSettings _android =
      AndroidInitializationSettings("@mipmap/ic_launcher");

  //==> ios settings
  static const DarwinInitializationSettings _ios = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  //==> initialization settings
  static const InitializationSettings initializationSettings =
      InitializationSettings(android: _android, iOS: _ios);

  //==> android notification details
  static const AndroidNotificationDetails _androidNotificationDetails =
      AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _description,
        importance: Importance.high,
        priority: Priority.max,
        playSound: true,
      );

  //==> ios notification details details
  static const DarwinNotificationDetails _iosNotificationDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

  //==> notification details
  static const NotificationDetails notificationDetails = NotificationDetails(
    android: _androidNotificationDetails,
    iOS: _iosNotificationDetails,
  );
}
