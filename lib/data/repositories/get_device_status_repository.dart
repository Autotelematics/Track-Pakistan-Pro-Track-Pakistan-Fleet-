// repository/get_device_status_repository.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/get_device_status_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class GetDeviceStatusRepository {
  Future<GetDeviceStatusModel?> getDeviceStatusApi({
    BuildContext? dialogContext,
  }) async {
    try {
      String? userApiHashKey = MySharedPreferences.getString(authTokenKey);
      print("User API Hash Key: $userApiHashKey");

      if (userApiHashKey.isEmpty) {
        print("No auth token found!");
        return null;
      }

      final url = Uri.parse(
          "${AppUrl.baseURL}${AppUrl.getDeviceStatusEp}$userApiHashKey");
      print("Calling API: $url");

      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("API Success - Parsing model...");
        return getDeviceStatusModelFromJson(response.body);
      } else {
        Map<String, dynamic> decodedBody = jsonDecode(response.body);
        print("API Error: ${decodedBody['message'] ?? 'Unknown error'}");
        return null;
      }
    } catch (e) {
      print("Exception in getDeviceStatusApi: $e");
      log("Exception: $e");
      return null;
    }
  }
}
