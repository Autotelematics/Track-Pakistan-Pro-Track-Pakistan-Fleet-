import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/task_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class TaskRepository {
  String _userApiHash() {
    final token = MySharedPreferences.getString(authTokenKey);
    if (token.isEmpty) {
      throw Exception('User token not found');
    }
    return token;
  }

  Uri _uri(String path, {Map<String, String>? query}) {
    final params = <String, String>{
      'user_api_hash': _userApiHash(),
      ...?query,
    };
    return Uri.parse('${AppUrl.baseURL}$path').replace(queryParameters: params);
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      final normalized = <String, dynamic>{};
      decoded.forEach((key, value) {
        if (key == null) return;
        normalized[key.toString()] = value;
      });
      return normalized;
    }
    throw Exception('Invalid response format');
  }

  void _ensureSuccess(http.Response response, Map<String, dynamic> body,
      {String fallback = 'Request failed'}) {
    final okStatusCode =
        response.statusCode >= 200 && response.statusCode < 300;
    final status = body['status'];
    final successByStatus = status == 1 || status == true || status == null;
    if (okStatusCode && successByStatus) return;

    final message = (body['message'] ?? fallback).toString().trim();
    if (message.isNotEmpty) {
      throw Exception(message);
    }
    throw Exception(fallback);
  }

  TaskActionResult _toActionResult(
    Map<String, dynamic> body, {
    required String fallbackSuccessMessage,
    required String fallbackFailureMessage,
  }) {
    final status = body['status'];
    final bool success = status == null || status == 1 || status == true;
    final String message = (body['message'] ?? '').toString().trim();
    return TaskActionResult(
      success: success,
      message: message.isNotEmpty
          ? message
          : (success ? fallbackSuccessMessage : fallbackFailureMessage),
    );
  }

  Future<TaskListPage> getTasksList({
    int page = 1,
    int? perPage,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      if (perPage != null && perPage > 0) 'per_page': perPage.toString(),
    };
    final response = await http.get(_uri(AppUrl.getTasksListEp, query: query));
    final body = _decode(response);
    _ensureSuccess(response, body, fallback: 'Failed to load tasks');
    return TaskListPage.fromJson(body);
  }

  Future<TaskActionResult> createTask({
    required TaskUpsertPayload payload,
  }) async {
    final response = await http.post(
      _uri(AppUrl.createTaskEp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload.toJson()),
    );
    final body = _decode(response);
    _ensureSuccess(response, body, fallback: 'Failed to create task');
    return _toActionResult(
      body,
      fallbackSuccessMessage: 'Task created successfully.',
      fallbackFailureMessage: 'Failed to create task.',
    );
  }

  Future<TaskActionResult> updateTask({
    required int id,
    required TaskUpsertPayload payload,
  }) async {
    final response = await http.post(
      _uri('${AppUrl.updateTaskEp}/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload.toJson()),
    );
    final body = _decode(response);
    _ensureSuccess(response, body, fallback: 'Failed to update task');
    return _toActionResult(
      body,
      fallbackSuccessMessage: 'Task updated successfully.',
      fallbackFailureMessage: 'Failed to update task.',
    );
  }

  Future<TaskActionResult> deleteTask({
    required int id,
  }) async {
    final response = await http.delete(_uri('${AppUrl.deleteTaskEp}/$id'));
    final body = _decode(response);
    _ensureSuccess(response, body, fallback: 'Failed to delete task');
    return _toActionResult(
      body,
      fallbackSuccessMessage: 'Task deleted successfully.',
      fallbackFailureMessage: 'Failed to delete task.',
    );
  }

  Future<TaskActionResult> assignTasks({
    required List<int> taskIds,
    required List<int> deviceIds,
  }) async {
    final String tasksValue =
        taskIds.where((id) => id > 0).map((id) => id.toString()).join(',');
    final String devicesValue =
        deviceIds.where((id) => id > 0).map((id) => id.toString()).join(',');

    final response = await http.post(
      _uri(AppUrl.assignTaskEp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'tasks': tasksValue,
        'devices': devicesValue,
      }),
    );
    final body = _decode(response);
    _ensureSuccess(response, body, fallback: 'Failed to assign tasks');
    return _toActionResult(
      body,
      fallbackSuccessMessage: 'Tasks assigned successfully.',
      fallbackFailureMessage: 'Failed to assign tasks.',
    );
  }
}
