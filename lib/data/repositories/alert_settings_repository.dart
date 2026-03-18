import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class AlertSettingsRepository {
  Future<Map<String, dynamic>?> getAlertSettings({
    String? deviceId,
  }) async {
    final userApiHashKey = MySharedPreferences.getString(authTokenKey);
    var url = "${AppUrl.baseURL}${AppUrl.getAlertSettingEp}$userApiHashKey";
    if (deviceId != null && deviceId.isNotEmpty) {
      url = "$url&device_id=$deviceId";
    }
    final headers = {"Content-Type": "application/json"};

    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  Future<List<int>?> syncAlertSettings({
    String? deviceId,
    required List<int> alertIds,
    int? active,
  }) async {
    final userApiHashKey = MySharedPreferences.getString(authTokenKey);
    final idsQuery = alertIds.map((id) => "&alert_ids[]=$id").join();
    final isDeviceSync = deviceId != null && deviceId.isNotEmpty;
    final url = Uri.parse(isDeviceSync
        ? "${AppUrl.baseURL}${AppUrl.syncAlertSettingEp}$userApiHashKey&device_id=$deviceId$idsQuery"
        : "${AppUrl.baseURL}${AppUrl.syncAlertActiveEp}$userApiHashKey$idsQuery&active=${active ?? 1}");
    final headers = {"Content-Type": "application/json"};

    http.Response response = await http.post(url, headers: headers);
    if (response.statusCode != 200) {
      response = await http.get(url, headers: headers);
    }
    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    final ids = decoded["assigned_alert_ids"] ??
        decoded["alert_ids"] ??
        decoded["data"]?["assigned_alert_ids"];
    if (ids is List) {
      return ids
          .map((e) => (e is num) ? e.toInt() : int.tryParse("$e"))
          .whereType<int>()
          .toList();
    }
    if (decoded["status"] == 1 || decoded["success"] == true) {
      return alertIds;
    }
    return <int>[];
  }

  Future<bool> syncAlertAnnouncement({
    required bool enabled,
  }) async {
    final userApiHashKey = MySharedPreferences.getString(authTokenKey).trim();
    if (userApiHashKey.isEmpty) return false;

    final url = Uri.parse(
      "${AppUrl.baseURL}${AppUrl.syncAlertAnnouncementEp}$userApiHashKey&alert_announcement=${enabled ? 1 : 0}",
    );
    final headers = {"Content-Type": "application/json"};

    http.Response response = await http.post(url, headers: headers);
    if (response.statusCode != 200) {
      response = await http.get(url, headers: headers);
    }
    if (response.statusCode != 200) return false;

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return false;
    if (decoded["status"] != 1 && decoded["success"] != true) return false;

    final raw = decoded["alert_announcement"];
    if (raw is num) return raw.toInt() == (enabled ? 1 : 0);
    if (raw is String) {
      final parsed = int.tryParse(raw.trim());
      if (parsed != null) return parsed == (enabled ? 1 : 0);
    }
    return true;
  }
}
