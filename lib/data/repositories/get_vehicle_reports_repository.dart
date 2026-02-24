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

    final Uri url = Uri.parse('${AppUrl.baseURL}${AppUrl.getDeviceReportsEp}$userApiHashKey');

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

    // Build geofences query string
    String geofencesQuery = geofenceIds.isEmpty
        ? ''
        : geofenceIds.map((id) => '&geofences[]=$id').join('');

    // Build complete query string
    final queryString = '&date_from=$dateFrom'
        '&devices[]=$deviceId'
        '&date_to=$dateTo'
        '&from_time=$fromTime'
        '&to_time=$toTime'
        '&format=$format'
        '&type=$reportType'
        '&speed_limit=$speedLimit'
        '$geofencesQuery'
        '&ignition_off=$minutes';

    final Uri url = Uri.parse('${AppUrl.baseURL}${AppUrl.generateReportsEp}$userApiHashKey$queryString');

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