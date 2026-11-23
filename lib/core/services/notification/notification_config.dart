import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification configuration setup for Android and iOS.
class NotificationConfig {
  NotificationConfig._();

  static const String channelId = "general.notification.service";
  static const String channelName = "General Notification Service";
  static const String channelDescription =
      "General notification service for app alerts and updates";

  /// Android notification channel setup
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.high,
  );

  /// Android initialization settings
  static const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings("@mipmap/ic_launcher");

  /// iOS initialization settings
  static const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  /// Combined initialization settings
  static const InitializationSettings initializationSettings =
      InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  /// Android notification details
  static const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    importance: Importance.high,
    priority: Priority.max,
    playSound: true,
  );

  /// iOS notification details
  static const DarwinNotificationDetails iosNotificationDetails =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  /// Combined notification details
  static const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
    iOS: iosNotificationDetails,
  );
}
