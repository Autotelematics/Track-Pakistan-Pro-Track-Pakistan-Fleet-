import 'package:flutter/material.dart';
import 'package:trackerapp/data/repositories/fcm_token_repository.dart';
import 'package:trackerapp/main.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/utils/local_notification_service.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/view/auth_screens/login_screen.dart';

class SessionExpiredException implements Exception {
  final String message;

  const SessionExpiredException([
    this.message = 'Session expired. Please login again.',
  ]);

  @override
  String toString() => message;
}

class SessionGuard {
  static bool _isLoggingOut = false;

  static bool isSessionExpiredError(Object error) => error is SessionExpiredException;

  static bool looksLikeSessionExpiredMessage(String message) {
    final text = message.trim().toLowerCase();
    if (text.isEmpty) return false;

    return text.contains('unauthorized') ||
        text.contains('unauthenticated') ||
        text.contains('invalid token') ||
        text.contains('invalid user_api_hash') ||
        text.contains('token expired') ||
        text.contains('session expired') ||
        text.contains('login expired') ||
        text.contains('wrong credentials') ||
        text.contains('invalid credentials') ||
        text.contains('password changed') ||
        text.contains('please login again') ||
        text.contains('user does not exist') ||
        text.contains('user not found') ||
        text.contains('access denied');
  }

  static Future<void> forceLogout({
    String message = 'Session expired. Please login again.',
  }) async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      try {
        await LocalNotificationService.instance.cancelAllReminderNotifications();
        await FcmTokenRepository().deleteLatestTokenForCurrentUser();
      } catch (_) {}

      await MySharedPreferences.logout();
      AppSnackBar.error(
        message: message,
        duration: const Duration(seconds: 4),
      );

      final navigator = rootNavigatorKey.currentState;
      if (navigator == null) return;

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } finally {
      _isLoggingOut = false;
    }
  }
}
