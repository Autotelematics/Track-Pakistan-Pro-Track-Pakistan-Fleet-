import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class TaskGeocodingRepository {
  String _userApiHash() {
    final token = MySharedPreferences.getString(authTokenKey);
    if (token.isEmpty) {
      throw Exception('User token not found');
    }
    return token;
  }

  Uri _uri(String path, {Map<String, String>? query}) {
    return Uri.parse('${AppUrl.baseURL}$path').replace(queryParameters: query);
  }

  Future<List<TaskGeoSuggestion>> autocomplete(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const <TaskGeoSuggestion>[];

    final response = await http.get(
      _uri(
        AppUrl.addressAutocompleteEp,
        query: <String, String>{
          'user_api_hash': _userApiHash(),
          'q': q,
        },
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to search locations');
    }

    if (response.body.trim().isEmpty) return const <TaskGeoSuggestion>[];
    final decoded = jsonDecode(response.body);

    List raw;
    if (decoded is List) {
      raw = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final dynamic items = decoded['items'] ?? decoded['data'] ?? decoded['results'];
      raw = items is List ? items : <dynamic>[];
    } else {
      raw = <dynamic>[];
    }

    return raw
        .whereType<Map>()
        .map((item) => TaskGeoSuggestion.fromJson(_normalizeMap(item)))
        .where((item) => item.address.trim().isNotEmpty)
        .toList(growable: false);
  }

  Future<String> reverseGeocode({
    required double lat,
    required double lon,
  }) async {
    final response = await http.get(
      _uri(
        AppUrl.geoAddressEp,
        query: <String, String>{
          'lat': lat.toString(),
          'lon': lon.toString(),
        },
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to get address');
    }

    if (response.body.trim().isEmpty) return '';
    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      final candidates = <dynamic>[
        decoded['address'],
        decoded['display_name'],
        decoded['formatted_address'],
        decoded['name'],
      ];
      for (final value in candidates) {
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
      }
      return '';
    }

    return decoded.toString().trim();
  }

  static Map<String, dynamic> _normalizeMap(Map source) {
    final normalized = <String, dynamic>{};
    source.forEach((key, value) {
      if (key == null) return;
      normalized[key.toString()] = value;
    });
    return normalized;
  }
}

class TaskGeoSuggestion {
  final String address;
  final double lat;
  final double lng;
  final String city;
  final String country;

  const TaskGeoSuggestion({
    required this.address,
    required this.lat,
    required this.lng,
    required this.city,
    required this.country,
  });

  factory TaskGeoSuggestion.fromJson(Map<String, dynamic> json) {
    String firstText(List<dynamic> values) {
      for (final value in values) {
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
      }
      return '';
    }

    return TaskGeoSuggestion(
      address: firstText(<dynamic>[
        json['address'],
        json['display_name'],
        json['formatted_address'],
        json['name'],
      ]),
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lng'] ?? json['lon']),
      city: firstText(<dynamic>[json['city'], json['town'], json['state']]),
      country: firstText(<dynamic>[json['country']]),
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
