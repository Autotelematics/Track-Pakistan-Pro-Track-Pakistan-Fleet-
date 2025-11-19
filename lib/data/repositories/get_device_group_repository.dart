import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/get_device_group_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class GetDeviceGroupRepository {
  Future<GetDeviceGroupModel?> getDeviceGroupApi({
    required int page,
    required BuildContext dialogContext,
  }) async {
    try {
      // Get Token
      String? userApiHashKey =
      await MySharedPreferences.getString(authTokenKey);

      print("📌 User API Hash Key: $userApiHashKey");

      final headers = {"Content-Type": "application/json"};

      final url = Uri.parse(
          "${AppUrl.baseURL}${AppUrl.getDeviceGroupEp}$userApiHashKey");

      print("🔗 API URL: $url");
      print("📝 Request Headers: $headers");

      final response = await http.get(url, headers: headers);

      log("📥 Status Code: ${response.statusCode}");
      log("📥 Raw Response Body: ${response.body}");

      // Print body for debugging
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // Decode JSON for debugging
        final decoded = jsonDecode(response.body);
        print("✅ Decoded JSON: $decoded");

        return getDeviceGroupModelFromJson(response.body);
      } else {
        final decodedBody = jsonDecode(response.body);
        print("❌ Error Message: ${decodedBody['message']}");
        log("❌ Error Calling API: ${decodedBody['message']}");
        return null;
      }
    } catch (e) {
      print("🔥 Repository Exception: $e");
      log("🔥 Repository Error: $e");
      rethrow;
    }
  }
}
