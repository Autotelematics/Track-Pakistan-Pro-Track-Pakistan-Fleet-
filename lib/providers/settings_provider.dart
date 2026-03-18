import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trackerapp/data/repositories/alert_settings_repository.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class SettingsProvider extends ChangeNotifier {
  final AlertSettingsRepository _alertSettingsRepository =
      AlertSettingsRepository();
  bool _playAlertsAnnouncement =
      MySharedPreferences.getBool(playAlertsAnnouncementKey);

  final List<Map<String, dynamic>> settingsItems = [
    {'icon': Icons.person_outline, 'title': 'Support'},
    {'icon': Icons.key_outlined, 'title': 'Password'},
    {'icon': Icons.badge_outlined, 'title': 'Drivers'},
    {'icon': Icons.notifications_none, 'title': 'Alert Setting'},
    {'icon': Icons.speaker_outlined, 'title': 'Play Alerts Announcement'},
    // {'icon': Icons.attach_money_outlined, 'title': 'Vehicle Expenses'},
    // {'icon': Icons.build_outlined, 'title': 'Maintenance'},
    {'icon': Icons.palette_outlined, 'title': 'Appearance'},
  ];

  // Keeps legacy in-memory state from showing deprecated logout row.
  List<Map<String, dynamic>> get visibleSettingsItems =>
      settingsItems.where((item) {
        final title = item['title'];
        if (title == 'LogOut') return false;
        if (title == 'Password' && !canChangePassword) return false;
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
    } catch (_) {
      _playAlertsAnnouncement = previous;
      notifyListeners();
    }
  }
}
