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
      final userApiHashKey = MySharedPreferences.getString(authTokenKey);
      log("User API Hash Key: $userApiHashKey");

      if (userApiHashKey.isEmpty) {
        log("No auth token found!");
        return null;
      }

      final endpointPath = AppUrl.getDeviceStatusEp.split('?').first;
      final url = Uri.parse('${AppUrl.baseURL}$endpointPath').replace(
        queryParameters: {
          'user_api_hash': userApiHashKey,
        },
      );
      log("Calling API: $url");

      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      log("Response Status Code: ${response.statusCode}");
      log("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        log("API Success - Parsing model...");
        return getDeviceStatusModelFromJson(response.body);
      } else {
        Map<String, dynamic> decodedBody = jsonDecode(response.body);
        log("API Error: ${decodedBody['message'] ?? 'Unknown error'}");
        return null;
      }
    } catch (e) {
      log("Exception in getDeviceStatusApi: $e");
      log("Exception: $e");
      return null;
    }
  }
}
