import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

class AppErrorMessage {
  static const String networkUnavailable =
      'Network connection issue. Please check internet and try again.';

  static String normalize(
    Object error, {
    String fallback = 'Request failed',
    String networkMessage = networkUnavailable,
  }) {
    if (error is SocketException) {
      return networkMessage;
    }
    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }
    if (error is http.ClientException) {
      if (_isNetworkText(error.message)) {
        return networkMessage;
      }
      final text = error.message.trim();
      return text.isEmpty ? fallback : text;
    }

    final raw = error.toString().trim();
    final cleaned = raw.startsWith('Exception:')
        ? raw.replaceFirst('Exception:', '').trim()
        : raw;
    if (_isNetworkText(cleaned)) {
      return networkMessage;
    }
    return cleaned.isEmpty ? fallback : cleaned;
  }

  static bool _isNetworkText(String text) {
    final lower = text.toLowerCase();
    return lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('no address associated with hostname') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection closed') ||
        lower.contains('timed out') ||
        lower.contains('clientexception');
  }
}
