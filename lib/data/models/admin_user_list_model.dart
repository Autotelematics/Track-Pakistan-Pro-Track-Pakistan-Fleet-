class AdminUserListModel {
  final int status;
  final String title;
  final List<AdminUserItem> items;
  final AdminPagination pagination;

  const AdminUserListModel({
    required this.status,
    required this.title,
    required this.items,
    required this.pagination,
  });

  factory AdminUserListModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json["items"] as List? ?? const [];
    return AdminUserListModel(
      status: _toInt(json["status"]),
      title: (json["title"] ?? "User List").toString(),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(AdminUserItem.fromJson)
          .toList(),
      pagination: AdminPagination.fromJson(
        (json["pagination"] as Map<String, dynamic>? ?? {}),
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? "") ?? 0;
  }
}

class AdminPagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  const AdminPagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory AdminPagination.fromJson(Map<String, dynamic> json) {
    return AdminPagination(
      total: _toInt(json["total"]),
      perPage: _toInt(json["per_page"]),
      currentPage: _toInt(json["current_page"], fallback: 1),
      lastPage: _toInt(json["last_page"], fallback: 1),
    );
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? "") ?? fallback;
  }
}

class AdminUserItem {
  final int userId;
  final String userEmail;
  final int activeStatus;
  final String userType;
  final String manager;
  final int totalDevices;
  final int? devicesLimit;
  final String expirationDate;
  final String lastLogin;

  const AdminUserItem({
    required this.userId,
    required this.userEmail,
    required this.activeStatus,
    required this.userType,
    required this.manager,
    required this.totalDevices,
    required this.devicesLimit,
    required this.expirationDate,
    required this.lastLogin,
  });

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    return AdminUserItem(
      userId: _toInt(json["user_id"]),
      userEmail: (json["user_email"] ?? "-").toString(),
      activeStatus: _toInt(json["active_status"]),
      userType: (json["user_type"] ?? "-").toString(),
      manager: (json["manager"] ?? "-").toString(),
      totalDevices: _toInt(json["total_devices"]),
      devicesLimit: _toNullableInt(json["devices_limit"]),
      expirationDate: (json["expiration_date"] ?? "-").toString(),
      lastLogin: (json["last_login"] ?? "-").toString(),
    );
  }

  bool get isActive => activeStatus == 1;

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? "") ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
