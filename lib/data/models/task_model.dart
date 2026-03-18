class TaskWaypoint {
  final int id;
  final int sortOrder;
  final String address;
  final double lat;
  final double lng;
  final String reachedAt;
  final String leftAt;

  const TaskWaypoint({
    required this.address,
    required this.lat,
    required this.lng,
    this.reachedAt = '',
    this.leftAt = '',
    this.id = 0,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'address': address.trim(),
      'lat': lat,
      'lng': lng,
    };
  }

  factory TaskWaypoint.fromJson(Map<String, dynamic> json) {
    return TaskWaypoint(
      id: _toInt(json['id']),
      sortOrder: _toInt(json['sort_order']),
      address: _toText(json['address']),
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lng']),
      reachedAt: _toText(json['reached_at']),
      leftAt: _toText(json['left_at']),
    );
  }
}

class TaskLocation {
  final String address;
  final double lat;
  final double lng;
  final String timeFrom;
  final String timeTo;
  final String reachedAt;
  final String leftAt;

  const TaskLocation({
    String? address,
    double? lat,
    double? lng,
    String? timeFrom,
    String? timeTo,
    String? reachedAt,
    String? leftAt,
  })  : address = address ?? '',
        lat = lat ?? 0,
        lng = lng ?? 0,
        timeFrom = timeFrom ?? '',
        timeTo = timeTo ?? '',
        reachedAt = reachedAt ?? '',
        leftAt = leftAt ?? '';

  factory TaskLocation.fromJson(Map<String, dynamic> json) {
    return TaskLocation(
      address: _toText(json['address']),
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lng']),
      timeFrom: _toText(json['time_from']),
      timeTo: _toText(json['time_to']),
      reachedAt: _toText(json['reached_at']),
      leftAt: _toText(json['left_at']),
    );
  }
}

class TaskDevice {
  final int id;
  final String name;
  final String imei;

  const TaskDevice({
    required this.id,
    required this.name,
    required this.imei,
  });

  factory TaskDevice.fromJson(Map<String, dynamic> json) {
    return TaskDevice(
      id: _toInt(json['id']),
      name: _toText(json['name']),
      imei: _toText(json['imei']),
    );
  }
}

class TaskUpsertPayload {
  final String title;
  final int deviceId;
  final int? priority;
  final String invoiceNumber;
  final String comment;
  final String pickupAddress;
  final double pickupAddressLat;
  final double pickupAddressLng;
  final String deliveryAddress;
  final double deliveryAddressLat;
  final double deliveryAddressLng;
  final List<TaskWaypoint> waypoints;

  const TaskUpsertPayload({
    required this.title,
    required this.deviceId,
    this.priority,
    required this.invoiceNumber,
    required this.comment,
    required this.pickupAddress,
    required this.pickupAddressLat,
    required this.pickupAddressLng,
    required this.deliveryAddress,
    required this.deliveryAddressLat,
    required this.deliveryAddressLng,
    this.waypoints = const <TaskWaypoint>[],
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title.trim(),
      'device_id': deviceId,
      if (priority != null) 'priority': priority,
      'invoice_number': invoiceNumber.trim(),
      'comment': comment.trim(),
      'pickup_address': pickupAddress.trim(),
      'pickup_address_lat': pickupAddressLat,
      'pickup_address_lng': pickupAddressLng,
      'delivery_address': deliveryAddress.trim(),
      'delivery_address_lat': deliveryAddressLat,
      'delivery_address_lng': deliveryAddressLng,
      'waypoints': waypoints.map((item) => item.toJson()).toList(),
    };
  }
}

class TaskItem {
  final int id;
  final String title;
  final String comment;
  final String invoiceNumber;
  final int status;
  final String statusName;
  final int priority;
  final String priorityName;
  final TaskDevice? device;
  final TaskLocation? pickup;
  final TaskLocation? delivery;
  final List<TaskWaypoint> waypoints;
  final DateTime? createdAt;

  const TaskItem({
    required this.id,
    required this.title,
    required this.comment,
    required this.invoiceNumber,
    required this.status,
    required this.statusName,
    required this.priority,
    required this.priorityName,
    required this.device,
    required this.pickup,
    required this.delivery,
    required this.waypoints,
    required this.createdAt,
  });

