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

  bool _hasFleetMobileAccess(Map<String, dynamic> body) {
    bool containsFleet(dynamic value) {
      if (value is List) {
        final normalized = value
            .map((e) => e.toString().trim().toLowerCase())
            .where((e) => e.isNotEmpty);
        return normalized.contains("trackpakistanfleet");
      }
      if (value is String) {
        return value.trim().toLowerCase() == "trackpakistanfleet";
      }
      return false;
    }

    final topLevelPermissions = body["permissions"];
    if (topLevelPermissions is Map<String, dynamic>) {
      final customerDetails = topLevelPermissions["customer_details"];
      if (customerDetails is Map<String, dynamic> &&
          containsFleet(customerDetails["mobile_access"])) {
        return true;
      }
    }

    final data = body["data"];
    if (data is Map<String, dynamic>) {
      final permissions = data["permissions"];
      if (permissions is Map<String, dynamic>) {
        final customerDetails = permissions["customer_details"];
        if (customerDetails is Map<String, dynamic> &&
            containsFleet(customerDetails["mobile_access"])) {
          return true;
        }
      }
    }

    return false;
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

  String _extractStringField(Map<String, dynamic> body, String key) {
    final topLevel = body[key]?.toString().trim();
    if (topLevel != null && topLevel.isNotEmpty && topLevel != "null") {
      return topLevel;
    }

    final data = body["data"];
    if (data is Map<String, dynamic>) {
      final nested = data[key]?.toString().trim();
      if (nested != null && nested.isNotEmpty && nested != "null") {
        return nested;
      }
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

  String _extractCompanyField(Map<String, dynamic> body, String key) {
    final companyDetails = body["company_details"];
    if (companyDetails is Map<String, dynamic>) {
      final topLevel = companyDetails[key]?.toString().trim();
      if (topLevel != null && topLevel.isNotEmpty && topLevel != "null") {
        return topLevel;
      }
    }

    final data = body["data"];
    if (data is Map<String, dynamic>) {
      final nestedCompanyDetails = data["company_details"];
      if (nestedCompanyDetails is Map<String, dynamic>) {
        final nested = nestedCompanyDetails[key]?.toString().trim();
        if (nested != null && nested.isNotEmpty && nested != "null") {
          return nested;
        }
      }
    }

    return "";
  }

  Future<void> _persistCompanyDetails(Map<String, dynamic> body) async {
    await MySharedPreferences.setString(
      companyNameKey,
      _extractCompanyField(body, "company_name"),
    );
    await MySharedPreferences.setString(
      companyAddressKey,
      _extractCompanyField(body, "company_address"),
    );
    await MySharedPreferences.setString(
      companyPhoneKey,
      _extractCompanyField(body, "phone_no"),
    );
    await MySharedPreferences.setString(
      companySupportEmailKey,
      _extractCompanyField(body, "support_email"),
    );
    await MySharedPreferences.setString(
      companyWebsiteKey,
      _extractCompanyField(body, "website"),
    );
    await MySharedPreferences.setString(
      companyWhatsappKey,
      _extractCompanyField(body, "whatsapp_no"),
    );
    await MySharedPreferences.setString(
      companyFacebookKey,
      _extractCompanyField(body, "facebook"),
    );
    await MySharedPreferences.setString(
      companyInstagramKey,
      _extractCompanyField(body, "instagram"),
    );
    await MySharedPreferences.setString(
      companyTermsUrlKey,
      _extractCompanyField(body, "terms_condition_url"),
    );
    await MySharedPreferences.setString(
      companyPrivacyUrlKey,
      _extractCompanyField(body, "privacy_policy_url"),
    );
    await MySharedPreferences.setString(
      companyNewsUrlKey,
      _extractCompanyField(body, "company_news_url"),
    );
  }

  Future<void> _persistUserSession(Map<String, dynamic> body) async {
    await MySharedPreferences.setBool(isLoggedInKey, true);
    await MySharedPreferences.setString(
      authTokenKey,
      body["user_api_hash"]?.toString() ??
          MySharedPreferences.getString(authTokenKey),
    );
    await MySharedPreferences.setInt(userIdKey, _extractUserId(body));
    await MySharedPreferences.setString(
      userNameKey,
      _extractStringField(body, "user_name"),
    );
    await MySharedPreferences.setString(
      userEmailKey,
      _extractUserEmail(body),
    );
    await MySharedPreferences.setString(
      userPhoneNumberKey,
      _extractStringField(body, "user_phone_number"),
    );
    await MySharedPreferences.setString(
      userExpirationDateKey,
      _extractStringField(body, "expiration_date"),
    );
    await MySharedPreferences.setString(
      userDevicesLimitKey,
      _extractStringField(body, "devices_limit"),
    );
    await MySharedPreferences.setString(userTypeKey, _extractUserType(body));
    await MySharedPreferences.setBool(
      canChangePasswordKey,
      _extractCanChangePassword(body),
    );
    await MySharedPreferences.setBool(
      canSendCommandViewKey,
      _extractSendCommandView(body),
    );
  }

  //Login
  Future<bool> loginApi({
    required String email,
    required String password,
  }) async {
    final endpointPath = AppUrl.loginEp.split('?').first;
    final url = Uri.parse('${AppUrl.baseURL}$endpointPath').replace(
      queryParameters: {
        'email': email,
        'password': password,
      },
    );
    final result = await http.post(url).timeout(const Duration(seconds: 12));
    final body = jsonDecode(result.body);
    if (result.statusCode == 200) {
      if (!_hasFleetMobileAccess(body)) {
        throw mobileAccessDeniedMessage;
      }
      await _persistUserSession(body);
      final fcmRepo = FcmTokenRepository();
      await fcmRepo.syncCurrentDeviceToken(force: true);
      await fcmRepo.syncLatestTokenIfAvailable(force: true);
      return true;
    } else {
      throw body["message"] ?? "Something went wrong";
    }
  }

  Future<void> fetchCompanyDetailsApi() async {
    final token = MySharedPreferences.getString(authTokenKey).trim();
    if (token.isEmpty) return;

    final endpointPath = AppUrl.getCompanyDetailsEp.split('?').first;
    final url = Uri.parse('${AppUrl.baseURL}$endpointPath').replace(
      queryParameters: {
        'user_api_hash': token,
      },
    );

    final result = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 12));

    final body = jsonDecode(result.body);
    if (result.statusCode == 200 && body["status"] == 1) {
      await _persistCompanyDetails(body);
      return;
    }

    throw body["message"] ?? "Unable to load company details";
  }

  // change password
  Future<String> changePasswordApi({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = MySharedPreferences.getString(authTokenKey);
    final endpointPath = AppUrl.changePasswordEp.split('?').first;
    final url = Uri.parse('${AppUrl.baseURL}$endpointPath').replace(
      queryParameters: {
        'user_api_hash': token,
        'old_password': oldPassword,
        'current_password': oldPassword,
        'password': newPassword,
        'new_password': newPassword,
        'password_confirmation': confirmPassword,
        'new_password_confirmation': confirmPassword,
      },
    );
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
