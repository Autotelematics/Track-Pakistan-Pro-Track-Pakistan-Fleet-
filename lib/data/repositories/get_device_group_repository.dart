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
      final token = MySharedPreferences.getString(authTokenKey);

      final url =
          Uri.parse('${AppUrl.baseURL}${AppUrl.getDeviceGroupEp}$token');
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
          log('API Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        return getDeviceGroupModelFromJson(response.body);
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Unknown error';
        log('API Error: $error');
        return null;
      }
    } catch (e) {
      log('Repository Error: $e');
      rethrow;
    }
  }
}
