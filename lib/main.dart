import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:notification_handling/core/services/notification/app_navigation_type.dart';
import 'package:notification_handling/core/services/notification/notification_navigation.dart';
import 'package:notification_handling/core/services/notification/notification_payload.dart';
import 'package:notification_handling/core/services/notification/notification_service.dart';

String? pendingPayload;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService.instance;

  try {
    await notificationService.initialize();
    pendingPayload = await notificationService.getLaunchPayload();
  } catch (e, st) {
    debugPrint("Notification service initialization error: $e");
    debugPrintStack(stackTrace: st);
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pendingPayload != null) {
        final payload = pendingPayload;
        pendingPayload = null;
        NotificationNavigation.handleNotificationNavigations(payload);
      }
    });
  }

  /// Reusable helper to verify and request notification permissions
  Future<bool> _ensureNotificationPermission() async {
    final service = NotificationService.instance;
    bool isGranted = await service.hasPermission();

    if (!isGranted) {
      log("Notification Permission not granted, requesting...");
      await service.requestPermission();
      isGranted = await service.hasPermission();

      if (!isGranted) {
        log("Permission permanently denied or rejected. Opening app settings...");
        await service.openAppSettings();
        return false;
      }
    }

    log("Notification Permission Granted");
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService.instance;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationNavigation.navigatorKey,
      home: Scaffold(
        appBar: AppBar(title: const Text("Notification Demo")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                notificationService.isInitialized
                    ? "Notification Initialized"
                    : "Notification Not Initialized",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!await _ensureNotificationPermission()) return;

                  await notificationService.showNotification(
                    id: 1,
                    title: "Hello",
                    description: "This is a test notification",
                    payload: const NotificationPayload(
                      applicationType: AppNavigationType.unknown,
                    ).encode(),
                  );
                },
                child: const Text("Test Notification"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (!await _ensureNotificationPermission()) return;

                  await notificationService.showNotification(
                    id: 2,
                    title: "New Message Alert",
                    description: "Tap to open Message Screen",
                    payload: const NotificationPayload(
                      applicationType: AppNavigationType.message,
                      id: "102",
                    ).encode(),
                  );
                },
                child: const Text("Nav Notification (Message Screen)"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
