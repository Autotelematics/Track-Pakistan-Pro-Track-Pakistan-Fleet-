import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
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

  Future<void> init() async {
    if (_initialized) return;
    if (!_ttsAvailable && _lastInitFailureAt != null) {
      final elapsed = DateTime.now().difference(_lastInitFailureAt!);
      if (elapsed.inSeconds < 3) return;
    }
    try {
      if (Platform.isIOS) {
        await _tts.setSharedInstance(true);
        await _tts.autoStopSharedSession(false);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          const [IosTextToSpeechAudioCategoryOptions.mixWithOthers],
          IosTextToSpeechAudioMode.spokenAudio,
        );
      }
      await _tts.awaitSpeakCompletion(true);
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      _ttsAvailable = true;
      _lastInitFailureAt = null;
      _initialized = true;
    } on MissingPluginException {
      _ttsAvailable = false;
      _lastInitFailureAt = DateTime.now();
    } on PlatformException {
      _ttsAvailable = false;
      _lastInitFailureAt = DateTime.now();
    }
  }

  Future<void> speakFromRemoteMessage(
    RemoteMessage message, {
    required bool isBackground,
  }) async {
    final enabled = MySharedPreferences.getBool(playAlertsAnnouncementKey);
    if (!enabled) return;

    // iOS does not reliably allow arbitrary TTS while app is backgrounded.
    if (isBackground && Platform.isIOS) return;

    final text = _extractMessageText(message);
    await speakText(text, isBackground: isBackground);
  }

  Future<void> speakText(
    String text, {
    required bool isBackground,
  }) async {
    final normalized = text.trim();
    if (normalized.isEmpty) return;

    final enabled = MySharedPreferences.getBool(playAlertsAnnouncementKey);
    if (!enabled) return;

    // iOS does not reliably allow arbitrary TTS while app is backgrounded.
    if (isBackground && Platform.isIOS) return;

    try {
      await init();
      if (!_ttsAvailable) return;
      await _tts.stop();
      await _tts.speak(normalized);
    } on MissingPluginException {
      // Background isolate may not have plugin bridge in some states.
      _initialized = false;
      _ttsAvailable = false;
      _lastInitFailureAt = DateTime.now();
    } on PlatformException {
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
