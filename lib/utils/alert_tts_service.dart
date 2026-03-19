import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class AlertTtsService {
  AlertTtsService._();
  static final AlertTtsService instance = AlertTtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _ttsAvailable = true;
  DateTime? _lastInitFailureAt;
  bool _handlersBound = false;

  Future<void> init() async {
    if (_initialized) return;
    if (!_ttsAvailable && _lastInitFailureAt != null) {
      final elapsed = DateTime.now().difference(_lastInitFailureAt!);
      if (elapsed.inSeconds < 3) return;
    }
    try {
      _bindHandlers();
      if (Platform.isIOS) {
        await _tts.setSharedInstance(true);
        await _tts.autoStopSharedSession(false);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          const [IosTextToSpeechAudioCategoryOptions.mixWithOthers],
          IosTextToSpeechAudioMode.spokenAudio,
        );
      }
      if (Platform.isAndroid) {
        await _tts.setAudioAttributesForNavigation();
        await _applyPreferredAndroidLanguage();
      }
      await _tts.awaitSpeakCompletion(true);
      if (!Platform.isAndroid) {
        await _tts.setLanguage("en-US");
      }
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      _ttsAvailable = true;
      _lastInitFailureAt = null;
      _initialized = true;
    } on MissingPluginException catch (e) {
      debugPrint('AlertTtsService init missing plugin: $e');
      _ttsAvailable = false;
      _lastInitFailureAt = DateTime.now();
    } on PlatformException catch (e) {
      debugPrint('AlertTtsService init platform error: ${e.code} ${e.message}');
      _ttsAvailable = false;
      _lastInitFailureAt = DateTime.now();
    }
  }

  void _bindHandlers() {
    if (_handlersBound) return;
    _tts.setStartHandler(() {});
    _tts.setCompletionHandler(() {});
    _tts.setCancelHandler(() {});
    _tts.setErrorHandler((message) {
      _initialized = false;
      _ttsAvailable = false;
      _lastInitFailureAt = DateTime.now();
    });
    _handlersBound = true;
  }

  Future<String> _applyPreferredAndroidLanguage() async {
    const candidates = <String>['en-US', 'en-GB', 'en'];
    for (final candidate in candidates) {
      final available = await _tts.isLanguageAvailable(candidate);
      if (available == 1 || available == true) {
        final result = await _tts.setLanguage(candidate);
        if (result == 1 || result == true) {
          return candidate;
        }
      }
    }
    final defaultVoice = await _tts.getDefaultVoice;
    if (defaultVoice is Map && defaultVoice['locale'] is String) {
      final locale = (defaultVoice['locale'] as String).trim();
      if (locale.isNotEmpty) {
        final result = await _tts.setLanguage(locale);
        if (result == 1 || result == true) {
          return locale;
        }
      }
    }
    return 'system-default';
  }

  Future<void> speakFromRemoteMessage(
    RemoteMessage message, {
    required bool isBackground,
    Duration? delay,
  }) async {
    await MySharedPreferences.reload();
    final enabled = MySharedPreferences.getBool(playAlertsAnnouncementKey);
    final text = _extractMessageText(message);
    if (!enabled) return;

    // iOS does not reliably allow arbitrary TTS while app is backgrounded.
    if (isBackground && Platform.isIOS) return;

    await speakText(
      text,
      isBackground: isBackground,
      delay: delay,
    );
  }

  Future<void> speakText(
    String text, {
    required bool isBackground,
    Duration? delay,
  }) async {
    final normalized = text.trim();
    if (normalized.isEmpty) return;

    await MySharedPreferences.reload();
    final enabled = MySharedPreferences.getBool(playAlertsAnnouncementKey);
    if (!enabled) return;

    // iOS does not reliably allow arbitrary TTS while app is backgrounded.
    if (isBackground && Platform.isIOS) return;

    try {
      final waitTime = delay ?? (Platform.isAndroid ? const Duration(milliseconds: 900) : Duration.zero);
      if (waitTime > Duration.zero) {
        await Future<void>.delayed(waitTime);
      }
      await init();
      if (!_ttsAvailable) return;
      await _tts.stop();
      await _tts.speak(
        normalized,
        focus: Platform.isAndroid,
      );
    } on MissingPluginException catch (e) {
      debugPrint('AlertTtsService speak missing plugin: $e');
      // Background isolate may not have plugin bridge in some states.
      _initialized = false;
      _ttsAvailable = false;
      _lastInitFailureAt = DateTime.now();
    } on PlatformException catch (e) {
      debugPrint('AlertTtsService speak platform error: ${e.code} ${e.message}');
      // Ignore TTS engine failures and keep notification flow running.
      _initialized = false;
      _ttsAvailable = false;
      _lastInitFailureAt = DateTime.now();
    }
  }

  String _extractMessageText(RemoteMessage message) {
    final data = message.data;
    final ttsText = (data["tts_text"] ?? "").toString().trim();
    if (ttsText.isNotEmpty) return ttsText;

    final title = (message.notification?.title ?? "").trim();
    final body = (message.notification?.body ?? "").trim();
    // Read only title for alerts (unless explicit tts_text is provided).
    if (title.isNotEmpty) return title;

    // Fallbacks if title is missing.
    final dataTitle = (data["title"] ?? "").toString().trim();
    if (dataTitle.isNotEmpty) return dataTitle;
    if (body.isNotEmpty) return body;
    return (data["body"] ?? data["message"] ?? "").toString().trim();
  }
}
