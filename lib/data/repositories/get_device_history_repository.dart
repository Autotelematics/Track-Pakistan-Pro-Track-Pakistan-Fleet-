import 'dart:convert';
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
      print("========== DEVICE HISTORY API START ==========");

      final token = MySharedPreferences.getString(authTokenKey);
      print("TOKEN: $token");

      final url = Uri.parse(
        '${AppUrl.baseURL}${AppUrl.getDeviceHistoryEp}'
            '$token'
            '&device_id=$deviceId'
            '&from_date=$fromDate'
            '&from_time=$fromTime'
            '&to_date=$toDate'
            '&to_time=$toTime'
            '&snap_to_road=1',
      );

      print("REQUEST URL:");
      print(url.toString());

      print("PARAMS:");
      print("device_id: $deviceId");
      print("from_date: $fromDate");
      print("from_time: $fromTime");
      print("to_date: $toDate");
      print("to_time: $toTime");
      print("snap_to_road: $snapToRoad");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
        },
      );

      print("STATUS CODE: ${response.statusCode}");

      print("RAW RESPONSE:");
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("DECODED JSON:");
        print(data);

        print("========== DEVICE HISTORY API SUCCESS ==========");

        return GetDeviceHistoryModel.fromJson(data);
      } else {
        print("========== API FAILED ==========");
        throw Exception(
            "Failed to load device history: ${response.statusCode}");
      }

    } catch (e, stack) {
      print("========== API ERROR ==========");
      print("ERROR: $e");
      print("STACKTRACE: $stack");
      throw Exception("API Error: $e");
    }
  }
}
