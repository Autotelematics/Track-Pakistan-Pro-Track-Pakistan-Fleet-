import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/device_expense_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class DeviceExpenseRepository {
  String _userApiHash() {
    final token = MySharedPreferences.getString(authTokenKey);
    if (token.isEmpty) {
      throw Exception("User token not found");
    }
    return token;
  }

  Uri _uri(String path, {Map<String, String>? query}) {
    final params = <String, String>{
      "user_api_hash": _userApiHash(),
      ...?query,
    };
    return Uri.parse("${AppUrl.baseURL}$path").replace(queryParameters: params);
  }

  Map<String, dynamic> _decode(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception("Invalid response");
  }

  void _ensureSuccess(http.Response response, Map<String, dynamic> body,
      {String fallback = "Request failed"}) {
    final okStatusCode = response.statusCode >= 200 && response.statusCode < 300;
    final status = body["status"];
    final successByStatus = status == 1 || status == true;
    if (!okStatusCode || !successByStatus) {
      throw Exception((body["message"] ?? fallback).toString());
    }
  }

  Future<DeviceExpenseListResponse> listExpenses({
    required int deviceId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int perPage = 15,
  }) async {
    final query = <String, String>{
      "device_id": "$deviceId",
      "page": "$page",
      "per_page": "$perPage",
    };
    if (from != null) query["from"] = from.toIso8601String().split("T").first;
    if (to != null) query["to"] = to.toIso8601String().split("T").first;

    final response =
        await http.get(_uri(AppUrl.deviceExpensesListEp, query: query));
    final body = _decode(response);
    _ensureSuccess(response, body, fallback: "Failed to load expenses");
    return DeviceExpenseListResponse.fromJson(body);
  }

  Future<List<DeviceExpenseType>> getExpenseTypes() async {
    final response = await http.get(_uri(AppUrl.deviceExpensesTypesEp));
    final body = _decode(response);
    _ensureSuccess(response, body, fallback: "Failed to load expense types");

    final raw = body["data"];
    if (raw is! List) return <DeviceExpenseType>[];
    return raw
        .whereType<Map>()
        .map((e) {
          final normalized = <String, dynamic>{};
          e.forEach((key, value) {
            if (key == null) return;
            normalized[key.toString()] = value;
          });
          return DeviceExpenseType.fromJson(normalized);
        })
        .toList();
  }

  Future<void> createExpense({
    required int deviceId,
    required int typeId,
    required DateTime date,
    required double quantity,
    required double unitCost,
    String? name,
    String? supplier,
    String? comment,
  }) async {
    final body = <String, String>{
      "device_id": "$deviceId",
      "device_expenses_type_id": "$typeId",
      "type_id": "$typeId",
      "date": date.toIso8601String().split("T").first,
      "quantity": "$quantity",
      "unit_cost": "$unitCost",
      if (name != null && name.trim().isNotEmpty) "name": name.trim(),
      if (supplier != null && supplier.trim().isNotEmpty) "supplier": supplier.trim(),
      if (comment != null && comment.trim().isNotEmpty) "comment": comment.trim(),
    };

    final response = await http.post(
      _uri(AppUrl.deviceExpensesCreateEp),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: body,
    );
    final decoded = _decode(response);
    _ensureSuccess(response, decoded, fallback: "Failed to create expense");
  }

  Future<void> updateExpense({
    required int expenseId,
    int? typeId,
    DateTime? date,
    double? quantity,
    double? unitCost,
    String? name,
    String? supplier,
    String? comment,
  }) async {
    final body = <String, String>{};
    if (typeId != null) {
      body["device_expenses_type_id"] = "$typeId";
      body["type_id"] = "$typeId";
    }
    if (date != null) body["date"] = date.toIso8601String().split("T").first;
    if (quantity != null) body["quantity"] = "$quantity";
    if (unitCost != null) body["unit_cost"] = "$unitCost";
    if (name != null) body["name"] = name.trim();
    if (supplier != null) body["supplier"] = supplier.trim();
    if (comment != null) body["comment"] = comment.trim();

    final response = await http.post(
      _uri("${AppUrl.deviceExpensesUpdateEp}/$expenseId"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: body,
    );
    final decoded = _decode(response);
    _ensureSuccess(response, decoded, fallback: "Failed to update expense");
  }

  Future<void> deleteExpense({required int expenseId}) async {
    final response =
        await http.delete(_uri("${AppUrl.deviceExpensesDeleteEp}/$expenseId"));
    final body = _decode(response);
    _ensureSuccess(response, body, fallback: "Failed to delete expense");
  }
}
