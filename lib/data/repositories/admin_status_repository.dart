import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/admin_status_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';

class AdminStatusRepository {
  Future<AdminStatusModel?> getAdminStatus({
    required String token,
  }) async {
    final url = Uri.parse("${AppUrl.baseURL}${AppUrl.getAdminStatusEp}$token");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    return AdminStatusModel.fromJson(decoded);
  }
}
