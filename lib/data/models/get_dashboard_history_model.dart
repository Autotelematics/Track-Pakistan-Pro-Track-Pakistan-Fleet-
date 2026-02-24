
import 'dart:convert';

GetDashboardHistoryModel getDashboardHistoryModelFromJson(String str) => GetDashboardHistoryModel.fromJson(json.decode(str));

String getDashboardHistoryModelToJson(GetDashboardHistoryModel data) => json.encode(data.toJson());

class GetDashboardHistoryModel {
  final Summary summary;
  final List<Vehicle> vehicles;

  GetDashboardHistoryModel({
    required this.summary,
    required this.vehicles,
  });

  factory GetDashboardHistoryModel.fromJson(Map<String, dynamic> json) => GetDashboardHistoryModel(
    summary: Summary.fromJson(json["summary"]),
    vehicles: List<Vehicle>.from(json["vehicles"].map((x) => Vehicle.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "summary": summary.toJson(),
    "vehicles": List<dynamic>.from(vehicles.map((x) => x.toJson())),
  };
}

class Summary {
  final double totalDistanceKm;
  final double averageDistanceKm;
  final List<TopSpeed> topSpeeds;
  final List<TopDistance> topDistance;

  Summary({
    required this.totalDistanceKm,
    required this.averageDistanceKm,
    required this.topSpeeds,
    required this.topDistance,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    totalDistanceKm: json["total_distance_km"]?.toDouble(),
    averageDistanceKm: json["average_distance_km"]?.toDouble(),
    topSpeeds: List<TopSpeed>.from(json["top_speeds"].map((x) => TopSpeed.fromJson(x))),
    topDistance: List<TopDistance>.from(json["top_distance"].map((x) => TopDistance.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total_distance_km": totalDistanceKm,
    "average_distance_km": averageDistanceKm,
    "top_speeds": List<dynamic>.from(topSpeeds.map((x) => x.toJson())),
    "top_distance": List<dynamic>.from(topDistance.map((x) => x.toJson())),
  };
}

class TopDistance {
  final int deviceId;
  final String deviceName;
  final double distanceKm;

  TopDistance({
    required this.deviceId,
    required this.deviceName,
    required this.distanceKm,
  });

  factory TopDistance.fromJson(Map<String, dynamic> json) => TopDistance(
    deviceId: json["device_id"],
    deviceName: json["device_name"],
    distanceKm: json["distance_km"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "device_id": deviceId,
    "device_name": deviceName,
    "distance_km": distanceKm,
  };
}

class TopSpeed {
  final int deviceId;
  final String deviceName;
  final int topSpeedKph;

  TopSpeed({
    required this.deviceId,
    required this.deviceName,
    required this.topSpeedKph,
  });

  factory TopSpeed.fromJson(Map<String, dynamic> json) => TopSpeed(
    deviceId: json["device_id"],
    deviceName: json["device_name"],
    topSpeedKph: json["top_speed_kph"],
  );

  Map<String, dynamic> toJson() => {
    "device_id": deviceId,
    "device_name": deviceName,
    "top_speed_kph": topSpeedKph,
  };
}

class Vehicle {
  final int deviceId;
  final String deviceName;
  final History history;

  Vehicle({
    required this.deviceId,
    required this.deviceName,
    required this.history,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    deviceId: json["device_id"],
    deviceName: json["device_name"],
    history: History.fromJson(json["history"]),
  );

  Map<String, dynamic> toJson() => {
    "device_id": deviceId,
    "device_name": deviceName,
    "history": history.toJson(),
  };
}

class History {
  final String distanceSum;
  final String topSpeed;
  final String moveDuration;
  final String stopDuration;

  History({
    required this.distanceSum,
    required this.topSpeed,
    required this.moveDuration,
    required this.stopDuration,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
    distanceSum: json["distance_sum"],
    topSpeed: json["top_speed"],
    moveDuration: json["move_duration"],
    stopDuration: json["stop_duration"],
  );

  Map<String, dynamic> toJson() => {
    "distance_sum": distanceSum,
    "top_speed": topSpeed,
    "move_duration": moveDuration,
    "stop_duration": stopDuration,
  };
}