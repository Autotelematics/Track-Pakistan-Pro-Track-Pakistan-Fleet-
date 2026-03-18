import 'dart:convert';

GetVehiclePerformanceModel getVehiclePerformanceModelFromJson(String str) =>
    GetVehiclePerformanceModel.fromJson(json.decode(str));

class GetVehiclePerformanceModel {
  final int status;
  final List<VehiclePerformanceItem> vehiclePerformance;

  const GetVehiclePerformanceModel({
    required this.status,
    required this.vehiclePerformance,
  });

  factory GetVehiclePerformanceModel.fromJson(Map<String, dynamic> json) {
    final rawList = json["vehicle_performance"];
    return GetVehiclePerformanceModel(
      status: (json["status"] as num?)?.toInt() ?? 0,
      vehiclePerformance: rawList is List
          ? rawList
              .whereType<Map<String, dynamic>>()
              .map(VehiclePerformanceItem.fromJson)
              .toList()
          : const [],
    );
  }
}

class VehiclePerformanceItem {
  final int vehicleId;
  final String vehicleName;
  final double distanceKm;
  final int idleCount;
  final int idleDurationSec;
  final int overspeedCount;
  final int overspeedDurationSec;
  final double score;

  const VehiclePerformanceItem({
    required this.vehicleId,
    required this.vehicleName,
    required this.distanceKm,
    required this.idleCount,
    required this.idleDurationSec,
    required this.overspeedCount,
    required this.overspeedDurationSec,
    required this.score,
  });

  factory VehiclePerformanceItem.fromJson(Map<String, dynamic> json) {
    return VehiclePerformanceItem(
      vehicleId: (json["vehicle_id"] as num?)?.toInt() ?? 0,
      vehicleName: (json["vehicle_name"] ?? "").toString(),
      distanceKm: (json["distance_km"] as num?)?.toDouble() ?? 0,
      idleCount: (json["idle_count"] as num?)?.toInt() ?? 0,
      idleDurationSec: (json["idle_duration_sec"] as num?)?.toInt() ?? 0,
      overspeedCount: (json["overspeed_count"] as num?)?.toInt() ?? 0,
      overspeedDurationSec:
          (json["overspeed_duration_sec"] as num?)?.toInt() ?? 0,
      score: (json["score"] as num?)?.toDouble() ?? 0,
    );
  }
}
