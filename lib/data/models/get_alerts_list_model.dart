// lib/data/models/get_alerts_list_model.dart

import 'dart:convert';

GetAlertsModel getAlertsModelFromJson(String str) =>
    GetAlertsModel.fromJson(json.decode(str));

String getAlertsModelToJson(GetAlertsModel data) => json.encode(data.toJson());

class GetAlertsModel {
  final int status;
  final int page;
  final int perPage;
  final int total;
  final Map<String, int> counts;
  final List<Item> items;
  final dynamic message;

  GetAlertsModel({
    required this.status,
    required this.page,
    required this.perPage,
    required this.total,
    required this.counts,
    required this.items,
    required this.message,
  });

  factory GetAlertsModel.fromJson(Map<String, dynamic> json) {
    final itemsData = json["items"];

    List<Item> parsedItems = [];
    int page = 1;
    int perPage = 10;
    int total = 0;
    Map<String, int> counts = {};

    if (itemsData != null) {
      if (itemsData is Map<String, dynamic>) {
        // Normal API response with pagination
        page = itemsData["current_page"] ?? 1;
        perPage = itemsData["per_page"] ?? 10;
        total = itemsData["total"] ?? 0;
        counts = _safeParseCounts(itemsData["counts"]);

        if (itemsData["data"] != null && itemsData["data"] is List) {
          parsedItems = List<Item>.from(
            (itemsData["data"] as List).map((x) => Item.fromJson(x)),
          );
        }
      } else if (itemsData is List) {
        // API returns a list directly
        parsedItems = List<Item>.from(itemsData.map((x) => Item.fromJson(x)));
      }
    }

    return GetAlertsModel(
      status: json["status"] ?? 0,
      page: page,
      perPage: perPage,
      total: total,
      counts: counts,
      items: parsedItems,
      message: json["message"],
    );
  }

  static Map<String, int> _safeParseCounts(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map<String, dynamic>) {
      return raw.map((key, value) => MapEntry(key, (value as num).toInt()));
    }
    return {};
  }

  GetAlertsModel copyWith({
    int? status,
    int? page,
    int? perPage,
    int? total,
    Map<String, int>? counts,
    List<Item>? items,
    dynamic message,
  }) =>
      GetAlertsModel(
        status: status ?? this.status,
        page: page ?? this.page,
        perPage: perPage ?? this.perPage,
        total: total ?? this.total,
        counts: counts ?? this.counts,
        items: items ?? this.items,
        message: message ?? this.message,
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "page": page,
    "per_page": perPage,
    "total": total,
    "counts": counts,
    "items": {
      "current_page": page,
      "per_page": perPage,
      "total": total,
      "data": items.map((x) => x.toJson()).toList(),
    },
    "message": message,
  };
}

// ---------------- Item Model ----------------

class Item {
  final int id;
  final String type;
  final DateTime? time;
  final String message;
  String address;
  final int course;
  final double latitude;
  final double longitude;
  final int speed;
  final String detail;
  final dynamic geofence;
  final String deviceName;
  final int deviceId;

  Item({
    required this.id,
    required this.type,
    required this.time,
    required this.message,
    required this.address,
    required this.course,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.detail,
    required this.geofence,
    required this.deviceName,
    required this.deviceId,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"] ?? 0,
    type: json["type"] ?? "",
    time: json["time"] != null ? DateTime.tryParse(json["time"]) : null,
    message: json["message"] ?? "",
    address: json["address"] ?? "",
    course: json["course"] ?? 0,
    latitude: (json["latitude"] as num?)?.toDouble() ?? 0.0,
    longitude: (json["longitude"] as num?)?.toDouble() ?? 0.0,
    speed: json["speed"] ?? 0,
    detail: json["detail"] ?? json["name"] ?? "",
    geofence: json["geofence"],
    deviceName: json["device_name"] ?? "Unknown",
    deviceId: json["device_id"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "time": time?.toIso8601String(),
    "message": message,
    "address": address,
    "course": course,
    "latitude": latitude,
    "longitude": longitude,
    "speed": speed,
    "detail": detail,
    "geofence": geofence,
    "device_name": deviceName,
    "device_id": deviceId,
  };
}
