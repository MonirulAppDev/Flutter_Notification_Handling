import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:notification_handling/core/services/notification/app_navigation_type.dart';
import 'package:notification_handling/core/services/notification/notification_payload.dart';
import 'package:notification_handling/core/services/notification/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationService _notificationService = NotificationService.instance;
  bool _hasPermission = false;
  bool _isCheckingPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    setState(() => _isCheckingPermission = true);
    try {
      final isGranted = await _notificationService.hasPermission();
      if (mounted) {
        setState(() {
          _hasPermission = isGranted;
          _isCheckingPermission = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isCheckingPermission = false);
      }
    }
  }

  Future<bool> _ensureNotificationPermission() async {
    bool isGranted = await _notificationService.hasPermission();

    if (!isGranted) {
      log("Notification Permission not granted, requesting...");
      await _notificationService.requestPermission();
      isGranted = await _notificationService.hasPermission();

      if (mounted) {
        setState(() => _hasPermission = isGranted);
      }

      if (!isGranted) {
        log("Permission permanently denied or rejected. Opening app settings...");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Notification permission is required to receive notifications.",
              ),
              action: SnackBarAction(
                label: "Settings",
                onPressed: () => _notificationService.openAppSettings(),
              ),
            ),
          );
        }
        return false;
      }
    }

    if (mounted && !_hasPermission) {
      setState(() => _hasPermission = true);
    }
    return true;
  }

  Future<void> _sendTestNotification({
    required int id,
    required String title,
    required String description,
    required AppNavigationType type,
    String? payloadId,
  }) async {
    if (!await _ensureNotificationPermission()) return;

    final payload = NotificationPayload(
      applicationType: type,
      id: payloadId,
    ).encode();

    await _notificationService.showNotification(
      id: id,
      title: title,
      description: description,
      payload: payload,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Triggered ${type.name.toUpperCase()} notification!"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Demo"),
        elevation: 2,
        actions: [
          IconButton(
            tooltip: "Refresh Permission Status",
            icon: _isCheckingPermission
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _checkPermissionStatus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _notificationService.isInitialized
                              ? Icons.check_circle_rounded
                              : Icons.error_outline_rounded,
                          color: _notificationService.isInitialized
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _notificationService.isInitialized
                                ? "Notification Initialized"
                                : "Notification Not Initialized",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Icon(
                          _hasPermission
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_off_rounded,
                          color: _hasPermission ? Colors.blue : Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _hasPermission
                                ? "Permission: Granted"
                                : "Permission: Not Granted",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        if (!_hasPermission)
                          TextButton(
                            onPressed: _ensureNotificationPermission,
                            child: const Text("Request"),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section Header
            Text(
              "Notification Types Test Panel",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              "Click any button below to trigger and test that notification type.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 16),

            // Message Notification Button
            _NotificationTypeCard(
              title: "Message Notification",
              subtitle: "Route: MessageScreen | ID: 102",
              icon: Icons.chat_rounded,
              color: Colors.blue,
              buttonText: "Nav Notification (Message Screen)",
              onPressed: () => _sendTestNotification(
                id: 1,
                title: "New Message Alert",
                description: "Tap to open Message Screen",
                type: AppNavigationType.message,
                payloadId: "102",
              ),
            ),
            const SizedBox(height: 12),

            // Order Notification Button
            _NotificationTypeCard(
              title: "Order Notification",
              subtitle: "Route: OrderScreen | ID: ORD-9421",
              icon: Icons.shopping_bag_rounded,
              color: Colors.green,
              buttonText: "Test Order Notification",
              onPressed: () => _sendTestNotification(
                id: 2,
                title: "Order Update",
                description: "Your order #ORD-9421 has been shipped! Tap to view.",
                type: AppNavigationType.order,
                payloadId: "ORD-9421",
              ),
            ),
            const SizedBox(height: 12),

            // Payment Notification Button
            _NotificationTypeCard(
              title: "Payment Notification",
              subtitle: "Route: PaymentScreen | ID: PAY-7705",
              icon: Icons.payment_rounded,
              color: Colors.purple,
              buttonText: "Test Payment Notification",
              onPressed: () => _sendTestNotification(
                id: 3,
                title: "Payment Received",
                description: "Payment of \$75.00 for #PAY-7705 was successful.",
                type: AppNavigationType.payment,
                payloadId: "PAY-7705",
              ),
            ),
            const SizedBox(height: 12),

            // Promotion Notification Button
            _NotificationTypeCard(
              title: "Promotion Notification",
              subtitle: "Route: PromotionScreen | ID: PROMO-50",
              icon: Icons.local_offer_rounded,
              color: Colors.deepOrange,
              buttonText: "Test Promotion Notification",
              onPressed: () => _sendTestNotification(
                id: 4,
                title: "Flash Sale 50% Off!",
                description: "Use code PROMO-50 for half price! Tap to explore.",
                type: AppNavigationType.promotion,
                payloadId: "PROMO-50",
              ),
            ),
            const SizedBox(height: 12),

            // Unknown / General Notification Button
            _NotificationTypeCard(
              title: "General / Unknown Notification",
              subtitle: "Route: Fallback (SnackBar) | ID: SYS-99",
              icon: Icons.notifications_rounded,
              color: Colors.teal,
              buttonText: "Test Notification",
              onPressed: () => _sendTestNotification(
                id: 5,
                title: "General System Alert",
                description: "This is a test notification for unknown navigation.",
                type: AppNavigationType.unknown,
                payloadId: "SYS-99",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTypeCard extends StatelessWidget {
  const _NotificationTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.buttonText,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  foregroundColor: color,
                  radius: 20,
                  child: Icon(icon, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.withValues(alpha: 0.1),
                  foregroundColor: color,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: color.withValues(alpha: 0.3)),
                  ),
                ),
                onPressed: onPressed,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
