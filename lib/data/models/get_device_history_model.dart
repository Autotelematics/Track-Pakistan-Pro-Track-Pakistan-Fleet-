import 'dart:convert';

GetDeviceHistoryModel getDeviceHistoryModelFromJson(String str) =>
    GetDeviceHistoryModel.fromJson(json.decode(str));

String getDeviceHistoryModelToJson(GetDeviceHistoryModel data) =>
    json.encode(data.toJson());

class GetDeviceHistoryModel {
  final Device device;
  final HistorySummary summary;
  final List<HistoryItem> history;

  GetDeviceHistoryModel({
    required this.device,
    required this.summary,
    required this.history,
  });

  factory GetDeviceHistoryModel.fromJson(Map<String, dynamic> json) =>
      GetDeviceHistoryModel(
        device: Device.fromJson((json["device"] is Map<String, dynamic>)
            ? json["device"] as Map<String, dynamic>
            : <String, dynamic>{}),
        summary: HistorySummary.fromJson((json["summary"] is Map<String, dynamic>)
            ? json["summary"] as Map<String, dynamic>
            : <String, dynamic>{}),
        history: List<HistoryItem>.from(
            ((json["History"] is List) ? json["History"] : const <dynamic>[])
                .whereType<Map<String, dynamic>>()
                .map((x) => HistoryItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "device": device.toJson(),
    "summary": summary.toJson(),
    "History": List<dynamic>.from(history.map((x) => x.toJson())),
  };
}

class Device {
  final int id;
  final String name;
  final String engineType;
  final String fuelQuantity;
  final double totalDistance;

  Device({
    required this.id,
    required this.name,
    required this.engineType,
    required this.fuelQuantity,
    required this.totalDistance,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    id: _asInt(json["id"]),
    name: _asString(json["name"]),
    engineType: _asString(json["engine_type"]),
    fuelQuantity: _asString(json["fuel_quantity"]),
    totalDistance: _asDouble(json["total_distance"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "engine_type": engineType,
    "fuel_quantity": fuelQuantity,
    "total_distance": totalDistance,
  };
}

class HistorySummary {
  final String totalDistance;
  final String topSpeed;
  final String moveDuration;
  final String stopDuration1;
  final String stopDuration2;
  final int totalTrips;
  final FuelPrices fuelPrices;
  final FuelSpent fuelSpent;

  HistorySummary({
    required this.totalDistance,
    required this.topSpeed,
    required this.moveDuration,
    required this.stopDuration1,
    required this.stopDuration2,
    required this.totalTrips,
    required this.fuelPrices,
    required this.fuelSpent,
  });

  factory HistorySummary.fromJson(Map<String, dynamic> json) => HistorySummary(
    totalDistance: _asString(json["Total Distance"]),
    topSpeed: _asString(json["Top Speed"]),
    moveDuration: _asString(json["Move Duration"]),
    stopDuration1: _asString(json["Stop Duration 1"]),
    stopDuration2: _asString(json["Stop Duration 2"]),
    totalTrips: _asInt(json["Total Trips"]),
    fuelPrices: FuelPrices.fromJson((json["Fuel Prices"] is Map<String, dynamic>)
        ? json["Fuel Prices"] as Map<String, dynamic>
        : <String, dynamic>{}),
    fuelSpent: FuelSpent.fromJson((json["Fuel Spent"] is Map<String, dynamic>)
        ? json["Fuel Spent"] as Map<String, dynamic>
        : <String, dynamic>{}),
  );

  Map<String, dynamic> toJson() => {
    "Total Distance": totalDistance,
    "Top Speed": topSpeed,
    "Move Duration": moveDuration,
    "Stop Duration 1": stopDuration1,
    "Stop Duration 2": stopDuration2,
    "Total Trips": totalTrips,
    "Fuel Prices": fuelPrices.toJson(),
    "Fuel Spent": fuelSpent.toJson(),
  };
}

class FuelPrices {
  final double petrolPrice;
  final double dieselPrice;
  final String fuelPriceLastUpdated;

  FuelPrices({
    required this.petrolPrice,
    required this.dieselPrice,
    required this.fuelPriceLastUpdated,
  });

  factory FuelPrices.fromJson(Map<String, dynamic> json) => FuelPrices(
    petrolPrice: _asDouble(json["petrol_price"]),
    dieselPrice: _asDouble(json["diesel_price"]),
    fuelPriceLastUpdated: _asString(json["fuel_price_last_updated"]),
  );

  Map<String, dynamic> toJson() => {
    "petrol_price": petrolPrice,
    "diesel_price": dieselPrice,
    "fuel_price_last_updated": fuelPriceLastUpdated,
  };
}

class FuelSpent {
  final double totalFuelSpent;
  final double totalFuelCost;

  FuelSpent({
    required this.totalFuelSpent,
    required this.totalFuelCost,
  });

  factory FuelSpent.fromJson(Map<String, dynamic> json) => FuelSpent(
    totalFuelSpent: _asDouble(json["Total Fuel Spent"]),
    totalFuelCost: _asDouble(json["Total Fuel Cost"]),
  );

  Map<String, dynamic> toJson() => {
    "Total Fuel Spent": totalFuelSpent,
    "Total Fuel Cost": totalFuelCost,
  };
}

// New Driver class to handle driver object
class Driver {
  final int? id;
  final int? userId;
  final int? deviceId;
  final String? devicePort;
  final String? name;
  final String? rfid;
  final String? phone;
  final String? email;
  final String? description;
  final String? createdAt;

  Driver({
    this.id,
    this.userId,
    this.deviceId,
    this.devicePort,
    this.name,
    this.rfid,
    this.phone,
    this.email,
    this.description,
    this.createdAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: _asNullableInt(json["id"]),
    userId: _asNullableInt(json["user_id"]),
    deviceId: _asNullableInt(json["device_id"]),
    devicePort: _asNullableString(json["device_port"]),
    name: _asNullableString(json["name"]),
    rfid: _asNullableString(json["rfid"]),
    phone: _asNullableString(json["phone"]),
    email: _asNullableString(json["email"]),
    description: _asNullableString(json["description"]),
    createdAt: _asNullableString(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "device_id": deviceId,
    "device_port": devicePort,
    "name": name,
    "rfid": rfid,
    "phone": phone,
    "email": email,
    "description": description,
    "created_at": createdAt,
  };
}

class HistoryItem {
  final int status;
  final String? name;
  final String rawTime;
  final double distance;
  final Driver? driver; // Changed from String? to Driver?
  final String? time;
  final String? left;
  final int? timeSeconds;
  final int? topSpeed;
  final int? averageSpeed;
  final String? message;
  final List<LocationItem> items;

  HistoryItem({
    required this.status,
    this.name,
    required this.rawTime,
    required this.distance,
    this.driver,
    this.time,
    this.left,
    this.timeSeconds,
    this.topSpeed,
    this.averageSpeed,
    this.message,
    required this.items,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    // Handle driver field - can be null, Map, or String
    Driver? driverObj;
    if (json["driver"] != null) {
      if (json["driver"] is Map<String, dynamic>) {
        driverObj = Driver.fromJson(json["driver"]);
      }
      // If it's a String or other type, leave it as null
    }

    return HistoryItem(
      status: _asInt(json["status"]),
      name: _asNullableString(json["name"]),
      rawTime: _asString(json["raw_time"]),
      distance: _asDouble(json["distance"]),
      driver: driverObj,
      time: _asNullableString(json["time"]),
      left: _asNullableString(json["left"]),
      timeSeconds: _asNullableInt(json["time_seconds"]),
      topSpeed: _asNullableInt(json["top_speed"]),
      averageSpeed: _asNullableInt(json["average_speed"]),
      message: _asNullableString(json["message"]),
      items: List<LocationItem>.from(
          ((json["items"] is List) ? json["items"] : const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map((x) => LocationItem.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "name": name,
    "raw_time": rawTime,
    "distance": distance,
    "driver": driver?.toJson(),
    "time": time,
    "left": left,
    "time_seconds": timeSeconds,
    "top_speed": topSpeed,
    "average_speed": averageSpeed,
    "message": message,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class LocationItem {
  final int? id;
  final String? rawTime;
  final int? altitude;
  final int? course;
  final int speed;
  final double lat;
  final double lng;
  final double distance;
  final int? valid;
  final String? other;
  final String? time;

  LocationItem({
    this.id,
    this.rawTime,
    this.altitude,
    this.course,
    required this.speed,
    required this.lat,
    required this.lng,
    required this.distance,
    this.valid,
    this.other,
    this.time,
  });

  factory LocationItem.fromJson(Map<String, dynamic> json) => LocationItem(
    id: _asNullableInt(json["id"]),
    rawTime: _asNullableString(json["raw_time"]),
    altitude: _asNullableInt(json["altitude"]),
    course: _asNullableInt(json["course"]),
    speed: _asInt(json["speed"]),
    lat: _parseLatLng(json["lat"]),
    lng: _parseLatLng(json["lng"]),
    distance: _asDouble(json["distance"]),
    valid: _asNullableInt(json["valid"]),
    other: _asNullableString(json["other"]),
    time: _asNullableString(json["time"]),
  );

  static double _parseLatLng(dynamic value) {
    if (value is Map<String, dynamic>) {
      return _asDouble(value['value']);
    }
    return _asDouble(value);
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "raw_time": rawTime,
    "altitude": altitude,
    "course": course,
    "speed": speed,
    "lat": lat,
    "lng": lng,
    "distance": distance,
    "valid": valid,
    "other": other,
    "time": time,
  };
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  if (value is Map<String, dynamic>) {
    for (final key in const ['text', 'value', 'label', 'name']) {
      final nested = value[key];
      if (nested is String && nested.trim().isNotEmpty) return nested;
    }
    return jsonEncode(value);
  }
  if (value is List) return value.join(', ');
  return value.toString();
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final parsed = _asString(value).trim();
  return parsed.isEmpty ? null : parsed;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  final parsed = _asInt(value, fallback: -2147483648);
  return parsed == -2147483648 ? null : parsed;
}

double _asDouble(dynamic value, {double fallback = 0.0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}
