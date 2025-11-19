


class GetDashboardModel {
  final StatusCounts statusCounts;
  final AlertsSummary alertsSummary;
  final List<MaintenanceItem> maintenance;
  final double petrolPrice;
  final double dieselPrice;
  final String fuelPriceLastUpdated;

  GetDashboardModel({
    required this.statusCounts,
    required this.alertsSummary,
    required this.maintenance,
    required this.petrolPrice,
    required this.dieselPrice,
    required this.fuelPriceLastUpdated,
  });

  factory GetDashboardModel.fromJson(Map<String, dynamic> json) {
    return GetDashboardModel(
      statusCounts:
      StatusCounts.fromJson(json["status_counts"] ?? <String, dynamic>{}),
      alertsSummary:
      AlertsSummary.fromJson(json["alerts_summary"] ?? <String, dynamic>{}),
      maintenance: (json["maintenance"] as List? ?? [])
          .map((e) => MaintenanceItem.fromJson(e ?? {}))
          .toList(),
      petrolPrice: (json["petrol_price"] ?? 0).toDouble(),
      dieselPrice: (json["diesel_price"] ?? 0).toDouble(),
      fuelPriceLastUpdated: json["fuel_price_last_updated"] ?? "",
    );
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

  AlertsSummary({
    required this.total,
    required this.custom,
    required this.idleDuration,
    required this.ignitionDuration,
    required this.moveStart,
    required this.offlineDuration,
    required this.overSpeed,
    required this.overParking,
  });

  factory AlertsSummary.fromJson(Map<String, dynamic> json) {
    return AlertsSummary(
      total: json["total"] ?? 0,
      custom: json["Custom"] ?? 0,
      idleDuration: json["Idle Duration"] ?? 0,
      ignitionDuration: json["Ignition duration"] ?? 0,
      moveStart: json["Move Start"] ?? 0,
      offlineDuration: json["Offline duration"] ?? 0,
      overSpeed: json["Over Speed"] ?? 0,
      overParking: json["Over Parking"] ?? 0,
    );
  }
}

class MaintenanceItem {
  final String device;
  final String name;
  final double interval;
  final String lastService;
  final double current;
  final double percent;
  final double left;
  final String status;
  final String description;

  MaintenanceItem({
    required this.device,
    required this.name,
    required this.interval,
    required this.lastService,
    required this.current,
    required this.percent,
    required this.left,
    required this.status,
    required this.description,
  });

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceItem(
      device: json["device"] ?? "",
      name: json["name"] ?? "",
      interval: (json["interval"] ?? 0).toDouble(),
      lastService: json["last_service"] ?? "",
      current: (json["current"] ?? 0).toDouble(),
      percent: (json["percent"] ?? 0).toDouble(),
      left: (json["left"] ?? 0).toDouble(),
      status: json["status"] ?? "",
      description: json["description"] ?? "",
    );
  }
}
