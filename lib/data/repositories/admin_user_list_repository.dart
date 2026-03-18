import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/admin_user_list_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';

class AdminUserListRepository {
  Future<AdminUserListModel?> getAdminUserList({
    required String token,
    String? email,
    int page = 1,
  }) async {
    final search = (email ?? "").trim();
    final url = Uri.parse(
      "${AppUrl.baseURL}${AppUrl.getAdminUserListEp}$token"
      "${search.isNotEmpty ? "&email=${Uri.encodeQueryComponent(search)}" : ""}"
      "&page=$page",
    );
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    return AdminUserListModel.fromJson(decoded);
  }

  Future<AdminUserStatusUpdateResult> setAdminUserStatus({
    required String token,
    required int userId,
    required int status,
  }) async {
    final url =
        Uri.parse("${AppUrl.baseURL}${AppUrl.setAdminUserStatusEp}$token");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "status": status,
      }),
    );

    if (response.statusCode != 200) {
      return const AdminUserStatusUpdateResult(
        success: false,
        message: "Failed to update user status.",
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return const AdminUserStatusUpdateResult(
        success: false,
        message: "Invalid server response.",
      );
    }

    final ok = _toInt(decoded["status"]) == 1;
    final message = (decoded["message"] ?? "").toString();
    int? active;
    final item = decoded["item"];
    if (item is Map<String, dynamic>) {
      active = _toNullableInt(item["active"]);
    }

    return AdminUserStatusUpdateResult(
      success: ok,
      message: message.isEmpty
          ? (ok
              ? "User status updated successfully."
              : "Failed to update user status.")
          : message,
      activeStatus: active,
    );
  }

  Future<AdminLoginAsResult> loginAsUser({
    required String token,
    required int userId,
  }) async {
    final url = Uri.parse("${AppUrl.baseURL}${AppUrl.adminLoginAsEp}$token");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
      }),
    );

    if (response.statusCode != 200) {
      return const AdminLoginAsResult(
        success: false,
        message: "Failed to login as user.",
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return const AdminLoginAsResult(
        success: false,
        message: "Invalid server response.",
      );
    }

    final ok = _toInt(decoded["status"]) == 1;
    final message = (decoded["message"] ?? "").toString().trim();
    return AdminLoginAsResult(
      success: ok,
      message: message.isEmpty
          ? (ok ? "Logged in as user." : "Failed to login as user.")
          : message,
      userApiHash: (decoded["user_api_hash"] ?? "").toString(),
      userId: _toInt(decoded["user_id"]),
      userEmail: (decoded["user_email"] ?? "").toString(),
      userType: (decoded["user_type"] ?? "").toString(),
    );
  }

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

class AdminUserStatusUpdateResult {
  final bool success;
  final String message;
  final int? activeStatus;

  const AdminUserStatusUpdateResult({
    required this.success,
    required this.message,
    this.activeStatus,
  });
}

class AdminLoginAsResult {
  final bool success;
  final String message;
  final String userApiHash;
  final int userId;
  final String userEmail;
  final String userType;

  const AdminLoginAsResult({
    required this.success,
    required this.message,
    this.userApiHash = "",
    this.userId = 0,
    this.userEmail = "",
    this.userType = "",
  });
}
