import 'package:flutter/material.dart';
import 'package:notification_handling/core/services/notification/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    NotificationService.instance.initialize();
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
          ],
        ),
      ),
    );
  }
}
