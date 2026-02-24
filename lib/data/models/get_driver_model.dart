import 'dart:convert';

GetDriverModel getDriverModelFromJson(String str) =>
    GetDriverModel.fromJson(json.decode(str));

String getDriverModelToJson(GetDriverModel data) => json.encode(data.toJson());

class GetDriverModel {
  final Items items;
  final int status;

  GetDriverModel({
    required this.items,
    required this.status,
  });

  factory GetDriverModel.fromJson(Map<String, dynamic> json) => GetDriverModel(
    items: Items.fromJson(json["items"]),
    status: json["status"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "items": items.toJson(),
    "status": status,
  };
}

class Items {
  final Drivers drivers;

  Items({
    required this.drivers,
  });

  factory Items.fromJson(Map<String, dynamic> json) => Items(
    drivers: Drivers.fromJson(json["drivers"]),
  );

  Map<String, dynamic> toJson() => {
    "drivers": drivers.toJson(),
  };
}

class Drivers {
  final int currentPage;
  final List<Datum> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final dynamic prevPageUrl;
  final int to;
  final int total;
  final String url;

  Drivers({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
    required this.url,
  });

  factory Drivers.fromJson(Map<String, dynamic> json) => Drivers(
    currentPage: json["current_page"] ?? 0,
    data: (json["data"] as List<dynamic>?)
        ?.map((x) => Datum.fromJson(x))
        .toList() ??
        [],
    firstPageUrl: json["first_page_url"] ?? "",
    from: json["from"] ?? 0,
    lastPage: json["last_page"] ?? 0,
    lastPageUrl: json["last_page_url"] ?? "",
    nextPageUrl: json["next_page_url"],
    path: json["path"] ?? "",
    perPage: json["per_page"] ?? 0,
    prevPageUrl: json["prev_page_url"],
    to: json["to"] ?? 0,
    total: json["total"] ?? 0,
    url: json["url"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": data.map((x) => x.toJson()).toList(),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
    "url": url,
  };
}

class Datum {
  final int id;
  final int userId;
  final String? deviceId;
  final String name;
  final String rfid;
  final String phone;
  final String email;
  final String? description;
  final List<dynamic> createdAt;
  final List<dynamic> updatedAt;
  final dynamic device;

  Datum({
    required this.id,
    required this.userId,
    this.deviceId,
    required this.name,
    required this.rfid,
    required this.phone,
    required this.email,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.device,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] ?? 0,
    userId: json["user_id"] ?? 0,
    deviceId: json["device_id"]?.toString(),
    name: json["name"] ?? "Unknown",
    rfid: json["rfid"] ?? "",
    phone: json["phone"] ?? "",
    email: json["email"] ?? "",
    description: json["description"],
    createdAt: List<dynamic>.from(json["created_at"] ?? []),
    updatedAt: List<dynamic>.from(json["updated_at"] ?? []),
    device: json["device"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "device_id": deviceId,
    "name": name,
    "rfid": rfid,
    "phone": phone,
    "email": email,
    "description": description,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "device": device,
  };
}
