import 'package:flutter/material.dart';
import 'package:trackerapp/data/repositories/alert_settings_repository.dart';
import 'package:trackerapp/utils/app_snackbar.dart';

class AlertSettingItem {
  final int id;
  final String name;
  final String type;
  final int active;
  bool assigned;

  AlertSettingItem({
    required this.id,
    required this.name,
    required this.type,
    required this.active,
    required this.assigned,
  });
}

class AlertSettingsProvider extends ChangeNotifier {
  final AlertSettingsRepository _repository = AlertSettingsRepository();
  Set<int> _initialActiveIds = <int>{};

  // toggles
  bool excessParking = false;
  bool offlineDuration = false;
  bool ignitionOn = false;
  bool ignitionOff = false;
  bool fenceExit = false;
  bool overspeed = false;
  bool stopDuration = false;
  bool powerDisconnected = false;
  bool idleDuration = false;

  double overspeedLimit = 0;
  bool isLoading = false;
  bool isSyncing = false;
  String? errorMessage;
  List<AlertSettingItem> alertItems = [];

  void _reset() {
    excessParking = false;
    offlineDuration = false;
    ignitionOn = false;
    ignitionOff = false;
    fenceExit = false;
    overspeed = false;
    stopDuration = false;
    powerDisconnected = false;
    idleDuration = false;
    overspeedLimit = 0;
    alertItems = [];
  }

  void toggle(String key) {
    switch (key) {
      case "excessParking":
        excessParking = !excessParking;
        break;
      case "offlineDuration":
        offlineDuration = !offlineDuration;
        break;
      case "ignitionOn":
        ignitionOn = !ignitionOn;
        break;
      case "ignitionOff":
        ignitionOff = !ignitionOff;
        break;
      case "fenceExit":
        fenceExit = !fenceExit;
        break;
      case "overspeed":
        overspeed = !overspeed;
        break;
      case "stopDuration":
        stopDuration = !stopDuration;
        break;
      case "powerDisconnected":
        powerDisconnected = !powerDisconnected;
        break;
      case "idleDuration":
        idleDuration = !idleDuration;
        break;
    }
    notifyListeners();
  }

  void updateOverspeed(double v) {
    overspeedLimit = v;
    notifyListeners();
  }

  void toggleAlertItem(int index) {
    if (index < 0 || index >= alertItems.length) return;
    alertItems[index].assigned = !alertItems[index].assigned;
    notifyListeners();
  }

