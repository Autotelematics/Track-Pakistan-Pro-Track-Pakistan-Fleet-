import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/get_device_history_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class GetDeviceHistoryRepository {

  Future<GetDeviceHistoryModel> getDeviceHistoryApi({
    required String deviceId,
    required String fromDate,
    required String fromTime,
    required String toDate,
    required String toTime,
    required bool snapToRoad,
  }) async {

    try {
      log("========== DEVICE HISTORY API START ==========");

      final token = MySharedPreferences.getString(authTokenKey);
      log("TOKEN: $token");

      final endpointPath = AppUrl.getDeviceHistoryEp.split('?').first;
      final url = Uri.parse('${AppUrl.baseURL}$endpointPath').replace(
        queryParameters: {
          'user_api_hash': token,
          'device_id': deviceId,
          'from_date': fromDate,
          'from_time': fromTime,
          'to_date': toDate,
          'to_time': toTime,
          'snap_to_road': snapToRoad ? '1' : '0',
        },
      );

      log("REQUEST URL:");
      log(url.toString());

      log("PARAMS:");
      log("device_id: $deviceId");
      log("from_date: $fromDate");
      log("from_time: $fromTime");
      log("to_date: $toDate");
      log("to_time: $toTime");
      log("snap_to_road: $snapToRoad");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
        },
      );

      log("STATUS CODE: ${response.statusCode}");

      log("RAW RESPONSE:");
      log(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        log("DECODED JSON:");
        log(data.toString());

        log("========== DEVICE HISTORY API SUCCESS ==========");

        return GetDeviceHistoryModel.fromJson(data);
      } else {
        log("========== API FAILED ==========");
        throw Exception(
            "Failed to load device history: ${response.statusCode}");
      }

    } catch (e, stack) {
      log("========== API ERROR ==========");
      log("ERROR: $e");
      log("STACKTRACE: $stack");
      throw Exception("API Error: $e");
    }
  }
}
