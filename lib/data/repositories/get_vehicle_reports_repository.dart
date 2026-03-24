import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/get_device_reports_model.dart';
import 'package:trackerapp/data/models/get_reports_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';

class ReportTypeRepository {
  String _cleanErrorText(Object e) {
    final text = e.toString().trim();
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length).trim();
    }
    return text;
  }

  List<String> _timeCandidates(String raw, {required String fallback}) {
    final candidates = <String>[];
    final trimmed = raw.trim();
    if (trimmed.isNotEmpty) candidates.add(trimmed);
    final normalized = _normalizeApiTime(trimmed, fallback: fallback);
    if (!candidates.contains(normalized)) candidates.add(normalized);
    if (!candidates.contains(fallback)) candidates.add(fallback);
    return candidates;
  }

  String _normalizeApiTime(String raw, {required String fallback}) {
    final value = raw.trim();
    if (value.isEmpty) return fallback;

    final twentyFour = RegExp(r'^(\d{1,2}):(\d{2})(?::\d{2})?$');
    final twentyFourMatch = twentyFour.firstMatch(value);
    if (twentyFourMatch != null) {
      final hour = int.tryParse(twentyFourMatch.group(1) ?? '');
      final minute = int.tryParse(twentyFourMatch.group(2) ?? '');
      if (hour != null && minute != null && hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    }

    final twelveHour = RegExp(r'^(\d{1,2}):(\d{2})(?::\d{2})?\s*([AaPp][Mm])$');
    final twelveHourMatch = twelveHour.firstMatch(value);
    if (twelveHourMatch != null) {
      final hour12 = int.tryParse(twelveHourMatch.group(1) ?? '');
      final minute = int.tryParse(twelveHourMatch.group(2) ?? '');
      final ampm = (twelveHourMatch.group(3) ?? '').toUpperCase();
      if (hour12 != null &&
          minute != null &&
          hour12 >= 1 &&
          hour12 <= 12 &&
          minute >= 0 &&
          minute <= 59) {
        var hour24 = hour12 % 12;
        if (ampm == 'PM') hour24 += 12;
        return '${hour24.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    }

    return fallback;
  }

  String _extractErrorText(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) {
      if (value.isEmpty) return '';
      return _extractErrorText(value.first);
    }
    if (value is Map) {
      if (value.isEmpty) return '';
      return _extractErrorText(value.values.first);
    }
    return value.toString();
  }

  bool _looksLikePdfBytes(List<int> bytes) {
    if (bytes.length < 5) return false;
    return bytes[0] == 0x25 && // %
        bytes[1] == 0x50 && // P
        bytes[2] == 0x44 && // D
        bytes[3] == 0x46 && // F
        bytes[4] == 0x2D; // -
  }

  bool _isDirectDocumentResponse(http.Response response) {
    final contentType = (response.headers['content-type'] ?? '').toLowerCase();
    if (contentType.contains('application/pdf') ||
        contentType.contains('application/octet-stream')) {
      return true;
    }
    return _looksLikePdfBytes(response.bodyBytes);
  }

  bool _isStatusPayload(dynamic parsed) {
    if (parsed is! Map) return false;
    return parsed.containsKey('status');
  }

  GetReportModel _modelFromSuccessfulResponse(
    String body,
    dynamic parsed,
  ) {
    if (parsed is String) {
      final raw = parsed.trim();
      if (raw.startsWith('http://') || raw.startsWith('https://')) {
        return GetReportModel(status: 1, url: raw);
      }
    }
    final bodyText = body.trim();
    if (bodyText.startsWith('http://') || bodyText.startsWith('https://')) {
      return GetReportModel(status: 1, url: bodyText);
    }
    final data = (parsed is Map)
        ? Map<String, dynamic>.from(parsed)
        : <String, dynamic>{};
    return GetReportModel.fromJson(data);
  }

  Future<GetReportModel?> _pollPendingReport(String initialUrl) async {
    var pollUrl = initialUrl.trim();
    if (pollUrl.isEmpty) return null;

    const maxAttempts = 45;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (attempt > 0) {
        await Future.delayed(const Duration(milliseconds: 1200));
      }
      final response =
          await http.get(Uri.parse(pollUrl)).timeout(const Duration(seconds: 30));
      dynamic parsed;
      if (response.body.isNotEmpty) {
        try {
          parsed = jsonDecode(response.body);
        } catch (_) {}
      }

      if (response.statusCode != 200) {
        continue;
      }

      if (_isDirectDocumentResponse(response)) {
        return GetReportModel(status: 1, url: pollUrl);
      }

      if (!_isStatusPayload(parsed) && response.body.trim().isNotEmpty) {
        // html/xls and other non-status payloads mean report is already ready.
        return GetReportModel(status: 1, url: pollUrl);
      }

      final model = _modelFromSuccessfulResponse(response.body, parsed);
      if (model.isSuccess) return model;

      if (model.status == 3 && (model.url ?? '').trim().isNotEmpty) {
        pollUrl = model.url!.trim();
        continue;
      }

      return model;
    }

    return GetReportModel(
      status: 3,
      message: 'Report is still processing. Please retry in a moment.',
      url: initialUrl,
    );
  }

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
      throw Exception('Failed to load report types: ${_cleanErrorText(e)}');
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
    int stops = 0,
    bool showAddresses = false,
    bool zonesInstead = false,
  }) async {
    if (userApiHashKey.trim().isEmpty) {
      throw Exception('API key is missing');
    }

    final endpointPath = AppUrl.generateReportsEp.split('?').first;
    final fromTimeCandidates =
        _timeCandidates(fromTime, fallback: '00:00');
    final toTimeCandidates =
        _timeCandidates(toTime, fallback: '23:59');

    Exception? lastError;

    for (final ft in fromTimeCandidates) {
      for (final tt in toTimeCandidates) {
        final queryAll = <String, List<String>>{
          'user_api_hash': [userApiHashKey],
          'date_from': [dateFrom],
          'devices[]': [deviceId.toString()],
          'date_to': [dateTo],
          'from_time': [ft],
          'to_time': [tt],
          'format': [format],
          'type': [reportType.toString()],
          'speed_limit': [speedLimit.toString()],
          'ignition_off': [minutes.toString()],
        };
        if (geofenceIds.isNotEmpty) {
          queryAll['geofences[]'] =
              geofenceIds.map((id) => id.toString()).toList();
        }
        if (stops > 0) {
          queryAll['stops'] = [stops.toString()];
        }
        if (showAddresses) {
          queryAll['show_addresses'] = ['1'];
        }
        if (zonesInstead) {
          queryAll['zones_instead'] = ['1'];
        }
        final queryString = queryAll.entries
            .expand((entry) => entry.value.map(
                  (value) =>
                      '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(value)}',
                ))
            .join('&');
        final Uri url = Uri.parse('${AppUrl.baseURL}$endpointPath?$queryString');

        final response =
            await http.get(url).timeout(const Duration(seconds: 30));
        dynamic parsed;
        if (response.body.isNotEmpty) {
          try {
            parsed = jsonDecode(response.body);
          } catch (_) {}
        }

        if (response.statusCode == 200) {
          if (_isDirectDocumentResponse(response)) {
            return GetReportModel(status: 1, url: url.toString());
          }

          if (!_isStatusPayload(parsed) && response.body.trim().isNotEmpty) {
            // For html/xls the server can return document payload directly.
            return GetReportModel(status: 1, url: url.toString());
          }

          final bodyText = response.body.trim();
          var model = _modelFromSuccessfulResponse(response.body, parsed);
          if (model.isSuccess) return model;

          if (model.status == 3 && (model.url ?? '').trim().isNotEmpty) {
            final polled = await _pollPendingReport(model.url!.trim());
            if (polled != null) {
              model = polled;
              if (model.isSuccess) return model;
            }
          }

          var message = model.bestErrorMessage.trim();
          if (message.isEmpty || message == 'Failed to generate report') {
            final shortened = bodyText.length > 300
                ? '${bodyText.substring(0, 300)}...'
                : bodyText;
            message = shortened.isEmpty
                ? 'Unexpected empty response from report API'
                : 'Unexpected report response: $shortened';
          }
          lastError = Exception(message);
          continue;
        }

        final message = (parsed is Map)
            ? (((parsed['message']?.toString().trim().isNotEmpty) ?? false)
                ? parsed['message'].toString().trim()
                : _extractErrorText(parsed['errors']).trim())
            : '';
        if (message.isNotEmpty) {
          lastError = Exception(
            'Server error (${response.statusCode}) [from_time=$ft,to_time=$tt]: $message',
          );
        } else {
          lastError = Exception(
            'Server error (${response.statusCode}) [from_time=$ft,to_time=$tt]',
          );
        }
      }
    }

    throw lastError ?? Exception('Failed to generate report');
  }
}
