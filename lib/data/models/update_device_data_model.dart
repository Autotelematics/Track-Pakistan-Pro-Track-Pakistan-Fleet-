import 'dart:convert';

UpdateDeviceDataModel updateDeviceDataModelFromJson(String str) =>
    UpdateDeviceDataModel.fromJson(json.decode(str) as Map<String, dynamic>);

String updateDeviceDataModelToJson(UpdateDeviceDataModel data) =>
    json.encode(data.toJson());

class UpdateDeviceDataModel {
  final int status;
  final String message;
  final int? deviceId;
  final String? kmPerLiter;
  final String? engineType;
  final String? vehicleType;
  final UpdatedDriver? driver;

  UpdateDeviceDataModel({
    required this.status,
    required this.message,
    this.deviceId,
    this.kmPerLiter,
    this.engineType,
    this.vehicleType,
    this.driver,
  });

  factory UpdateDeviceDataModel.fromJson(Map<String, dynamic> json) =>
      UpdateDeviceDataModel(
        status: (json["status"] as num?)?.toInt() ?? 0,
        message: (json["message"] ?? "").toString(),
        deviceId: (json["device_id"] as num?)?.toInt(),
        kmPerLiter: json["km_per_liter"]?.toString(),
        engineType: json["engine_type"]?.toString(),
        vehicleType: json["vehicle_type"]?.toString(),
        driver: json["driver"] is Map<String, dynamic>
            ? UpdatedDriver.fromJson(json["driver"] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "device_id": deviceId,
        "km_per_liter": kmPerLiter,
        "engine_type": engineType,
        "vehicle_type": vehicleType,
        "driver": driver?.toJson(),
      };
}

class UpdatedDriver {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? rfid;
  final String? description;

  UpdatedDriver({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.rfid,
    this.description,
  });

  factory UpdatedDriver.fromJson(Map<String, dynamic> json) => UpdatedDriver(
        id: (json["id"] as num?)?.toInt(),
        name: json["name"]?.toString(),
        phone: json["phone"]?.toString(),
        email: json["email"]?.toString(),
        rfid: json["rfid"]?.toString(),
        description: json["description"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "rfid": rfid,
        "description": description,
      };
}
