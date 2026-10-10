import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';

import 'package:trackerapp/data/models/get_device_commands_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import "package:http/http.dart" as http;

class GetDeviceCommandsRepository {
  //Get Device Commands
  Future<List<GetDeviceCommandsModel>?> getDeviceCommands(
      {required String deviceId})
  async {
    final userAuthToken = MySharedPreferences.getString(authTokenKey);
    final endpointPath = AppUrl.getDeviceCommandsEp.split('?').first;
    final url = Uri.parse('${AppUrl.baseURL}$endpointPath').replace(
      queryParameters: {
        'user_api_hash': userAuthToken,
        'device_id': deviceId,
      },
    );
    final headers = {"Content-Type": "application/json"};
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return getDeviceCommandsModelFromJson(response.body);
    } else {
      return null;
    }
  }

  //Send Device Commands
  Future<void> sendDeviceCommands({required String deviceId, commandType}) async {
    final userAuthToken = MySharedPreferences.getString(authTokenKey);
    final endpointPath = AppUrl.sendDeviceCommandsEp.split('?').first;
    final url = Uri.parse('${AppUrl.baseURL}$endpointPath').replace(
      queryParameters: {
        'user_api_hash': userAuthToken,
        'device_id': deviceId,
        'type': '$commandType',
      },
    );
    final headers = {"Content-Type": "application/json"};
    final response = await http.post(url, headers: headers);

    // Print API response to log & debug console
    log("Send Command Endpoint: $url");
    log("Send Command StatusCode: ${response.statusCode}");
    log("Send Command Body: ${response.body}");
    debugPrint("Send Command Response [${response.statusCode}]: ${response.body}");

    Map<String, dynamic>? decoded;
    try {
      final parsed = jsonDecode(response.body);
      if (parsed is Map<String, dynamic>) {
        decoded = parsed;
      }
    } catch (_) {}

    // Evaluate success based on HTTP status code AND API response payload (e.g. status == 1 or true)
    bool isApiSuccess = false;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded != null) {
        if (decoded.containsKey("status")) {
          final statusVal = decoded["status"];
          isApiSuccess = statusVal == 1 || statusVal == true || statusVal == "1";
        } else if (decoded.containsKey("success")) {
          final successVal = decoded["success"];
          isApiSuccess = successVal == true || successVal == 1 || successVal == "1";
        } else {
          isApiSuccess = true;
        }
      } else {
        isApiSuccess = true;
      }
    }

    String serverMsg = "";
    if (decoded != null) {
      serverMsg = (decoded["message"] ?? decoded["error"] ?? decoded["success"] ?? "").toString().trim();
    }

    if (isApiSuccess) {
      final msg = serverMsg.isNotEmpty ? serverMsg : "Command sent successfully";
      AppSnackBar.success(message: msg);
    } else {
      final msg = serverMsg.isNotEmpty ? serverMsg : "Failed to send command";
      AppSnackBar.error(message: msg);
    }
  }
}
