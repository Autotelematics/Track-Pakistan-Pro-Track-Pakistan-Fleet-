import 'dart:io';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:trackerapp/res/app_endpoints.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class FcmTokenRepository {
  bool _looksLikeApiSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) return false;
    final raw = response.body.trim();
    if (raw.isEmpty) return true;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('status')) {
          final status = decoded['status'];
          if (status is num && status == 0) return false;
          if (status is String) {
            final normalized = status.trim().toLowerCase();
            if (normalized == '0' || normalized == 'false' || normalized == 'error') {
              return false;
            }
          }
        }
        if (decoded.containsKey('success')) {
          final success = decoded['success'];
          if (success is bool) return success;
          if (success is num) return success != 0;
          if (success is String) {
            final normalized = success.trim().toLowerCase();
            return normalized == '1' || normalized == 'true' || normalized == 'success';
          }
        }
        if (decoded.containsKey('error')) {
          final error = decoded['error'];
          if (error == true) return false;
          if (error is num && error != 0) return false;
          if (error is String && error.trim().isNotEmpty) return false;
        }
      }
    } catch (_) {
      // Keep backward compatibility for non-JSON 2xx responses.
      return true;
    }
    return true;
  }

  String _clipBody(String body) {
    const maxLen = 240;
    if (body.length <= maxLen) return body;
    return '${body.substring(0, maxLen)}...';
  }

  Future<String?> _fetchCurrentTokenSafely() async {
    final messaging = FirebaseMessaging.instance;

    if (Platform.isIOS) {
      const maxAttempts = 12;
      for (var i = 0; i < maxAttempts; i++) {
        try {
          final apnsToken = await messaging.getAPNSToken();
          if (apnsToken != null && apnsToken.isNotEmpty) break;
        } catch (_) {}
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }

    try {
      return await messaging.getToken();
    } catch (e) {
      debugPrint('FCM getToken failed: $e');
      return null;
    }
  }

  Future<void> syncCurrentDeviceToken({bool force = false}) async {
    final current = (await _fetchCurrentTokenSafely())?.trim() ?? '';
    if (current.isEmpty) {
      await syncLatestTokenIfAvailable(force: force);
      return;
    }
    await rememberLatestToken(current);
    await syncToken(current, force: force);
  }

  Future<void> rememberLatestToken(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return;
    await MySharedPreferences.setString(latestFcmTokenKey, trimmed);
  }

  Future<void> syncLatestTokenIfAvailable({bool force = false}) async {
    final latestToken = MySharedPreferences.getString(latestFcmTokenKey).trim();
    if (latestToken.isEmpty) return;
    await syncToken(latestToken, force: force);
  }

  Future<void> syncToken(String token, {bool force = false}) async {
    final fcmToken = token.trim();
    final userApiHash = MySharedPreferences.getString(authTokenKey).trim();
    if (fcmToken.isEmpty) {
      debugPrint('FCM sync skipped: empty token');
      return;
    }
    if (userApiHash.isEmpty) {
      debugPrint('FCM sync deferred: user_api_hash not available yet');
      return;
    }

    final lastSyncedToken =
        MySharedPreferences.getString(lastSyncedFcmTokenKey).trim();
    final lastSyncedHash =
        MySharedPreferences.getString(lastSyncedFcmUserHashKey).trim();

    if (!force && lastSyncedToken == fcmToken && lastSyncedHash == userApiHash) {
      return;
    }

    final uri =
        Uri.parse('${AppUrl.baseURL}${AppUrl.submitFcmTokenEp}').replace(
      queryParameters: {
        'user_api_hash': userApiHash,
        'token': fcmToken,
        'fcm_token': fcmToken,
        'device_token': fcmToken,
      },
    );

    debugPrint('FCM sync request POST $uri');
    var response = await http.post(
      uri,
      body: {
        'user_api_hash': userApiHash,
        'token': fcmToken,
        'fcm_token': fcmToken,
        'device_token': fcmToken,
      },
    ).timeout(const Duration(seconds: 12));

    if (response.statusCode == 404 || response.statusCode == 405) {
      debugPrint('FCM sync fallback GET $uri');
      response = await http.get(uri).timeout(const Duration(seconds: 12));
    }

    if (_looksLikeApiSuccess(response)) {
      await MySharedPreferences.setString(lastSyncedFcmTokenKey, fcmToken);
      await MySharedPreferences.setString(
          lastSyncedFcmUserHashKey, userApiHash);
      debugPrint(
        'FCM sync success (${response.statusCode}) body=${_clipBody(response.body)}',
      );
      return;
    }

    debugPrint(
      'FCM sync failed (${response.statusCode}): ${_clipBody(response.body)}',
    );
    throw Exception(
      'Failed to sync FCM token (status: ${response.statusCode})',
    );
  }

  Future<void> deleteLatestTokenForCurrentUser() async {
    final latestToken = MySharedPreferences.getString(latestFcmTokenKey).trim();
    if (latestToken.isEmpty) return;
    await deleteToken(latestToken);
  }

  Future<void> deleteToken(String token) async {
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('FirebaseMessaging deleteToken warning: $e');
    }

    final fcmToken = token.trim();
    final userApiHash = MySharedPreferences.getString(authTokenKey).trim();
    if (fcmToken.isEmpty || userApiHash.isEmpty) return;

    final endpointCandidates = <String>[
      AppUrl.deleteFcmTokenEp,
      AppUrl.submitFcmTokenEp,
    ];
    http.Response? lastResponse;

    for (final endpoint in endpointCandidates) {
      final uri = Uri.parse('${AppUrl.baseURL}$endpoint').replace(
        queryParameters: {
          'user_api_hash': userApiHash,
          'token': fcmToken,
        },
      );
      final response = await http.delete(uri).timeout(const Duration(seconds: 12));
      lastResponse = response;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await MySharedPreferences.removeKey(lastSyncedFcmTokenKey);
        await MySharedPreferences.removeKey(lastSyncedFcmUserHashKey);
        debugPrint('FCM delete success (${response.statusCode}) on $endpoint');
        return;
      }
    }

    debugPrint(
      'FCM delete failed (${lastResponse?.statusCode}): ${lastResponse?.body}',
    );
    throw Exception(
      'Failed to delete FCM token (status: ${lastResponse?.statusCode ?? "unknown"})',
    );
  }
}
