class AdminStatusModel {
  final int status;
  final AdminDeviceStatus deviceStatus;
  final AdminUsersStatus usersStatus;

  const AdminStatusModel({
    required this.status,
    required this.deviceStatus,
    required this.usersStatus,
  });

  factory AdminStatusModel.fromJson(Map<String, dynamic> json) {
    return AdminStatusModel(
      status: _toInt(json["status"]),
      deviceStatus: AdminDeviceStatus.fromJson(
          (json["device_status"] as Map<String, dynamic>? ?? {})),
      usersStatus: AdminUsersStatus.fromJson(
          (json["users_status"] as Map<String, dynamic>? ?? {})),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? "") ?? 0;
  }
}

class AdminDeviceStatus {
  final int totalCount;
  final int offline;
  final int expired;
  final int neverConnected;
  final int ack;
  final int online;
  final int idle;

  const AdminDeviceStatus({
    required this.totalCount,
    required this.offline,
    required this.expired,
    required this.neverConnected,
    required this.ack,
    required this.online,
    required this.idle,
  });

  factory AdminDeviceStatus.fromJson(Map<String, dynamic> json) {
    return AdminDeviceStatus(
      totalCount: _toInt(json["total_count"]),
      offline: _toInt(json["offline"]),
      expired: _toInt(json["expired"]),
      neverConnected: _toInt(json["never_connected"]),
      ack: _toInt(json["ack"]),
      online: _toInt(json["online"]),
      idle: _toInt(json["idle"]),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? "") ?? 0;
  }
}

class AdminUsersStatus {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;

  const AdminUsersStatus({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
  });

  factory AdminUsersStatus.fromJson(Map<String, dynamic> json) {
    return AdminUsersStatus(
      totalUsers: _toInt(json["total_users"]),
      activeUsers: _toInt(json["active_users"]),
      inactiveUsers: _toInt(json["inactive_users"]),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? "") ?? 0;
  }
}
