import 'package:flutter/material.dart';
import 'package:notification_handling/core/services/notification/app_navigation_type.dart';
import 'package:notification_handling/core/services/notification/notification_payload.dart';
import 'package:notification_handling/features/message/screens/message_screen.dart';
import 'package:notification_handling/features/order/screens/order_screen.dart';
import 'package:notification_handling/features/payment/screens/payment_screen.dart';
import 'package:notification_handling/features/promotion/screens/promotion_screen.dart';

class NotificationNavigation {
  NotificationNavigation._();

  /// Central navigation key to be set on MaterialApp.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Backward-compatible alias
  static GlobalKey<NavigatorState> get navigationKey => navigatorKey;

  /// Handles routing based on raw notification payload.
  static void handleNotificationNavigations(String? rawResponse) {
    if (rawResponse == null || rawResponse.isEmpty) return;

    final payload = NotificationPayload.decode(rawResponse);
    final navigator = navigatorKey.currentState;

    if (navigator == null) {
      debugPrint("NotificationNavigation: NavigatorState is not ready.");
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
        debugPrint("Order page navigating (id: ${payload.id})");
        navigator.push(
          MaterialPageRoute(
            builder: (context) => OrderScreen(orderId: payload.id),
          ),
        );
        break;

      case AppNavigationType.payment:
        debugPrint("Payment page navigating (id: ${payload.id})");
        navigator.push(
          MaterialPageRoute(
            builder: (context) => PaymentScreen(paymentId: payload.id),
          ),
        );
        break;

      case AppNavigationType.promotion:
        debugPrint("Promotion page navigating (id: ${payload.id})");
        navigator.push(
          MaterialPageRoute(
            builder: (context) => PromotionScreen(promotionId: payload.id),
          ),
        );
        break;

      case AppNavigationType.unknown:
        debugPrint("Unknown navigation type for payload: $rawResponse");
        final context = navigatorKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Unknown / General notification clicked: ${payload.id ?? 'No ID'}",
              ),
            ),
          );
        }
        break;
    }
  }
}
