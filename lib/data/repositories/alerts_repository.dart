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
    String? from,
    String? to,
  }) async {
    try {
      final query = <String, String>{
        'user_api_hash': userApiHashKey,
        'page': '$page',
        'paginate': '0',
      };
      if (deviceId != null && deviceId.isNotEmpty) {
        query['device_id'] = deviceId;
      }
      if (alertType != null && alertType.isNotEmpty) {
        query['type'] = alertType;
      }
      if (from != null && from.isNotEmpty) {
        query['from'] = from;
      }
      if (to != null && to.isNotEmpty) {
        query['to'] = to;
      }

      final uri = Uri.parse('$_baseUrl/get_alert_list')
          .replace(queryParameters: query);

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

  /// GET ONE ALERT BY ALERT ID
  Future<Item?> getAlertById({
    required int alertId,
    required String userApiHashKey,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/get_alert_list').replace(
        queryParameters: <String, String>{
          'user_api_hash': userApiHashKey,
          'alert_id': '$alertId',
          'page': '1',
          'paginate': '0',
        },
      );

      log('GET ALERT BY ID URL: $uri');

      final response = await http.get(
        uri,
        headers: const {
          'Content-Type': 'application/json',
        },
      );

      log('GET ALERT BY ID STATUS CODE: ${response.statusCode}');
      log('GET ALERT BY ID RESPONSE BODY: ${response.body}');

      if (response.statusCode != 200) return null;

      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return _extractItemFromMap(decoded);
      }
      return null;
    } catch (e) {
      log('ERROR GETTING ALERT BY ID: $e');
      return null;
    }
  }

  Item? _extractItemFromMap(Map<String, dynamic> jsonMap) {
    final directItems = jsonMap['items'];
    if (directItems is List && directItems.isNotEmpty) {
      final first = directItems.first;
      if (first is Map<String, dynamic>) return Item.fromJson(first);
    }

    final item = jsonMap['item'];
    if (item is Map<String, dynamic>) {
      return Item.fromJson(item);
    }

    final data = jsonMap['data'];
    if (data is Map<String, dynamic>) {
      final nestedItems = data['items'];
      if (nestedItems is List && nestedItems.isNotEmpty) {
        final first = nestedItems.first;
        if (first is Map<String, dynamic>) return Item.fromJson(first);
      }
      if (data['id'] != null) {
        return Item.fromJson(data);
      }
    }

    if (jsonMap['id'] != null) {
      return Item.fromJson(jsonMap);
    }
    return null;
  }

  /// DELETE ALERTS
  Future<bool> deleteAlerts({
    required List<int> alertIds,
    required String userApiHashKey,
  }) async {
    try {
      final ids = alertIds.join(',');
      final endpointPath = AppUrl.deleteEp.split('?').first;
      final uri = Uri.parse('$_baseUrl$endpointPath').replace(
        queryParameters: {
          'user_api_hash': userApiHashKey,
          'id': ids,
        },
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
