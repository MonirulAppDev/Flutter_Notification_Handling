import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:notification_handling/core/services/notification/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationService.instance.initialize();
  } catch (e, st) {
    debugPrint("Notification service initialization error: $e");
    debugPrintStack(stackTrace: st);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationService notificationService = NotificationService.instance;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
                bool isNotificationGranted =
                    await notificationService.hasPermission();

                if (!isNotificationGranted) {
                  log("Notification Denied");

                  await notificationService.requestPermission();

                  isNotificationGranted =
                      await notificationService.hasPermission();

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
                );
              },

              //==> button text
              child: Text("Test Notification"),
            ),
          ],
        ),
      ),
    );
  }
}