  Future<void> fetchAlertSettings({required String deviceId}) async {
    isLoading = true;
    errorMessage = null;
    _reset();
    notifyListeners();

    try {
      final response = await _repository.getAlertSettings(deviceId: deviceId);
      if (response == null) {
        errorMessage = "Unable to load alert settings";
      } else {
        _applyResponse(response);
      }
    } catch (_) {
      errorMessage = "Unable to load alert settings";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserAlertSettings() async {
    isLoading = true;
    errorMessage = null;
    _reset();
    notifyListeners();

    try {
      final response = await _repository.getAlertSettings();
      if (response == null) {
        errorMessage = "Unable to load alert settings";
      } else {
        _applyResponse(response);
        _initialActiveIds = alertItems
            .where((item) => item.assigned)
            .map((item) => item.id)
            .where((id) => id > 0)
            .toSet();
      }
    } catch (_) {
      errorMessage = "Unable to load alert settings";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> syncAlertSettings({required String deviceId}) async {
    isSyncing = true;
    notifyListeners();
    try {
      final selectedIds = alertItems
          .where((item) => item.assigned)
          .map((item) => item.id)
          .where((id) => id > 0)
          .toList();
      final syncedIds = await _repository.syncAlertSettings(
        deviceId: deviceId,
        alertIds: selectedIds,
      );
      if (syncedIds == null) {
        AppSnackBar.error(message: "Failed to sync alert settings");
        return false;
      }
      final syncedSet = syncedIds.toSet();
      for (final item in alertItems) {
        item.assigned = syncedSet.contains(item.id);
      }
      AppSnackBar.success(message: "Alert settings updated");
      return true;
    } catch (_) {
      AppSnackBar.error(message: "Failed to sync alert settings");
      return false;
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<bool> syncUserAlertSettings() async {
    isSyncing = true;
    notifyListeners();
    try {
      final currentActiveIds = alertItems
          .where((item) => item.assigned)
          .map((item) => item.id)
          .where((id) => id > 0)
          .toSet();

      final toEnable = currentActiveIds.difference(_initialActiveIds).toList();
      final toDisable = _initialActiveIds.difference(currentActiveIds).toList();

      if (toEnable.isEmpty && toDisable.isEmpty) {
        AppSnackBar.success(message: "Alert settings updated");
        return true;
      }

      if (toEnable.isNotEmpty) {
        final enabled = await _repository.syncAlertSettings(
          alertIds: toEnable,
          active: 1,
        );
        if (enabled == null) {
          AppSnackBar.error(message: "Failed to sync alert settings");
          return false;
        }
      }

      if (toDisable.isNotEmpty) {
        final disabled = await _repository.syncAlertSettings(
          alertIds: toDisable,
          active: 0,
        );
        if (disabled == null) {
          AppSnackBar.error(message: "Failed to sync alert settings");
          return false;
        }
      }

      _initialActiveIds = currentActiveIds;
      for (final item in alertItems) {
        item.assigned = currentActiveIds.contains(item.id);
      }

      AppSnackBar.success(message: "Alert settings updated");
      return true;
    } catch (_) {
      AppSnackBar.error(message: "Failed to sync alert settings");
      return false;
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  void _applyResponse(Map<String, dynamic> response) {
    final source = response["data"] ?? response;
    if (source is Map<String, dynamic>) {
      final alerts = source["alerts"];
      if (alerts is List) {
        _applyAlertsList(alerts);
      }
      source.forEach((key, value) {
        _consumeEntry(key, value);
      });
      return;
    }
    if (source is List) {
      for (final item in source) {
        if (item is Map<String, dynamic>) {
          _consumeEntry(
            (item["key"] ??
                    item["name"] ??
                    item["title"] ??
                    item["type"] ??
                    item["alert"] ??
                    "")
                .toString(),
            item["assigned"] ?? item["value"] ?? item["status"],
          );
        }
      }
    }
  }

  void _applyAlertsList(List alerts) {
    final parsed = <AlertSettingItem>[];
    for (final item in alerts) {
      if (item is! Map<String, dynamic>) continue;
      parsed.add(
        AlertSettingItem(
          id: (item["id"] as num?)?.toInt() ?? 0,
          name: (item["name"] ?? "Alert").toString(),
          type: (item["type"] ?? "").toString(),
          active: (item["active"] as num?)?.toInt() ?? 0,
          assigned:
              (_toFlag(item["active"]) ?? _toFlag(item["assigned"]) ?? 0) == 1,
        ),
      );

      final assigned =
          _toFlag(item["active"]) ?? _toFlag(item["assigned"]) ?? 0;
      if (assigned != 1) continue;

      final type = (item["type"] ?? "").toString().toLowerCase();
      final name = (item["name"] ?? "").toString().toLowerCase();

      if (type.contains("offline")) offlineDuration = true;
      if (type.contains("overspeed")) overspeed = true;
      if (type.contains("idle")) idleDuration = true;
      if (type.contains("stop_duration") || type.contains("parking")) {
        stopDuration = true;
      }
      if (type.contains("geofence")) fenceExit = true;
      if (type.contains("excess") || type.contains("over_parking")) {
        excessParking = true;
      }

      if (type == "custom" || type.isEmpty) {
        if (name.contains("ignition on")) ignitionOn = true;
        if (name.contains("ignition off")) ignitionOff = true;
        if (name.contains("power disconnected")) powerDisconnected = true;
        if (name.contains("offline")) offlineDuration = true;
        if (name.contains("overspeed")) overspeed = true;
        if (name.contains("idle")) idleDuration = true;
        if (name.contains("stop duration")) stopDuration = true;
      }
    }
    if (parsed.isNotEmpty) {
      alertItems = parsed;
    }
  }

  void _consumeEntry(String key, dynamic value) {
    if (value is Map<String, dynamic>) {
      final entryKey = (value["key"] ??
              value["name"] ??
              value["title"] ??
              value["type"] ??
              value["alert"] ??
              key)
          .toString();
      final assigned = value["assigned"] ?? value["value"] ?? value["status"];
      _setByKey(entryKey, assigned);
      if (value["overspeed_limit"] is num) {
        overspeedLimit = (value["overspeed_limit"] as num).toDouble();
      }
      return;
    }
    _setByKey(key, value);
  }

  int? _toFlag(dynamic value) {
    if (value is bool) return value ? 1 : 0;
    if (value is num) return value > 0 ? 1 : 0;
    final text = value?.toString().trim().toLowerCase() ?? "";
    if (text.isEmpty) return null;
    if (text == "1" || text == "true" || text == "yes" || text == "on") {
      return 1;
    }
    if (text == "0" || text == "false" || text == "no" || text == "off") {
      return 0;
    }
    return null;
  }

  void _setByKey(String rawKey, dynamic value) {
    final flag = _toFlag(value);
    if (flag == null) return;
    final enabled = flag == 1;
    final normalized =
        rawKey.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    switch (normalized) {
      case "excessparking":
      case "overparking":
        excessParking = enabled;
        break;
      case "offlineduration":
      case "offline":
      case "offlinetime":
        offlineDuration = enabled;
        break;
      case "ignitionon":
        ignitionOn = enabled;
        break;
      case "ignitionoff":
        ignitionOff = enabled;
        break;
      case "fenceexit":
      case "geofenceexit":
      case "geofenceout":
        fenceExit = enabled;
        break;
      case "overspeed":
      case "overspeeding":
        overspeed = enabled;
        break;
      case "stopduration":
      case "parkingduration":
        stopDuration = enabled;
        break;
      case "powerdisconnected":
      case "powercut":
      case "powerdisconnect":
        powerDisconnected = enabled;
        break;
      case "idleduration":
      case "idle":
        idleDuration = enabled;
        break;
    }
  }
}
