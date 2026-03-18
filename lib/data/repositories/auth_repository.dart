import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trackerapp/data/repositories/fcm_token_repository.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class AuthRepository {
  static const String mobileAccessDeniedMessage =
      "Sorry you dont have permssion to use this Mobile App, Contact your Service Provider";

  bool _extractSendCommandView(Map<String, dynamic> body) {
    bool? fromPermissions(dynamic permissionsNode) {
      if (permissionsNode is! Map<String, dynamic>) return null;
      final sendCommand = permissionsNode["send_command"];
      if (sendCommand is! Map<String, dynamic>) return null;
      final view = sendCommand["view"];
      if (view is bool) return view;
      if (view is num) return view != 0;
      if (view is String) {
        final t = view.trim().toLowerCase();
        return t == "1" || t == "true" || t == "yes";
      }
      return null;
    }

    final top = fromPermissions(body["permissions"]);
    if (top != null) return top;

    final data = body["data"];
    if (data is Map<String, dynamic>) {
      final nested = fromPermissions(data["permissions"]);
      if (nested != null) return nested;
    }

    // Backward-compatible default: keep command access enabled when missing.
    return true;
  }

  bool _extractCanChangePassword(Map<String, dynamic> body) {
    final topLevelPermissions = body["permissions"];
    if (topLevelPermissions is Map<String, dynamic>) {
      final customerDetails = topLevelPermissions["customer_details"];
      if (customerDetails is Map<String, dynamic>) {
        final value = customerDetails["can_change_password"];
        if (value is bool) return value;
      }
    }

    final data = body["data"];
    if (data is Map<String, dynamic>) {
      final permissions = data["permissions"];
      if (permissions is Map<String, dynamic>) {
        final customerDetails = permissions["customer_details"];
        if (customerDetails is Map<String, dynamic>) {
          final value = customerDetails["can_change_password"];
          if (value is bool) return value;
        }
      }
    }

    return true;
  }

  int? _extractMobileAccess(Map<String, dynamic> body) {
    int? parseValue(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    final topLevelPermissions = body["permissions"];
    if (topLevelPermissions is Map<String, dynamic>) {
      final customerDetails = topLevelPermissions["customer_details"];
      if (customerDetails is Map<String, dynamic>) {
        final parsed = parseValue(customerDetails["mobile_access"]);
        if (parsed != null) return parsed;
      }
    }

    final data = body["data"];
    if (data is Map<String, dynamic>) {
      final permissions = data["permissions"];
      if (permissions is Map<String, dynamic>) {
        final customerDetails = permissions["customer_details"];
        if (customerDetails is Map<String, dynamic>) {
          final parsed = parseValue(customerDetails["mobile_access"]);
          if (parsed != null) return parsed;
        }
      }
    }

    return null;
  }

  int _extractUserId(Map<String, dynamic> body) {
    int? parse(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    final topLevel = parse(body["user_id"]);
    if (topLevel != null) return topLevel;

    final data = body["data"];
    if (data is Map<String, dynamic>) {
      final nested = parse(data["user_id"]);
      if (nested != null) return nested;
    }

    return 0;
  }

  String _extractUserEmail(Map<String, dynamic> body) {
    final topLevel = body["user_email"]?.toString().trim();
    if (topLevel != null && topLevel.isNotEmpty) return topLevel;

    final data = body["data"];
    if (data is Map<String, dynamic>) {
      final nested = data["user_email"]?.toString().trim();
      if (nested != null && nested.isNotEmpty) return nested;
    }

    return "";
  }

  String _extractUserType(Map<String, dynamic> body) {
    final topLevel = body["user_type"]?.toString().trim();
    if (topLevel != null && topLevel.isNotEmpty) return topLevel;

    final data = body["data"];
    if (data is Map<String, dynamic>) {
      final nested = data["user_type"]?.toString().trim();
      if (nested != null && nested.isNotEmpty) return nested;
    }

    return "";
  }

  //Login
  Future<bool> loginApi({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
        "${AppUrl.baseURL}${AppUrl.loginEp}email=$email&password=$password");
    final result = await http.post(url).timeout(const Duration(seconds: 12));
    final body = jsonDecode(result.body);
    if (result.statusCode == 200) {
      if (_extractMobileAccess(body) != 3) {
        throw mobileAccessDeniedMessage;
      }
      await MySharedPreferences.setBool(isLoggedInKey, true);
      await MySharedPreferences.setString(
          authTokenKey, body["user_api_hash"]?.toString() ?? "");
      await MySharedPreferences.setInt(userIdKey, _extractUserId(body));
      await MySharedPreferences.setString(
          userEmailKey, _extractUserEmail(body));
      await MySharedPreferences.setString(userTypeKey, _extractUserType(body));
      await MySharedPreferences.setBool(
          canChangePasswordKey, _extractCanChangePassword(body));
      await MySharedPreferences.setBool(
          canSendCommandViewKey, _extractSendCommandView(body));
      final fcmRepo = FcmTokenRepository();
      await fcmRepo.syncCurrentDeviceToken(force: true);
      await fcmRepo.syncLatestTokenIfAvailable(force: true);
      return true;
    } else {
      throw body["message"] ?? "Something went wrong";
    }
  }

  // change password
  Future<String> changePasswordApi({
    required String oldPassword,
    required String newPassword,
  }) async {
    final token = MySharedPreferences.getString(authTokenKey);
    final url = Uri.parse(
        "${AppUrl.baseURL}${AppUrl.changePasswordEp}$token&password=$oldPassword&password_confirmation=$newPassword");
    final result = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 12));

    final body = jsonDecode(result.body);
    if (result.statusCode == 200) {
      return body["message"] ?? "Password changed successfully!";
    } else {
      throw body["message"] ?? "Failed to change password";
    }
  }
}
