import 'dart:convert';

List<GetDeviceCommandsModel> getDeviceCommandsModelFromJson(String str) =>
    List<GetDeviceCommandsModel>.from(
        json.decode(str).map((x) => GetDeviceCommandsModel.fromJson(x)));

String getDeviceCommandsModelToJson(List<GetDeviceCommandsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetDeviceCommandsModel {
  final String type;
  final String title;
  final List<Attribute> attributes;

  GetDeviceCommandsModel({
    required this.type,
    required this.title,
    required this.attributes,
  });

  factory GetDeviceCommandsModel.fromJson(Map<String, dynamic> json) =>
      GetDeviceCommandsModel(
        type: json["type"] as String,
        title: json["title"] as String,
        attributes: json["attributes"] == null
            ? []
            : List<Attribute>.from(
            (json["attributes"] as List<dynamic>)
                .map((x) => Attribute.fromJson(x as Map<String, dynamic>))),
      );

  Map<String, dynamic> toJson() => {
    "type": type,
    "title": title,
    "attributes": List<dynamic>.from(attributes.map((x) => x.toJson())),
  };
}

class Attribute {
  final String title;
  final String name;
  final String type;
  final String? validation;
  final String? description;
  final String? defaultValue;

  Attribute({
    required this.title,
    required this.name,
    required this.type,
    this.validation,
    this.description,
    this.defaultValue,
  });

  factory Attribute.fromJson(Map<String, dynamic> json) => Attribute(
    title: json["title"] as String,
    name: json["name"] as String,
    type: json["type"] as String,
    validation: json["validation"] as String?,
    description: json["description"] as String?,
    defaultValue: json["default"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "name": name,
    "type": type,
    if (validation != null) "validation": validation,
    if (description != null) "description": description,
    if (defaultValue != null) "default": defaultValue,
  };
}