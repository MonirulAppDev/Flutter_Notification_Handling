import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:notification_handling/core/services/notification/app_navigation_type.dart';

/// Notification Payload model for handling navigation and custom payload data.
class NotificationPayload {
  const NotificationPayload({required this.applicationType, this.id});

  final AppNavigationType applicationType;
  final String? id;

  Map<String, dynamic> toJson() {
    return {
      "type": applicationType.name,
      if (id != null) "id": id,
    };
  }

  String encode() => jsonEncode(toJson());

  factory NotificationPayload.decode(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return const NotificationPayload(
        applicationType: AppNavigationType.unknown,
      );
    }

    try {
      final json = jsonDecode(payload);
      if (json is Map<String, dynamic>) {
        final typeName = json["type"] as String?;
        final type = AppNavigationType.values.firstWhere(
          (element) => element.name.toLowerCase() == typeName?.toLowerCase(),
          orElse: () => AppNavigationType.unknown,
        );

        return NotificationPayload(
          applicationType: type,
          id: json["id"]?.toString(),
        );
      }
    } catch (_) {
      // Fallback: If not valid JSON, check if payload contains type or keyword (e.g. "message 102")
      final parts = payload.trim().split(RegExp(r'\s+|:'));
      if (parts.isNotEmpty) {
        final matchedType = AppNavigationType.values.firstWhere(
          (e) => e.name.toLowerCase() == parts.first.toLowerCase(),
          orElse: () => AppNavigationType.unknown,
        );
        if (matchedType != AppNavigationType.unknown) {
          final id = parts.length > 1 ? parts.sublist(1).join(' ').trim() : null;
          return NotificationPayload(applicationType: matchedType, id: id);
        }
      }
      debugPrint("Payload could not be parsed as JSON: $payload");
    }

    return const NotificationPayload(
      applicationType: AppNavigationType.unknown,
    );
  }

  @override
  String toString() =>
      'NotificationPayload(type: ${applicationType.name}, id: $id)';
}
