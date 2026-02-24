import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/get_alerts_list_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';

class AlertsRepository {
  final String _baseUrl = AppUrl.baseURL;

  /// GET ALERTS LIST
  Future<GetAlertsModel?> getAlerts({
    required int page,
    required String userApiHashKey,
    String? deviceId,
    String? alertType,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl${AppUrl.alertsEp}$userApiHashKey&page=$page'
            '${deviceId != null && deviceId.isNotEmpty ? '&device_id=$deviceId' : ''}'
            '${alertType != null && alertType.isNotEmpty ? '&type=$alertType' : ''}',
      );

      log('GET ALERTS URL: $uri');

      final response = await http.get(
        uri,
        headers: const {
          'Content-Type': 'application/json',
        },
      );

      log('STATUS CODE: ${response.statusCode}');
      log('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
        json.decode(response.body) as Map<String, dynamic>;

        return GetAlertsModel.fromJson(jsonData);
      }

      return null;
    } catch (e) {
      log('ERROR GETTING ALERTS: $e');
      return null;
    }
  }

  /// DELETE ALERTS
  Future<bool> deleteAlerts({
    required List<int> alertIds,
    required String userApiHashKey,
  }) async {
    try {
      final ids = alertIds.join(',');

      final uri = Uri.parse(
        '$_baseUrl${AppUrl.deleteEp}$userApiHashKey&id=$ids',
      );

      log('DELETE ALERTS URL: $uri');

      final response = await http.post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
        },
      );

      log('STATUS CODE: ${response.statusCode}');
      log('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 1 || data['success'] == true;
      }

      return false;
    } catch (e) {
      log('ERROR DELETING ALERTS: $e');
      return false;
    }
  }


}
