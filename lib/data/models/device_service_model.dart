class DeviceService {
  final int id;
  final int userId;
  final int deviceId;
  final String deviceName;
  final String name;
  final String expirationBy;
  final String interval;
  final String lastService;
  final String triggerEventLeft;
  final bool renewAfterExpiration;
  final bool expires;
  final DateTime? expiresDate;
  final bool remind;
  final DateTime? remindDate;
  final bool eventSent;
  final bool expired;
  final String email;
  final String mobilePhone;
  final String description;
  final int? currentOdometer;
  final String currentEngineHours;

  const DeviceService({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.deviceName,
    required this.name,
    required this.expirationBy,
    required this.interval,
    required this.lastService,
    required this.triggerEventLeft,
    required this.renewAfterExpiration,
    required this.expires,
    required this.expiresDate,
    required this.remind,
    required this.remindDate,
    required this.eventSent,
    required this.expired,
    required this.email,
    required this.mobilePhone,
    required this.description,
    required this.currentOdometer,
    required this.currentEngineHours,
  });

  factory DeviceService.fromJson(Map<String, dynamic> json) {
    return DeviceService(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      deviceId: _toInt(json['device_id']),
      deviceName: _asString(json['device_name']),
      name: _asString(json['name']),
      expirationBy: _asString(json['expiration_by']),
      interval: _asString(json['interval']),
      lastService: _asString(json['last_service']),
      triggerEventLeft: _asString(json['trigger_event_left']),
      renewAfterExpiration: _toBool(json['renew_after_expiration']),
      expires: _toBool(json['expires']),
      expiresDate: _tryParseDate(json['expires_date']?.toString()),
      remind: _toBool(json['remind']),
      remindDate: _tryParseDate(json['remind_date']?.toString()),
      eventSent: _toBool(json['event_sent']),
      expired: _toBool(json['expired']),
      email: _asString(json['email']),
      mobilePhone: _asString(json['mobile_phone']),
      description: _asString(json['description']),
      currentOdometer: _toNullableInt(json['current_odometer']),
      currentEngineHours: _asString(json['current_enginehours']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    final asInt = int.tryParse('${value ?? ''}');
    if (asInt != null) return asInt;
    final asDouble = double.tryParse('${value ?? ''}');
    if (asDouble != null) return asDouble.toInt();
    return 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    final parsed = _toInt(value);
    return parsed == 0 && '${value ?? ''}'.trim().isEmpty ? null : parsed;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = '${value ?? ''}'.toLowerCase().trim();
    return text == '1' || text == 'true' || text == 'yes';
  }

  static DateTime? _tryParseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }
}

class DeviceServiceListResponse {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<DeviceService> data;

  const DeviceServiceListResponse({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.data,
  });

  factory DeviceServiceListResponse.fromJson(Map<String, dynamic> json) {
    final services = _normalizeAnyMap(json['services']);
    final pager = _pickPagerMap(json: json, services: services);
    final rawData = _extractListData(json: json, services: services);
    final list = rawData
        .whereType<Map>()
        .map((e) => DeviceService.fromJson(_normalizeMap(e)))
        .toList();

    return DeviceServiceListResponse(
      currentPage: _toInt(pager['current_page']),
      lastPage: _toInt(pager['last_page']),
      perPage: _toInt(pager['per_page']),
      total: _toInt(pager['total']),
      data: list,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    final asInt = int.tryParse('${value ?? ''}');
    if (asInt != null) return asInt;
    final asDouble = double.tryParse('${value ?? ''}');
    if (asDouble != null) return asDouble.toInt();
    return 0;
  }

  static List _extractListData({
    required Map<String, dynamic> json,
    required Map<String, dynamic> services,
  }) {
    final fromNestedServicesData = services['services'];
    if (fromNestedServicesData is List) return fromNestedServicesData;
    if (fromNestedServicesData is Map) {
      final nestedData = fromNestedServicesData['data'];
      if (nestedData is List) return nestedData;
      if (nestedData is Map) return nestedData.values.toList();
      return fromNestedServicesData.values.toList();
    }

    final fromServicesData = services['data'];
    if (fromServicesData is List) return fromServicesData;
    if (fromServicesData is Map) return fromServicesData.values.toList();

    final fromServicesDirect = json['services'];
    if (fromServicesDirect is List) return fromServicesDirect;
    if (fromServicesDirect is Map) {
      final normalized = _normalizeMap(fromServicesDirect);
      final nested = normalized['data'];
      if (nested is List) return nested;
      if (nested is Map) return nested.values.toList();
      return _findServiceEntries(normalized);
    }

    final fromRootData = json['data'];
    if (fromRootData is List) return fromRootData;
    if (fromRootData is Map) {
      final nested = _normalizeMap(fromRootData);
      final nestedData = nested['data'];
      if (nestedData is List) return nestedData;
      if (nestedData is Map) return nestedData.values.toList();
      return _findServiceEntries(nested);
    }

    final recursive = _findServiceEntries(json);
    if (recursive.isNotEmpty) return recursive;

    return const <dynamic>[];
  }

  static Map<String, dynamic> _pickPagerMap({
    required Map<String, dynamic> json,
    required Map<String, dynamic> services,
  }) {
    if (_hasPagerKeys(services)) return services;
    final rootData = _normalizeAnyMap(json['data']);
    if (_hasPagerKeys(rootData)) return rootData;
    final rootServices = _normalizeAnyMap(json['services']);
    if (_hasPagerKeys(rootServices)) return rootServices;
    return <String, dynamic>{};
  }

  static bool _hasPagerKeys(Map<String, dynamic> map) {
    return map.containsKey('current_page') ||
        map.containsKey('last_page') ||
        map.containsKey('per_page') ||
        map.containsKey('total');
  }

  static List _findServiceEntries(dynamic node) {
    if (node is List) {
      if (node.isNotEmpty &&
          node.first is Map &&
          _looksLikeServiceMap(_normalizeMap(node.first as Map))) {
        return node;
      }
      for (final item in node) {
        final nested = _findServiceEntries(item);
        if (nested.isNotEmpty) return nested;
      }
      return const <dynamic>[];
    }

    if (node is Map) {
      final map = _normalizeMap(node);
      const preferredKeys = ['services', 'data', 'items', 'rows', 'result'];
      for (final key in preferredKeys) {
        if (!map.containsKey(key)) continue;
        final nested = _findServiceEntries(map[key]);
        if (nested.isNotEmpty) return nested;
      }

      for (final value in map.values) {
        final nested = _findServiceEntries(value);
        if (nested.isNotEmpty) return nested;
      }
    }

    return const <dynamic>[];
  }

  static bool _looksLikeServiceMap(Map<String, dynamic> map) {
    return map.containsKey('id') &&
        (map.containsKey('device_id') ||
            map.containsKey('name') ||
            map.containsKey('expiration_by'));
  }

  static Map<String, dynamic> _normalizeAnyMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return _normalizeMap(value);
    return <String, dynamic>{};
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
