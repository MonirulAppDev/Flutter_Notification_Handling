import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:notification_handling/core/services/notification/app_navigation_type.dart';

class NotificationPayload {
  const NotificationPayload({required this.applicationType, this.id});

  final AppNavigationType applicationType;
  final String? id;

  Map<String, dynamic> toJson() {
    return {"type": applicationType.name, "id": id};
  }

  String encode() => jsonEncode(toJson());

  factory NotificationPayload.decode(String? payload) {
    if (payload == null || payload.isEmpty) {
      return NotificationPayload(applicationType: AppNavigationType.unknown);
    }

    try {
      final json = jsonDecode(payload);
      final typeName = json["type"] as String;
      final type = AppNavigationType.values.firstWhere(
        (element) => element.name == typeName,
        orElse: () => AppNavigationType.unknown,
      );

      return NotificationPayload(applicationType: type, id: json["id"]);
    } catch (e, s) {
      debugPrint("Payload decode error: $e");
      debugPrintStack(stackTrace: s);

      return NotificationPayload(applicationType: AppNavigationType.unknown);
    }
  }
}
