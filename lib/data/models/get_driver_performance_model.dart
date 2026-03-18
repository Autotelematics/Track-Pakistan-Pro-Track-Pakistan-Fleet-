import 'dart:convert';

GetDriverPerformanceModel getDriverPerformanceModelFromJson(String str) =>
    GetDriverPerformanceModel.fromJson(json.decode(str));

class GetDriverPerformanceModel {
  final int status;
  final List<DriverPerformanceItem> driverPerformance;

  const GetDriverPerformanceModel({
    required this.status,
    required this.driverPerformance,
  });

  factory GetDriverPerformanceModel.fromJson(Map<String, dynamic> json) {
    final rawList = json["driver_performance"];
    return GetDriverPerformanceModel(
      status: (json["status"] as num?)?.toInt() ?? 0,
      driverPerformance: rawList is List
          ? rawList
              .whereType<Map<String, dynamic>>()
              .map(DriverPerformanceItem.fromJson)
              .toList()
          : const [],
    );
  }
}

class DriverPerformanceItem {
  final int driverId;
  final String driverName;
  final List<int> vehicleIds;
  final int vehiclesCount;
  final double distanceKm;
  final double engineHours;
  final int idleCount;
  final int idleDurationSec;
  final int overspeedCount;
  final int overspeedDurationSec;
  final int harshBrakeCount;
  final int harshAccelerationCount;
  final double score;
  final String grade;
  final int rank;

  const DriverPerformanceItem({
    required this.driverId,
    required this.driverName,
    required this.vehicleIds,
    required this.vehiclesCount,
    required this.distanceKm,
    required this.engineHours,
    required this.idleCount,
    required this.idleDurationSec,
    required this.overspeedCount,
    required this.overspeedDurationSec,
    required this.harshBrakeCount,
    required this.harshAccelerationCount,
    required this.score,
    required this.grade,
    required this.rank,
  });

  factory DriverPerformanceItem.fromJson(Map<String, dynamic> json) {
    return DriverPerformanceItem(
      driverId: (json["driver_id"] as num?)?.toInt() ?? 0,
      driverName: (json["driver_name"] ?? "").toString(),
      vehicleIds: _parseVehicleIds(json["vehicle_ids"]),
      vehiclesCount: (json["vehicles_count"] as num?)?.toInt() ?? 0,
      distanceKm: (json["distance_km"] as num?)?.toDouble() ?? 0,
      engineHours: (json["engine_hours"] as num?)?.toDouble() ?? 0,
      idleCount: (json["idle_count"] as num?)?.toInt() ?? 0,
      idleDurationSec: (json["idle_duration_sec"] as num?)?.toInt() ?? 0,
      overspeedCount: (json["overspeed_count"] as num?)?.toInt() ?? 0,
      overspeedDurationSec:
          (json["overspeed_duration_sec"] as num?)?.toInt() ?? 0,
      harshBrakeCount: (json["harsh_brake_count"] as num?)?.toInt() ?? 0,
      harshAccelerationCount:
          (json["harsh_acceleration_count"] as num?)?.toInt() ?? 0,
      score: (json["score"] as num?)?.toDouble() ?? 0,
      grade: (json["grade"] ?? "").toString(),
      rank: (json["rank"] as num?)?.toInt() ?? 0,
    );
  }
}

List<int> _parseVehicleIds(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map((e) {
        if (e is int) return e;
        if (e is num) return e.toInt();
        return int.tryParse(e.toString());
      })
      .whereType<int>()
      .toList();
}