  bool get hasStops => waypoints.isNotEmpty;
  String get vehicleName =>
      device?.name.trim().isNotEmpty == true ? device!.name.trim() : '-';

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    final List<TaskWaypoint> mappedWaypoints;
    final dynamic rawWaypoints = json['waypoints'];
    if (rawWaypoints is List) {
      mappedWaypoints = rawWaypoints
          .whereType<Map>()
          .map((item) => TaskWaypoint.fromJson(_normalizeMap(item)))
          .toList();
    } else {
      mappedWaypoints = <TaskWaypoint>[];
    }

    TaskDevice? mappedDevice;
    final dynamic rawDevice = json['device'];
    if (rawDevice is Map) {
      mappedDevice = TaskDevice.fromJson(_normalizeMap(rawDevice));
    }

    TaskLocation? mappedPickup;
    final dynamic rawPickup = json['pickup'];
    if (rawPickup is Map) {
      mappedPickup = TaskLocation.fromJson(_normalizeMap(rawPickup));
    }

    TaskLocation? mappedDelivery;
    final dynamic rawDelivery = json['delivery'];
    if (rawDelivery is Map) {
      mappedDelivery = TaskLocation.fromJson(_normalizeMap(rawDelivery));
    }

    return TaskItem(
      id: _toInt(json['id']),
      title: _toText(json['title']),
      comment: _toText(json['comment']),
      invoiceNumber: _toText(json['invoice_number']),
      status: _toInt(json['status']),
      statusName: _toText(json['status_name']),
      priority: _toInt(json['priority']),
      priorityName: _toText(json['priority_name']),
      device: mappedDevice,
      pickup: mappedPickup,
      delivery: mappedDelivery,
      waypoints: mappedWaypoints,
      createdAt: _tryParseDateTime(json['created_at']),
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

class TaskActionResult {
  final bool success;
  final String message;

  const TaskActionResult({
    required this.success,
    required this.message,
  });
}

class TaskListPage {
  final List<TaskItem> items;
  final int count;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final int from;
  final int to;

  const TaskListPage({
    required this.items,
    required this.count,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  bool get hasMore => currentPage < lastPage;

  factory TaskListPage.fromJson(Map<String, dynamic> json) {
    final dynamic rawList =
        json['data'] ?? json['items'] ?? json['tasks'] ?? json['list'];
    final List<TaskItem> parsedItems;
    if (rawList is List) {
      parsedItems = rawList.whereType<Map>().map((item) {
        final normalized = <String, dynamic>{};
        item.forEach((key, value) {
          if (key == null) return;
          normalized[key.toString()] = value;
        });
        return TaskItem.fromJson(normalized);
      }).toList(growable: false);
    } else {
      parsedItems = const <TaskItem>[];
    }

    return TaskListPage(
      items: parsedItems,
      count: _toInt(json['count']),
      total: _toInt(json['total']),
      perPage: _toInt(json['per_page']),
      currentPage:
          _toInt(json['current_page']) <= 0 ? 1 : _toInt(json['current_page']),
      lastPage: _toInt(json['last_page']) <= 0 ? 1 : _toInt(json['last_page']),
      from: _toInt(json['from']),
      to: _toInt(json['to']),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  final String text = value?.toString() ?? '';
  final int? asInt = int.tryParse(text);
  if (asInt != null) return asInt;
  final double? asDouble = double.tryParse(text);
  if (asDouble != null) return asDouble.toInt();
  return 0;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _tryParseDateTime(dynamic value) {
  if (value == null) return null;
  final String text = _toText(value);
  if (text.isEmpty) return null;
  final DateTime? direct = DateTime.tryParse(text);
  if (direct != null) return direct;

  // API format example: 2026-03-08 18:26:34
  final DateTime? spaced = DateTime.tryParse(text.replaceFirst(' ', 'T'));
  return spaced;
}

String _toText(dynamic value) {
  if (value == null) return '';
  final text = value.toString().trim();
  if (text.toLowerCase() == 'null') return '';
  return text;
}
