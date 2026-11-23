import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_handling/core/services/notification/notification_navigation.dart';
import 'package:notification_handling/core/services/notification/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
NotificationResponse? pendingResponse;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final NotificationService notificationService = NotificationService.instance;

  try {
    await notificationService.initialize();
    await notificationService.checkForLaunchNotification();

    final launchDetails = await notificationService
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      pendingResponse = launchDetails?.notificationResponse;
    }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final response = pendingResponse?.payload;
      if (response != null) {
        pendingResponse = null;
        NotificationNavigation.handleNotificationNavigations(response);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NotificationService notificationService = NotificationService.instance;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                notificationService.isInitialize
                    ? "Notification Initialized"
                    : "Notification Not Initialized",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              //==> pressed on notification
              onPressed: () async {
                bool isNotificationGranted = await notificationService
                    .hasPermission();

                if (!isNotificationGranted) {
                  log("Notification Denied");

                  await notificationService.requestPermission();

                  isNotificationGranted = await notificationService
                      .hasPermission();

                  if (!isNotificationGranted) {
                    notificationService.openAppSettings();
                    return;
                  }
                }

                log("Notification Granted");
                debugPrint("Notification showing called");

                await notificationService.showNotification(
                  id: 1,
                  title: "Hello",
                  description: "This is a test notification",
                  payload: "This is notification payload!",
                );
              },

              //==> button text
              child: Text("Test Notification"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              //==> pressed on notification
              onPressed: () async {
                bool isNotificationGranted = await notificationService
                    .hasPermission();

                if (!isNotificationGranted) {
                  log("Notification Denied");

                  await notificationService.requestPermission();

                  isNotificationGranted = await notificationService
                      .hasPermission();

                  if (!isNotificationGranted) {
                    notificationService.openAppSettings();
                    return;
                  }
                }

                log("Notification Granted");
                debugPrint("Notification showing called");

                await notificationService.showNotification(
                  id: 2,
                  title: "Hello Android",
                  description: "This is a nav notification",
                  payload: "message 102",
                );
              },

              //==> button text
              child: Text("Nav Notification"),
            ),
          ],
        ),
      ),
    );
  }
}
