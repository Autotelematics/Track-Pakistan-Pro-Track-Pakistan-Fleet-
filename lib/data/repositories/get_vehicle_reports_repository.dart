import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/get_device_reports_model.dart';
import 'package:trackerapp/data/models/get_reports_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';

class ReportTypeRepository {
  /// Fetch available report types
  Future<ReportTypeModel> fetchReportTypes({required String userApiHashKey}) async {
    if (userApiHashKey.trim().isEmpty) {
      throw Exception('API key is missing');
    }

    final endpointPath = AppUrl.getDeviceReportsEp.split('?').first;
    final Uri url = Uri.parse('${AppUrl.baseURL}$endpointPath').replace(
      queryParameters: {
        'user_api_hash': userApiHashKey,
      },
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReportTypeModel.fromJson(data);
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load report types: $e');
    }
  }

  /// Generate and fetch report URL
  Future<GetReportModel> generateReport({
    required String userApiHashKey,
    required String dateFrom,
    required String dateTo,
    required int deviceId,
    required String format,
    required int reportType,
    required String fromTime,
    required String toTime,
    int speedLimit = 0,
    List<int> geofenceIds = const [],
    int minutes = 0,
  }) async {
    if (userApiHashKey.trim().isEmpty) {
      throw Exception('API key is missing');
    }

    final endpointPath = AppUrl.generateReportsEp.split('?').first;
    final queryAll = <String, List<String>>{
      'user_api_hash': [userApiHashKey],
      'date_from': [dateFrom],
      'devices[]': [deviceId.toString()],
      'date_to': [dateTo],
      'from_time': [fromTime],
      'to_time': [toTime],
      'format': [format],
      'type': [reportType.toString()],
      'speed_limit': [speedLimit.toString()],
      'ignition_off': [minutes.toString()],
    };
    if (geofenceIds.isNotEmpty) {
      queryAll['geofences[]'] = geofenceIds.map((id) => id.toString()).toList();
    }
    final queryString = queryAll.entries
        .expand((entry) => entry.value.map(
              (value) =>
                  '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(value)}',
            ))
        .join('&');
    final Uri url = Uri.parse('${AppUrl.baseURL}$endpointPath?$queryString');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GetReportModel.fromJson(data);
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }
}
