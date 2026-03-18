import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/update_device_data_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class UpdateDeviceDataRepository {
  Future<UpdateDeviceDataModel> fetchCurrentDeviceData({
    required String deviceId,
  }) async {
    return _postDeviceData(
      deviceId: deviceId,
    );
  }

  Future<UpdateDeviceDataModel> updateDeviceData({
    required String deviceId,
    required String fuelQuantity,
    required String vehicleType,
    required String engineType,
  }) async {
    return _postDeviceData(
      deviceId: deviceId,
      fuelQuantity: fuelQuantity,
      vehicleType: vehicleType,
      engineType: engineType,
    );
  }

  Future<UpdateDeviceDataModel> _postDeviceData({
    required String deviceId,
    String? fuelQuantity,
    String? vehicleType,
    String? engineType,
  }) async {
    final userApiHash = MySharedPreferences.getString(authTokenKey);
    if (userApiHash.isEmpty) {
      throw Exception("User token not found");
    }

    final query = <String, String>{
      "user_api_hash": userApiHash,
      "device_id": deviceId,
    };
    if (fuelQuantity != null) query["fuel_quantity"] = fuelQuantity;
    if (vehicleType != null) query["vehicle_type"] = vehicleType;
    if (engineType != null) query["engine_type"] = engineType;

    final uri = Uri.parse("${AppUrl.baseURL}${AppUrl.updateDeviceDataEp}")
        .replace(queryParameters: query);

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>? ??
        <String, dynamic>{};

    if (response.statusCode == 200) {
      return UpdateDeviceDataModel.fromJson(decoded);
    }

    final message =
        (decoded["message"] ?? "Failed to update device data").toString();
    throw Exception(message);
  }
}
