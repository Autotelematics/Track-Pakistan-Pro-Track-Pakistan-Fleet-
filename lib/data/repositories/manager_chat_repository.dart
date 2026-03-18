import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/manager_chat_model.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class ManagerChatApiException implements Exception {
  final int statusCode;
  final String message;

  const ManagerChatApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => message;
}

class ManagerChatRepository {
  String _userApiHash() {
    final token = MySharedPreferences.getString(authTokenKey).trim();
    if (token.isEmpty) {
      throw const ManagerChatApiException(
        statusCode: 401,
        message: 'Session expired. Please login again.',
      );
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
    throw const ManagerChatApiException(
      statusCode: 500,
      message: 'Invalid response format',
    );
  }

  void _ensureSuccess(
    http.Response response,
    Map<String, dynamic> body, {
    required String fallback,
  }) {
    final isOk = response.statusCode >= 200 && response.statusCode < 300;
    final status = body['status'];
    final byStatus = status == null || status == 1 || status == true;
    if (isOk && byStatus) return;

    final message = (body['message'] ?? fallback).toString().trim();
    throw ManagerChatApiException(
      statusCode: response.statusCode,
      message: message.isEmpty ? fallback : message,
    );
  }

  Future<ManagerChatThread?> getCurrentThread() async {
    final response = await http.get(_uri(AppUrl.managerChatThreadEp));
    final body = _decode(response);
    _ensureSuccess(response, body, fallback: 'Failed to load support chat');
    return ManagerChatThreadResponse.fromJson(body).thread;
  }

  Future<ManagerChatThread> createThread({
    ManagerChatCreatePayload payload = const ManagerChatCreatePayload(),
  }) async {
    final response = await http.post(
      _uri(AppUrl.managerChatCreateThreadEp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload.toJson()),
    );
    final body = _decode(response);
    _ensureSuccess(response, body, fallback: 'Failed to start support chat');

    final rawThread = body['thread'];
    if (rawThread is Map) {
      return ManagerChatThread.fromJson(_toMap(rawThread));
    }
    throw const ManagerChatApiException(
      statusCode: 500,
      message: 'Chat thread was not returned by the server',
    );
  }

  Future<List<ManagerChatMessage>> getMessages({
    required int threadId,
  }) async {
    final response =
        await http.get(_uri('${AppUrl.managerChatThreadEp}/$threadId/messages'));
    final body = _decode(response);
    _ensureSuccess(response, body, fallback: 'Failed to load chat messages');
    return ManagerChatMessagesResponse.fromJson(body).items;
  }

  Future<void> sendMessage({
    required int threadId,
    required ManagerChatSendPayload payload,
  }) async {
    final response = await http.post(
      _uri('${AppUrl.managerChatThreadEp}/$threadId/messages/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload.toJson()),
    );
    final body = _decode(response);
    _ensureSuccess(response, body, fallback: 'Failed to send message');
  }

  Future<void> markRead({
    required int threadId,
  }) async {
    final response = await http.post(
      _uri('${AppUrl.managerChatThreadEp}/$threadId/read'),
      headers: {'Content-Type': 'application/json'},
    );
    final body = _decode(response);
    _ensureSuccess(response, body, fallback: 'Failed to mark chat as read');
  }

  Map<String, dynamic> _toMap(Map source) {
    final normalized = <String, dynamic>{};
    source.forEach((key, value) {
      if (key == null) return;
      normalized[key.toString()] = value;
    });
    return normalized;
  }
}
