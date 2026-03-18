import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/get_driver_performance_model.dart';
import 'package:trackerapp/data/models/get_vehicle_performance_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';

class PerformanceRepository {
  final String _baseUrl = AppUrl.baseURL;

  Future<GetVehiclePerformanceModel?> getVehiclePerformance({
    required String userApiHashKey,
    required String from,
    required String to,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl${AppUrl.vehiclePerformanceEp}').replace(
        queryParameters: {
          'user_api_hash': userApiHashKey,
          'from': from,
          'to': to,
        },
      );

      final response = await http.get(
        uri,
        headers: const {'Content-Type': 'application/json'},
      );

      log('GET VEHICLE PERFORMANCE URL: $uri');
      log('STATUS CODE: ${response.statusCode}');
      log('RESPONSE BODY: ${response.body}');

      if (response.statusCode != 200) return null;

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return GetVehiclePerformanceModel.fromJson(decoded);
    } catch (e) {
      log('ERROR GETTING VEHICLE PERFORMANCE: $e');
      return null;
    }
  }

  Future<GetDriverPerformanceModel?> getDriverPerformance({
    required String userApiHashKey,
    required String from,
    required String to,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl${AppUrl.driverPerformanceEp}').replace(
        queryParameters: {
          'user_api_hash': userApiHashKey,
          'from': from,
          'to': to,
        },
      );

      final response = await http.get(
        uri,
        headers: const {'Content-Type': 'application/json'},
      );

      log('GET DRIVER PERFORMANCE URL: $uri');
      log('STATUS CODE: ${response.statusCode}');
      log('RESPONSE BODY: ${response.body}');

      if (response.statusCode != 200) return null;

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return GetDriverPerformanceModel.fromJson(decoded);
    } catch (e) {
      log('ERROR GETTING DRIVER PERFORMANCE: $e');
      return null;
    }
  }
}
