import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/get_device_list_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class VehicleRepository {
  Future<GetDevicesListModel?> fetchVehicleData({
    BuildContext? dialogContext,
  }) async {
    try {
      final userApiHashKey = MySharedPreferences.getString(authTokenKey);
      final headers = {"Content-Type": "application/json"};
      final endpointPath = AppUrl.getDeviceListEp.split('?').first;
      final url = Uri.parse('${AppUrl.baseURL}$endpointPath').replace(
        queryParameters: {
          "user_api_hash": userApiHashKey,
        },
      );

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is Map<String, dynamic>) {
          return getDevicesListModelFromJson(response.body);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        final decodedBody = jsonDecode(response.body);
        log("API Error: ${decodedBody['message']}");
        return null;
      }
    } on SocketException catch (e) {
      log(
        "Repository DNS/Network Error: ${e.message}. URL: ${AppUrl.baseURL}",
      );
      rethrow;
    } catch (e) {
      log("Repository Error: $e");
      rethrow;
    }
  }
}
