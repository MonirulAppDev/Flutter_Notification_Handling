import 'package:flutter/material.dart';
import 'package:notification_handling/core/services/notification/notification_navigation.dart';
import 'package:notification_handling/core/services/notification/notification_service.dart';
import 'package:notification_handling/features/home/screens/home_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Notification Demo",
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationNavigation.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
