import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notification_handling/core/services/notification/app_navigation_type.dart';
import 'package:notification_handling/core/services/notification/notification_payload.dart';
import 'package:notification_handling/features/message/screens/message_screen.dart';

class NotificationNavigation {
  NotificationNavigation._();

  static final GlobalKey<NavigatorState> navigationKey =
      GlobalKey<NavigatorState>();

  static void handleNotificationNavigations(String rawResponse) {
    final payload = NotificationPayload.decode(rawResponse);

    final navigator = navigationKey.currentState;
    if (navigator == null) {
      debugPrint("Navigator is not ready");
      return;
    }

    switch (payload.applicationType) {
      case AppNavigationType.message:
        if (payload.id == null) return;
        navigator.push(
          MaterialPageRoute(
            builder: (context) => MessageScreen(messageId: payload.id),
          ),
        );
        break;

      case AppNavigationType.order:
        debugPrint("Order page navigating");
        break;

      case AppNavigationType.payment:
        debugPrint("Payment page navigating");
        break;

      case AppNavigationType.promotion:
        debugPrint("Promotion page navigating");
        break;

      case AppNavigationType.unknown:
        debugPrint("Unknown page navigating");
        break;
    }
  }
}
