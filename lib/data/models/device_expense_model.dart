class DeviceExpense {
  final int id;
  final int deviceId;
  final int? typeId;
  final DateTime? date;
  final double quantity;
  final double unitCost;
  final String typeName;
  final String name;
  final String supplier;
  final String comment;

  const DeviceExpense({
    required this.id,
    required this.deviceId,
    required this.typeId,
    required this.date,
    required this.quantity,
    required this.unitCost,
    required this.typeName,
    required this.name,
    required this.supplier,
    required this.comment,
  });

  double get totalCost => quantity * unitCost;

  factory DeviceExpense.fromJson(Map<String, dynamic> json) {
    final parsedTypeId = _extractTypeId(json);
    return DeviceExpense(
      id: _toInt(json["id"]),
      deviceId: _toInt(json["device_id"]),
      typeId: parsedTypeId,
      date: _tryParseDate(json["date"]?.toString()),
      quantity: _toDouble(json["quantity"]),
      unitCost: _toDouble(json["unit_cost"]),
      typeName: _extractTypeName(json),
      name: _asString(json["name"]),
      supplier: _asString(json["supplier"]),
      comment: _asString(json["comment"]),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    final text = value?.toString() ?? "";
    final asInt = int.tryParse(text);
    if (asInt != null) return asInt;
    final asDouble = double.tryParse(text);
    if (asDouble != null) return asDouble.toInt();
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? "") ?? 0;
  }

  static DateTime? _tryParseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static String _asString(dynamic value) {
    if (value == null) return "";
    return value.toString();
  }

  static String _extractTypeName(Map<String, dynamic> json) {
    final directCandidates = [
      json["device_expenses_type_name"],
      json["device_expense_type_name"],
      json["expense_type_name"],
      json["type_name"],
      json["type"],
    ];
    for (final candidate in directCandidates) {
      final text = _asString(candidate).trim();
      if (text.isNotEmpty) return text;
    }

    final nested = json["device_expense_type"] ??
        json["device_expenses_type"] ??
        json["expense_type"] ??
        json["type_obj"];
    if (nested is Map) {
      final normalized = <String, dynamic>{};
      nested.forEach((key, value) {
        if (key == null) return;
        normalized[key.toString()] = value;
      });
      final text = _asString(
        normalized["name"] ??
            normalized["title"] ??
            normalized["label"] ??
            normalized["value"],
      ).trim();
      if (text.isNotEmpty) return text;
    }
    return "";
  }

  static int? _extractTypeId(Map<String, dynamic> json) {
    final candidates = [
      json["device_expenses_type_id"],
      json["device_expense_type_id"],
      json["expense_type_id"],
      json["type_id"],
      json["device_expenses_type"],
      json["device_expense_type"],
      json["expense_type"],
      json["type"],
    ];
    for (final candidate in candidates) {
      if (candidate == null) continue;
      final parsed = _toInt(candidate);
      if (parsed > 0) return parsed;
    }

    final nested = json["device_expense_type"] ??
        json["device_expenses_type"] ??
        json["expense_type"] ??
        json["type_obj"];
    if (nested is Map) {
      final rawId = nested["id"] ?? nested["type_id"];
      if (rawId != null) {
        final parsed = _toInt(rawId);
        if (parsed > 0) return parsed;
      }
    }
    return null;
  }
}

class DeviceExpenseType {
  final int id;
  final String name;

  const DeviceExpenseType({
    required this.id,
    required this.name,
  });

  factory DeviceExpenseType.fromJson(Map<String, dynamic> json) {
    final rawId = json["id"] ?? json["type_id"] ?? json["value"];
    final parsedId = rawId is int ? rawId : int.tryParse("${rawId ?? ""}") ?? 0;
    final rawName =
        json["name"] ?? json["title"] ?? json["label"] ?? json["value"];
    return DeviceExpenseType(
      id: parsedId,
      name: rawName == null ? "" : rawName.toString(),
    );
  }
}

class DeviceExpenseListResponse {
  final int? deviceId;
  final double total;
  final List<DeviceExpense> data;

  const DeviceExpenseListResponse({
    required this.deviceId,
    required this.total,
    required this.data,
  });

  factory DeviceExpenseListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json["data"];
    final list = rawData is List
        ? rawData
            .whereType<Map>()
            .map((e) => DeviceExpense.fromJson(_normalizeMap(e)))
            .toList()
        : <DeviceExpense>[];

    return DeviceExpenseListResponse(
      deviceId: json["device_id"] == null
          ? null
          : (json["device_id"] is int
              ? json["device_id"] as int
              : int.tryParse("${json["device_id"]}")),
      total: json["total"] is num
          ? (json["total"] as num).toDouble()
          : double.tryParse("${json["total"]}") ?? 0,
      data: list,
    );
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
