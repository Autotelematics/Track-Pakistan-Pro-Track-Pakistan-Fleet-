import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trackerapp/res/app_endpoints.dart';

class AdminPushNotificationRepository {
  Future<List<AdminUserWithTokensItem>> getAdminUsersWithTokens({
    required String token,
  }) async {
    final endpointPath = AppUrl.getAdminUsersWithTokensEp.split('?').first;
    final url = Uri.parse('${AppUrl.baseURL}$endpointPath').replace(
      queryParameters: {
        'user_api_hash': token,
      },
    );
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode != 200) return const [];

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return const [];
    if (_toInt(decoded["status"]) != 1) return const [];
    final items = decoded["items"];
    if (items is! List) return const [];

    return items
        .whereType<Map<String, dynamic>>()
        .map(AdminUserWithTokensItem.fromJson)
        .toList(growable: false);
  }

  Future<AdminPushNotificationResult> sendPushNotification({
    required String token,
    required String title,
    required String body,
    required int sendToAll,
    String? targetUserId,
    List<int>? targetUserIds,
    String? fcmToken,
    String priority = "10",
    String? sound,
    String? data,
    required int scheduleEnabled,
    String? scheduleType,
    String? dailyTime,
    String? weeklyDay,
    String? weeklyTime,
    String? monthlyDay,
    String? monthlyTime,
    String? yearlyMonth,
    String? yearlyDay,
    String? yearlyTime,
    String? customDate,
    String? customTime,
  }) async {
    final query = <String, String>{
      "title": title,
      "body": body,
      "send_to_all": sendToAll.toString(),
      "priority": priority,
      "schedule_enabled": scheduleEnabled.toString(),
      "user_api_hash": token,
    };
    final userId = (targetUserId ?? "").trim();
    if (userId.isNotEmpty) {
      query["target_user_id"] = userId;
    }
    final ids = (targetUserIds ?? const <int>[])
        .where((id) => id > 0)
        .toList(growable: false);
    if (ids.isNotEmpty) {
      query["target_user_ids"] = jsonEncode(ids);
    }
    final tokenInput = (fcmToken ?? "").trim();
    if (tokenInput.isNotEmpty) {
      query["fcm_token"] = tokenInput;
    }
    final customSound = (sound ?? "").trim();
    if (customSound.isNotEmpty) {
      query["sound"] = customSound;
    }
    final extraData = (data ?? "").trim();
    if (extraData.isNotEmpty) {
      query["data"] = extraData;
    }
    if (scheduleEnabled == 1) {
      final type = (scheduleType ?? "").trim();
      if (type.isNotEmpty) {
        query["schedule_type"] = type;
      }
      void addIfNotEmpty(String key, String? value) {
        final v = (value ?? "").trim();
        if (v.isNotEmpty) query[key] = v;
      }

      addIfNotEmpty("daily_time", dailyTime);
      addIfNotEmpty("weekly_day", weeklyDay);
      addIfNotEmpty("weekly_time", weeklyTime);
      addIfNotEmpty("monthly_day", monthlyDay);
      addIfNotEmpty("monthly_time", monthlyTime);
      addIfNotEmpty("yearly_month", yearlyMonth);
      addIfNotEmpty("yearly_day", yearlyDay);
      addIfNotEmpty("yearly_time", yearlyTime);
      addIfNotEmpty("custom_date", customDate);
      addIfNotEmpty("custom_time", customTime);
    }

    final url = Uri.parse("${AppUrl.baseURL}${AppUrl.sendPushNotificationEp}")
        .replace(queryParameters: query);

    final response = await http.post(url);
    if (response.statusCode != 200) {
      return const AdminPushNotificationResult(
        success: false,
        message: "Failed to send notification.",
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return const AdminPushNotificationResult(
        success: false,
        message: "Invalid server response.",
      );
    }

    final ok = _toInt(decoded["status"]) == 1;
    final message = (decoded["message"] ?? "").toString().trim();
    return AdminPushNotificationResult(
      success: ok,
      message: message.isEmpty
          ? (ok
              ? "Notification sent successfully."
              : "Failed to send notification.")
          : message,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? "") ?? 0;
  }
}

class AdminPushNotificationResult {
  final bool success;
  final String message;

  const AdminPushNotificationResult({
    required this.success,
    required this.message,
  });
}

class AdminUserWithTokensItem {
  final int userId;
  final String userEmail;
  final int activeStatus;
  final List<String> fcmTokens;

  const AdminUserWithTokensItem({
    required this.userId,
    required this.userEmail,
    required this.activeStatus,
    required this.fcmTokens,
  });

  factory AdminUserWithTokensItem.fromJson(Map<String, dynamic> json) {
    final tokens = json["fcm_token"];
    return AdminUserWithTokensItem(
      userId: _parseInt(json["user_id"]),
      userEmail: (json["user_email"] ?? "").toString(),
      activeStatus: _parseInt(json["active_status"]),
      fcmTokens: tokens is List
          ? tokens.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList()
          : const [],
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? "") ?? 0;
  }
}
