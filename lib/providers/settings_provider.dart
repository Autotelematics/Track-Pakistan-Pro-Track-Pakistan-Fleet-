import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trackerapp/l10n/app_localizations.dart';
import 'package:trackerapp/data/repositories/alert_settings_repository.dart';
import 'package:trackerapp/utils/alert_tts_service.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

enum SettingsItemId {
  myAccount,
  support,
  password,
  drivers,
  alertSetting,
  playAlertsAnnouncement,
  appearance,
  language,
}

class SettingsItem {
  final SettingsItemId id;
  final IconData icon;
  final String Function(AppLocalizations l10n) titleBuilder;
  final bool hasSwitch;

  const SettingsItem({
    required this.id,
    required this.icon,
    required this.titleBuilder,
    this.hasSwitch = false,
  });
}

class SettingsProvider extends ChangeNotifier {
  final AlertSettingsRepository _alertSettingsRepository =
      AlertSettingsRepository();
  bool _playAlertsAnnouncement =
      MySharedPreferences.getBool(playAlertsAnnouncementKey);

  List<SettingsItem> get settingsItems => [
        SettingsItem(
          id: SettingsItemId.myAccount,
          icon: Icons.account_circle_outlined,
          titleBuilder: (l10n) => l10n.myAccount,
        ),
        SettingsItem(
          id: SettingsItemId.support,
          icon: Icons.person_outline,
          titleBuilder: (l10n) => l10n.support,
        ),
        SettingsItem(
          id: SettingsItemId.password,
          icon: Icons.key_outlined,
          titleBuilder: (l10n) => l10n.password,
        ),
        SettingsItem(
          id: SettingsItemId.drivers,
          icon: Icons.badge_outlined,
          titleBuilder: (l10n) => l10n.drivers,
        ),
        SettingsItem(
          id: SettingsItemId.alertSetting,
          icon: Icons.notifications_none,
          titleBuilder: (l10n) => l10n.alertSetting,
        ),
        SettingsItem(
          id: SettingsItemId.playAlertsAnnouncement,
          icon: Icons.speaker_outlined,
          titleBuilder: (l10n) => l10n.playAlertsAnnouncement,
          hasSwitch: true,
        ),
        SettingsItem(
          id: SettingsItemId.language,
          icon: Icons.language_outlined,
          titleBuilder: (l10n) => l10n.language,
        ),
        SettingsItem(
          id: SettingsItemId.appearance,
          icon: Icons.palette_outlined,
          titleBuilder: (l10n) => l10n.appearance,
        ),
      ];

  List<SettingsItem> get visibleSettingsItems => settingsItems.where((item) {
        if (item.id == SettingsItemId.password && !canChangePassword) {
          return false;
        }
        return true;
      }).toList();

  bool get canChangePassword {
    if (!MySharedPreferences.containKey(canChangePasswordKey)) {
      return true;
    }
    return MySharedPreferences.getBool(canChangePasswordKey);
  }

  bool get playAlertsAnnouncement => _playAlertsAnnouncement;

  Future<void> setPlayAlertsAnnouncement(bool enabled) async {
    final previous = _playAlertsAnnouncement;
    _playAlertsAnnouncement = enabled;
    notifyListeners();

    try {
      if (Platform.isIOS) {
        final synced = await _alertSettingsRepository.syncAlertAnnouncement(
          enabled: enabled,
        );
        if (!synced) {
          _playAlertsAnnouncement = previous;
          notifyListeners();
          return;
        }
      }
      await MySharedPreferences.setBool(playAlertsAnnouncementKey, enabled);
      if (Platform.isAndroid && enabled) {
        await AlertTtsService.instance.speakText(
          'Alert announcements enabled',
          isBackground: false,
          delay: const Duration(milliseconds: 150),
        );
      }
    } catch (_) {
      _playAlertsAnnouncement = previous;
      notifyListeners();
    }
  }
}
