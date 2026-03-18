import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/device_service_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class DeviceServiceRepository {
  String _userApiHash() {
    final token = MySharedPreferences.getString(authTokenKey);
    if (token.isEmpty) {
      throw Exception('User token not found');
    }
    return token;
  }

  Uri _uri(String path, {Map<String, String>? query}) {
    final params = <String, String>{
      'user_api_hash': _userApiHash(),
      ...?query,
    };
    return Uri.parse('${AppUrl.baseURL}$path').replace(queryParameters: params);
  }

  String _formatDateTime(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    final h = value.hour.toString().padLeft(2, '0');
    final min = value.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      final normalized = <String, dynamic>{};
      decoded.forEach((key, value) {
        if (key == null) return;
        normalized[key.toString()] = value;
      });
      return normalized;
    }
    throw Exception('Invalid response format');
  }

  dynamic _decodeAny(http.Response response) {
    if (response.body.trim().isEmpty) return <String, dynamic>{};
    return jsonDecode(response.body);
  }

  String _firstErrorText(dynamic errors) {
    if (errors is Map) {
      if (errors.isEmpty) return '';
      return _firstErrorText(errors.values.first);
    }
    if (errors is List) {
      if (errors.isEmpty) return '';
      return _firstErrorText(errors.first);
    }
    return errors?.toString() ?? '';
  }

  void _ensureStatusCode(http.Response response,
      {String fallback = 'Request failed'}) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    String parsedMessage = '';
    try {
      final body = _decode(response);
      final extracted = _firstErrorText(body['errors']);
      if (extracted.trim().isNotEmpty) {
        parsedMessage = extracted.trim();
      } else {
        final message = body['message']?.toString().trim() ?? '';
        if (message.isNotEmpty) {
          parsedMessage = message;
        }
      }
    } catch (_) {
      // Ignore parse failures and fall back below.
    }
    if (parsedMessage.isNotEmpty) {
      throw Exception(parsedMessage);
    }
    if (response.body.trim().isNotEmpty &&
        response.body.trim().toLowerCase() != 'null') {
      throw Exception(response.body.trim());
    }
    throw Exception(fallback);
  }

  void _ensureApiStatusOk(Map<String, dynamic> body, {String? fallback}) {
    if (!body.containsKey('status')) return;
    final status = body['status'];
    final success = status == 1 || status == true;
    if (success) return;

    final errorText = _firstErrorText(body['errors']).trim();
    if (errorText.isNotEmpty) {
      throw Exception(errorText);
    }
    throw Exception(
        (body['message'] ?? fallback ?? 'Request failed').toString());
  }

  Future<DeviceServiceListResponse> listServices({
    required int deviceId,
    int page = 1,
  }) async {
    final query = <String, String>{
      'device_id': '$deviceId',
      'page': '$page',
    };

    final endpointCandidates = <String>[
      AppUrl.deviceServicesCreateEp, // confirmed by user: /services
      AppUrl.deviceServicesEp, // legacy fallback: /service-api
    ];

    http.Response? response;
    for (final endpoint in endpointCandidates) {
      final current = await http.get(_uri(endpoint, query: query));
      if (current.statusCode == 404) {
        response = current;
        continue;
      }
      response = current;
      break;
    }

    if (response == null) {
      throw Exception('Failed to load services');
    }

    _ensureStatusCode(response, fallback: 'Failed to load services');

    final decoded = _decodeAny(response);
    if (decoded is List) {
      return DeviceServiceListResponse.fromJson(<String, dynamic>{
        'data': decoded,
        'current_page': 1,
        'last_page': 1,
        'per_page': decoded.length,
        'total': decoded.length,
      });
    }
    if (decoded is Map<String, dynamic>) {
      return DeviceServiceListResponse.fromJson(decoded);
    }
    if (decoded is Map) {
      final normalized = <String, dynamic>{};
      decoded.forEach((key, value) {
        if (key == null) return;
        normalized[key.toString()] = value;
      });
      return DeviceServiceListResponse.fromJson(normalized);
    }
    throw Exception('Invalid services list response');
  }

  Future<void> createService({
    required int deviceId,
    required String name,
    required String expirationBy,
    required String interval,
    required String lastService,
    String? triggerEventLeft,
    required bool renewAfterExpiration,
    required bool expires,
    DateTime? expiresDate,
    required bool remind,
    DateTime? remindDate,
    String? email,
    String? mobilePhone,
    String? description,
  }) async {
    final enteredEmail = email?.trim() ?? '';
    final fallbackUserEmail = MySharedPreferences.getString(userEmailKey).trim();
    final resolvedEmail = enteredEmail.isNotEmpty ? enteredEmail : fallbackUserEmail;

    final params = <String, String>{
      'user_api_hash': _userApiHash(),
      'device_id': '$deviceId',
      'name': name.trim(),
      'expiration_by': expirationBy.trim(),
      'interval': interval.trim(),
      'last_service': lastService.trim(),
      'renew_after_expiration': renewAfterExpiration ? '1' : '0',
      if (triggerEventLeft != null && triggerEventLeft.trim().isNotEmpty)
        'trigger_event_left': triggerEventLeft.trim(),
      if (expiresDate != null)
        'expires_date': _formatDateTime(expiresDate),
      if (remindDate != null)
        'remind_date': _formatDateTime(remindDate),
      if (expires) 'expires': '1',
      if (remind) 'remind': '1',
      if (resolvedEmail.isNotEmpty) 'email': resolvedEmail,
      if (mobilePhone != null && mobilePhone.trim().isNotEmpty)
        'mobile_phone': mobilePhone.trim(),
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
    };

    final endpointCandidates = <String>[
      AppUrl.deviceServicesCreateEp,
      AppUrl.deviceServicesEp,
      '${AppUrl.deviceServicesCreateEp}/create',
      '${AppUrl.deviceServicesCreateEp}/store',
      '${AppUrl.deviceServicesEp}/create',
      '${AppUrl.deviceServicesEp}/store',
    ];

    http.Response? response;
    for (final endpoint in endpointCandidates) {
      // 1) Match known working Postman style: POST with query params.
      var current = await http.post(_uri(endpoint, query: params));

      if (current.statusCode == 404) {
        // 2) Fallback: form-urlencoded body.
        current = await http.post(
          _uri(endpoint),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: params,
        );
      }

      if (current.statusCode == 404) {
        response = current;
        continue;
      }

      response = current;
      break;
    }

    if (response == null) {
      throw Exception('Failed to create service');
    }

    _ensureStatusCode(response, fallback: 'Failed to create service');
    final decoded = _decode(response);
    _ensureApiStatusOk(decoded, fallback: 'Failed to create service');
  }

  Future<void> updateService({
    required int serviceId,
    String? name,
    String? expirationBy,
    String? interval,
    String? lastService,
    String? triggerEventLeft,
    bool? renewAfterExpiration,
    bool? expires,
    DateTime? expiresDate,
    bool? remind,
    DateTime? remindDate,
    String? email,
    String? mobilePhone,
    String? description,
  }) async {
    final body = <String, String>{
      if (name != null) 'name': name.trim(),
      if (expirationBy != null) 'expiration_by': expirationBy.trim(),
      if (interval != null) 'interval': interval.trim(),
      if (lastService != null) 'last_service': lastService.trim(),
      if (triggerEventLeft != null)
        'trigger_event_left': triggerEventLeft.trim(),
      if (renewAfterExpiration != null)
        'renew_after_expiration': renewAfterExpiration ? '1' : '0',
      if (expires != null) 'expires': expires ? '1' : '0',
      if (expiresDate != null)
        'expires_date': expiresDate.toIso8601String().split('T').first,
      if (remind != null) 'remind': remind ? '1' : '0',
      if (remindDate != null)
        'remind_date': remindDate.toIso8601String().split('T').first,
      if (email != null) 'email': email.trim(),
      if (mobilePhone != null) 'mobile_phone': mobilePhone.trim(),
      if (description != null) 'description': description.trim(),
    };

    final endpoint = '${AppUrl.deviceServicesEp}/$serviceId';
    http.Response response;
    try {
      response = await http.put(
        _uri(endpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );
      _ensureStatusCode(response, fallback: 'Failed to update service');
    } catch (_) {
      response = await http.post(
        _uri(endpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );
      _ensureStatusCode(response, fallback: 'Failed to update service');
    }

    final decoded = _decode(response);
    _ensureApiStatusOk(decoded, fallback: 'Failed to update service');
  }

  Future<void> deleteService({
    required int serviceId,
    required int deviceId,
  }) async {
    final endpoint = '${AppUrl.deviceServicesCreateEp}/$serviceId';
    final response = await http.delete(
      _uri(endpoint, query: {
        'device_id': '$deviceId',
      }),
    );
    _ensureStatusCode(response, fallback: 'Failed to delete service');
    final decoded = _decode(response);
    _ensureApiStatusOk(decoded, fallback: 'Failed to delete service');
  }
}
