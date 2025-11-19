import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/get_alerts_list_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';

class AlertsRepository {
  static  String baseUrl = AppUrl.baseURL;

  /// GET Alerts List
  Future<GetAlertsModel?> getAlerts({
    required int page,
    String? deviceId,
    String? alertType,
    required String userApiHashKey,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl${AppUrl.alertsEp}$userApiHashKey&page=$page'
            '${deviceId != null ? '&device_id=$deviceId' : ''}'
            '${alertType != null ? '&type=$alertType' : ''}',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return GetAlertsModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load alerts. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching alerts: $e');
    }
  }

  /// DELETE Alerts
  Future<bool> deleteAlerts({
    required List<int> alertIds,
    required String userApiHashKey,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl${AppUrl.deleteEp}$userApiHashKey');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'ids': alertIds.join(',')},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['status'] == 1 || jsonData['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
