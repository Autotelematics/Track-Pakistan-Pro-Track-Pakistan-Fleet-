import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/get_device_live_tracking_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/session_guard.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class GetDeviceLiveTrackingRepository {
  Future<GetDeviceLiveTrackingModel?> getDeviceLiveTrackingApi({
    required int deviceId,
  }) async {
    final userApiHashKey = MySharedPreferences.getString(authTokenKey);
    if (userApiHashKey.trim().isEmpty) {
      throw const SessionExpiredException();
    }
    final headers = {"Content-Type": "application/json"};
    final endpointPath = AppUrl.getDeviceLiveTrackingEp.split('?').first;
    final url = Uri.parse('${AppUrl.baseURL}$endpointPath').replace(
      queryParameters: {
        'user_api_hash': userApiHashKey,
        'id': deviceId.toString(),
      },
    );
    http.Response response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      return getDeviceLiveTrackingModelFromJson(response.body);
    } else {
      Map<String, dynamic> decodedBody = jsonDecode(response.body);
      final message = (decodedBody['message'] ?? decodedBody['error'] ?? '')
          .toString()
          .trim();
      log("Error Calling Api :$message");
      if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          SessionGuard.looksLikeSessionExpiredMessage(message)) {
        throw SessionExpiredException(
          message.isEmpty
              ? 'Session expired. Please login again.'
              : message,
        );
      }
      return null;
    }
  }
}
