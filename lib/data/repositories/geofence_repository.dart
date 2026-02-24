import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/geofence_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';

class GeofenceRepository {
  final String _baseUrl = AppUrl.baseURL;

  Future<GetGeofencesModel?> getGeofence({
    required String userApiHashKey,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl${AppUrl.geofenceEp}$userApiHashKey',
      );
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return GetGeofencesModel.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      log('ERROR GETTING GEOFENCE: $e');
      return null;
    }
  }

  /// CHANGE ACTIVE STATUS
  Future<bool> changeGeofenceActive({
    required int id,
    required bool active,
    required String userApiHashKey,
  })
  async {
    try {
      final uri = Uri.parse(
        '$_baseUrl${AppUrl.changeActiveGeofenceEp}$userApiHashKey&id=$id&active=${active ? "true" : "false"}',
      );

      log('CHANGE ACTIVE URL: $uri');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      log('STATUS CODE: ${response.statusCode}');
      log('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 1;
      }

      return false;
    } catch (e) {
      log('ERROR CHANGING GEOFENCE ACTIVE: $e');
      return false;
    }
  }
}