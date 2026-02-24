
import 'dart:convert';

GetDeviceGroupModel getDeviceGroupModelFromJson(String str) => GetDeviceGroupModel.fromJson(json.decode(str));

String getDeviceGroupModelToJson(GetDeviceGroupModel data) => json.encode(data.toJson());

class GetDeviceGroupModel {
  final int status;
  final List<GetDeviceGroupModelItem> items;

  GetDeviceGroupModel({
    required this.status,
    required this.items,
  });

  factory GetDeviceGroupModel.fromJson(Map<String, dynamic> json) => GetDeviceGroupModel(
    status: json["status"],
    items: List<GetDeviceGroupModelItem>.from(json["items"].map((x) => GetDeviceGroupModelItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class GetDeviceGroupModelItem {
  final int id;
  final String title;
  final List<ItemItem> items;

  GetDeviceGroupModelItem({
    required this.id,
    required this.title,
    required this.items,
  });

  factory GetDeviceGroupModelItem.fromJson(Map<String, dynamic> json) => GetDeviceGroupModelItem(
    id: json["id"],
    title: json["title"],
    items: List<ItemItem>.from(json["items"].map((x) => ItemItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class ItemItem {
  final int id;
  final String name;

  ItemItem({
    required this.id,
    required this.name,
  });

  factory ItemItem.fromJson(Map<String, dynamic> json) => ItemItem(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}