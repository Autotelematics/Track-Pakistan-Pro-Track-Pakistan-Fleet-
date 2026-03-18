import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:trackerapp/data/models/local_reminder_model.dart';
import 'package:trackerapp/utils/local_notification_service.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class ReminderProvider extends ChangeNotifier {
  final List<LocalReminder> _reminders = [];

  List<LocalReminder> get reminders => List.unmodifiable(_reminders);
  LocalReminder? reminderById(int id) {
    try {
      return _reminders.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> initialize() async {
    await _loadFromStorage();
    await _rescheduleAll();
  }

  Future<void> _loadFromStorage() async {
    final raw = MySharedPreferences.getString(localRemindersKey);
    if (raw.isEmpty) {
      _reminders.clear();
      notifyListeners();
      return;
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _reminders
        ..clear()
        ..addAll(
          decoded
              .map((e) => LocalReminder.fromMap(Map<String, dynamic>.from(e)))
              .toList(),
        );
      _reminders.sort((a, b) => a.dueAt.compareTo(b.dueAt));
      notifyListeners();
    } catch (_) {
      _reminders.clear();
      await MySharedPreferences.setString(localRemindersKey, "[]");
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final payload = jsonEncode(_reminders.map((e) => e.toMap()).toList());
    await MySharedPreferences.setString(localRemindersKey, payload);
  }

  Future<void> _rescheduleAll() async {
    for (final reminder in _reminders) {
      await LocalNotificationService.instance.scheduleReminder(reminder);
    }
  }

  Future<void> addReminder({
    required int deviceId,
    required String vehicleName,
    required String title,
    required String type,
    required String description,
    required DateTime dueAt,
    required String repeatType,
  }) async {
    final normalizedRepeat = repeatType.trim().isEmpty ? "none" : repeatType;
    final reminder = LocalReminder(
      id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      deviceId: deviceId,
      vehicleName: vehicleName.trim().isEmpty ? "Vehicle" : vehicleName.trim(),
      title: title.trim(),
      type: type.trim().isEmpty ? "Custom" : type.trim(),
      description: description.trim(),
      dueAt: dueAt,
      isRecurring: normalizedRepeat != "none",
      repeatType: normalizedRepeat,
      createdAt: DateTime.now(),
    );

    _reminders.add(reminder);
    _reminders.sort((a, b) => a.dueAt.compareTo(b.dueAt));

    await _persist();
    await LocalNotificationService.instance.scheduleReminder(reminder);
    notifyListeners();
  }

  Future<void> updateReminder({
    required int reminderId,
    required int deviceId,
    required String vehicleName,
    required String title,
    required String type,
    required String description,
    required DateTime dueAt,
    required String repeatType,
  }) async {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index == -1) return;

    final existing = _reminders[index];
    final normalizedRepeat = repeatType.trim().isEmpty ? "none" : repeatType;
    final updated = LocalReminder(
      id: existing.id,
      deviceId: deviceId,
      vehicleName: vehicleName.trim().isEmpty ? "Vehicle" : vehicleName.trim(),
      title: title.trim(),
      type: type.trim().isEmpty ? "Custom" : type.trim(),
      description: description.trim(),
      dueAt: dueAt,
      isRecurring: normalizedRepeat != "none",
      repeatType: normalizedRepeat,
      createdAt: existing.createdAt,
    );

    _reminders[index] = updated;
    _reminders.sort((a, b) => a.dueAt.compareTo(b.dueAt));

    await _persist();
    await LocalNotificationService.instance.cancelReminder(reminderId);
    await LocalNotificationService.instance.scheduleReminder(updated);
    notifyListeners();
  }

  Future<void> deleteReminder(int reminderId) async {
    _reminders.removeWhere((r) => r.id == reminderId);
    await _persist();
    await LocalNotificationService.instance.cancelReminder(reminderId);
    notifyListeners();
  }
}
