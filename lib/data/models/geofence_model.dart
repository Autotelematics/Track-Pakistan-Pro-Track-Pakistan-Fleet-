import 'dart:convert';

GetGeofencesModel getGeofencesModelFromJson(String str) =>
    GetGeofencesModel.fromJson(json.decode(str));

String getGeofencesModelToJson(GetGeofencesModel data) =>
    json.encode(data.toJson());

class GetGeofencesModel {
  final int? status;
  final List<Geofence>? geofences;

  GetGeofencesModel({
    this.status,
    this.geofences,
  });

  factory GetGeofencesModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? geofencesList = json['items']?['geofences'] as List<dynamic>?;

    final List<Geofence> parsedGeofences = geofencesList == null
        ? []
        : geofencesList
        .map((e) => Geofence.fromJson(e as Map<String, dynamic>))
        .toList();

    return GetGeofencesModel(
      status: json['status'] as int?,
      geofences: parsedGeofences,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'items': {
      'geofences': geofences?.map((e) => e.toJson()).toList(),
    },
  };
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

class Geofence {
  final int id;
  final int userId;
  final int groupId;
   bool active;
  final String name;
  final String polygonColor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String type;
  final double? radius;
  final LatLng? center;
  final List<LatLng> points;
  final dynamic deviceId;

  Geofence({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.active,
    required this.name,
    required this.polygonColor,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
    this.radius,
    this.center,
    required this.points,
    this.deviceId,
  });

  factory Geofence.fromJson(Map<String, dynamic> json) {
    final String type = json['type'] as String? ?? 'circle';

    // Parse center and radius for circle
    LatLng? center;
    double? radius;
    if (type == 'circle') {
      final Map<String, dynamic>? centerJson = json['center'] as Map<String, dynamic>?;
      if (centerJson != null) {
        final double? lat = double.tryParse(centerJson['lat']?.toString() ?? '');
        final double? lng = double.tryParse(centerJson['lng']?.toString() ?? '');
        if (lat != null && lng != null) {
          center = LatLng(lat, lng);
        }
      }
      final int? radiusInt = json['radius'] as int?;
      radius = radiusInt?.toDouble();
    }

    // Parse polygon points
    List<LatLng> points = [];
    if (type == 'polygon') {
      final String coordsStr = json['coordinates'] as String? ?? '[]';
      if (coordsStr.isNotEmpty && coordsStr != '[]') {
        try {
          final List<dynamic> decoded = jsonDecode(coordsStr);
          points = decoded.map<LatLng>((item) {
            final Map<String, dynamic> pointMap = item as Map<String, dynamic>;
            final double? lat = double.tryParse(pointMap['lat'].toString());
            final double? lng = double.tryParse(pointMap['lng'].toString());
            if (lat == null || lng == null) {
              throw Exception('Invalid coordinates');
            }
            return LatLng(lat, lng);
          }).toList();
        } catch (e) {
          // If parsing fails, keep empty list
          points = [];
        }
      }
    }

    // Parse dates
    final DateTime createdAt = DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.now();
    final DateTime updatedAt = DateTime.tryParse(json['updated_at'] as String? ?? '') ??
        DateTime.now();

    return Geofence(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      groupId: json['group_id'] as int,
      active: (json['active'] as int? ?? 0) == 1,
      name: json['name'] as String? ?? '',
      polygonColor: json['polygon_color'] as String? ?? '#000000',
      createdAt: createdAt,
      updatedAt: updatedAt,
      type: type,
      radius: radius,
      center: center,
      points: points,
      deviceId: json['device_id'],
    );
  }

  Map<String, dynamic> toJson() {
    // Reconstruct coordinates string for polygon
    final String coordinates = type == 'polygon' && points.isNotEmpty
        ? jsonEncode(points.map((p) => {
      'lat': p.latitude,
      'lng': p.longitude,
    }).toList())
        : '[]';

    // Reconstruct center map for circle (as strings like API)
    final Map<String, String>? centerMap = type == 'circle' && center != null
        ? {
      'lat': center!.latitude.toString(),
      'lng': center!.longitude.toString(),
    }
        : null;

    return {
      'id': id,
      'user_id': userId,
      'group_id': groupId,
      'active': active ? 1 : 0,
      'name': name,
      'coordinates': coordinates,
      'polygon_color': polygonColor,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'type': type,
      'radius': radius?.toInt(),
      'center': centerMap,
      'device_id': deviceId,
    };
  }
}