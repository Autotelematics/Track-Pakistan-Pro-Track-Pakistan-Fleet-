class GetDashboardModel {
  final String userEmail;
  final StatusCounts statusCounts;
  final AlertsSummary alertsSummary;
  final List<MaintenanceItem> maintenance;
  final double petrolPrice;
  final double dieselPrice;
  final String fuelPriceLastUpdated;

  GetDashboardModel({
    required this.userEmail,
    required this.statusCounts,
    required this.alertsSummary,
    required this.maintenance,
    required this.petrolPrice,
    required this.dieselPrice,
    required this.fuelPriceLastUpdated,
  });

  factory GetDashboardModel.fromJson(Map<String, dynamic> json) {
    return GetDashboardModel(
      userEmail: (json["user_email"] ?? "").toString(),
      statusCounts:
          StatusCounts.fromJson(json["status_counts"] ?? <String, dynamic>{}),
      alertsSummary:
          AlertsSummary.fromJson(json["alerts_summary"] ?? <String, dynamic>{}),
      maintenance: (json["maintenance"] as List? ?? [])
          .map((e) => MaintenanceItem.fromJson(e ?? {}))
          .toList(),
      petrolPrice: _toDouble(json["petrol_price"]),
      dieselPrice: _toDouble(json["diesel_price"]),
      fuelPriceLastUpdated: (json["fuel_price_last_updated"] ?? "").toString(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}

class StatusCounts {
  final int total;
  final int offline;
  final int expired;
  final int ack;
  final int neverConnected;
  final int online;
  final int idle;

  StatusCounts({
    required this.total,
    required this.offline,
    required this.expired,
    required this.ack,
    required this.neverConnected,
    required this.online,
    required this.idle,
  });

  factory StatusCounts.fromJson(Map<String, dynamic> json) {
    return StatusCounts(
      total: json["total"] ?? 0,
      offline: json["offline"] ?? 0,
      expired: json["expired"] ?? 0,
      ack: json["ack"] ?? 0,
      neverConnected: json["never_connected"] ?? 0,
      online: json["online"] ?? 0,
      idle: json["idle"] ?? 0,
    );
  }
}

class AlertsSummary {
  final int total;
  final int custom;
  final int idleDuration;
  final int ignitionDuration;
  final int moveStart;
  final int offlineDuration;
  final int overSpeed;
  final int overParking;
  final int zoneIn;
  final int zoneOut;

  AlertsSummary({
    required this.total,
    required this.custom,
    required this.idleDuration,
    required this.ignitionDuration,
    required this.moveStart,
    required this.offlineDuration,
    required this.overSpeed,
    required this.overParking,
    required this.zoneIn,
    required this.zoneOut,
  });

  factory AlertsSummary.fromJson(Map<String, dynamic> json) {
    return AlertsSummary(
      total: _toInt(json["total"]),
      custom: _toInt(json["Custom"]),
      idleDuration: _toInt(json["Idle Duration"]),
      ignitionDuration: _toInt(json["Ignition duration"]),
      moveStart: _toInt(json["Move Start"]),
      offlineDuration: _toInt(json["Offline duration"]),
      overSpeed: _toInt(json["Over Speed"]),
      overParking: _toInt(json["Over Parking"]),
      zoneIn: _toInt(json["Zone in"]),
      zoneOut: _toInt(json["Zone out"]),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}

class MaintenanceItem {
  final int deviceId;
  final String device;
  final int serviceId;
  final String name;
  final double interval;
  final String lastService;
  final double current;
  final double percent;
  final double left;
  final String status;
  final String description;
  final String expirationBy;
  final String type;
  final String typeLabel;
  final String unit;
  final String expiresDate;
  final String remindDate;
  final int? daysTotal;
  final int? daysElapsed;
  final int? daysLeft;
  final int expired;

  MaintenanceItem({
    required this.deviceId,
    required this.device,
    required this.serviceId,
    required this.name,
    required this.interval,
    required this.lastService,
    required this.current,
    required this.percent,
    required this.left,
    required this.status,
    required this.description,
    required this.expirationBy,
    required this.type,
    required this.typeLabel,
    required this.unit,
    required this.expiresDate,
    required this.remindDate,
    required this.daysTotal,
    required this.daysElapsed,
    required this.daysLeft,
    required this.expired,
  });

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceItem(
      deviceId: _toInt(json["device_id"]),
      device: (json["device"] ?? "").toString(),
      serviceId: _toInt(json["service_id"]),
      name: (json["name"] ?? "").toString(),
      interval: _toDouble(json["interval"]),
      lastService: (json["last_service"] ?? "").toString(),
      current: _toDouble(json["current"]),
      percent: _toDouble(json["percent"]),
      left: _toDouble(json["left"]),
      status: (json["status"] ?? "").toString(),
      description: (json["description"] ?? "").toString(),
      expirationBy: (json["expiration_by"] ?? "").toString(),
      type: (json["type"] ?? "").toString(),
      typeLabel: (json["type_label"] ?? "").toString(),
      unit: (json["unit"] ?? "").toString(),
      expiresDate: (json["expires_date"] ?? "").toString(),
      remindDate: (json["remind_date"] ?? "").toString(),
      daysTotal: _toNullableInt(json["days_total"]),
      daysElapsed: _toNullableInt(json["days_elapsed"]),
      daysLeft: _toNullableInt(json["days_left"]),
      expired: _toInt(json["expired"]),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    final parsed = _toInt(value);
    if (value.toString().trim().isEmpty) return null;
    return parsed;
  }
}
