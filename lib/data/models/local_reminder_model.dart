class LocalReminder {
  final int id;
  final int deviceId;
  final String vehicleName;
  final String title;
  final String type;
  final String description;
  final DateTime dueAt;
  final bool isRecurring;
  final String repeatType;
  final DateTime createdAt;

  const LocalReminder({
    required this.id,
    required this.deviceId,
    required this.vehicleName,
    required this.title,
    required this.type,
    required this.description,
    required this.dueAt,
    required this.isRecurring,
    required this.repeatType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "deviceId": deviceId,
      "vehicleName": vehicleName,
      "title": title,
      "type": type,
      "description": description,
      "dueAt": dueAt.toIso8601String(),
      "isRecurring": isRecurring,
      "repeatType": repeatType,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  factory LocalReminder.fromMap(Map<String, dynamic> map) {
    return LocalReminder(
      id: map["id"] as int,
      deviceId: (map["deviceId"] ?? 0) as int,
      vehicleName: (map["vehicleName"] ?? "Vehicle") as String,
      title: (map["title"] ?? "") as String,
      type: (map["type"] ?? "Custom") as String,
      description: (map["description"] ?? "") as String,
      dueAt: DateTime.parse(map["dueAt"] as String),
      isRecurring: (map["isRecurring"] ?? false) as bool,
      repeatType: (map["repeatType"] ??
              ((map["isRecurring"] ?? false) ? "daily" : "none"))
          as String,
      createdAt: DateTime.parse(map["createdAt"] as String),
    );
  }
}
