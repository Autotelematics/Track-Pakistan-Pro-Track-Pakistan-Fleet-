import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/get_device_live_tracking_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class GetDeviceLiveTrackingRepository {
  Future<GetDeviceLiveTrackingModel?> getDeviceLiveTrackingApi({
    required int deviceId,
  }) async {
    String? userApiHashKey =  MySharedPreferences.getString(authTokenKey);
    final headers = {"Content-Type": "application/json"};
    final url = Uri.parse(
        "${AppUrl.baseURL}${AppUrl.getDeviceLiveTrackingEp}$userApiHashKey&id=$deviceId");
    http.Response response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      return getDeviceLiveTrackingModelFromJson(response.body);
    } else {
      Map<String, dynamic> decodedBody = jsonDecode(response.body);
      log("Error Calling Api :${decodedBody['message']}");
      return null;
    }
  }
}