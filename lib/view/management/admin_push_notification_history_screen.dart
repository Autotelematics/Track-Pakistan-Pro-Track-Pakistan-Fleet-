import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class AdminPushNotificationHistoryScreen extends StatefulWidget {
  const AdminPushNotificationHistoryScreen({super.key});

  @override
  State<AdminPushNotificationHistoryScreen> createState() =>
      _AdminPushNotificationHistoryScreenState();
}

class _AdminPushNotificationHistoryScreenState
    extends State<AdminPushNotificationHistoryScreen> {
  List<Map<String, dynamic>> _history = const [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final raw =
        MySharedPreferences.getStringList(adminPushNotificationHistoryKey);
    final parsed = <Map<String, dynamic>>[];
    for (final row in raw) {
      try {
        final decoded = jsonDecode(row);
        if (decoded is Map<String, dynamic>) parsed.add(decoded);
      } catch (_) {}
    }
    setState(() {
      _history = parsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Previously Sent")),
      body: _history.isEmpty
          ? Center(
              child: Text(
                "No previous notifications found.",
                style: AppStyles.regularTextStyle(context),
              ),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 1.8.h),
              children: _history.map((item) {
                final sentAt = (item["sent_at"] ?? "-").toString();
                final title = (item["title"] ?? "-").toString();
                final body = (item["body"] ?? "-").toString();
                final token = (item["fcm_token"] ?? "-").toString();
                final priority = (item["priority"] ?? "10").toString();
                final sound = (item["sound"] ?? "default").toString();
                final data = (item["data"] ?? "").toString();
                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: .15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Sent At: $sentAt"),
                      Text("Title: $title"),
                      Text("Body: $body"),
                      Text(
                        "FCM Token: $token",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text("Priority: $priority"),
                      Text("Sound: $sound"),
                      Text("Data: ${data.isEmpty ? '-' : data}"),
                    ],
                  ),
                );
              }).toList(growable: false),
            ),
    );
  }
}
