import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class DashboardLayoutProvider with ChangeNotifier {
  static const List<String> _defaultOrder = <String>[
    'fleet_insight',
    'alert_grid',
    'latest_tasks',
    'maintenance',
    'maintenance_analytics',
    'local_reminder',
    'fuel_price',
    'history_pair',
    'offline_24h',
    'performance',
    'expense',
  ];

  static const Map<String, String> _labels = <String, String>{
    'fleet_insight': 'Fleet Insight Ai',
    'alert_grid': 'Alerts Summary',
    'latest_tasks': 'Latest Tasks',
    'maintenance': 'Maintenance Reminder',
    'maintenance_analytics': 'Maintenance Analytics',
    'local_reminder': 'Local Reminder',
    'fuel_price': 'Fuel Price',
    'history_pair': 'Distance & Top Speed',
    'offline_24h': 'Offline Over 24 Hours',
    'performance': 'Performance Analytics',
    'expense': 'Expense Analytics',
  };

  List<String> _order = List<String>.from(_defaultOrder);
  Map<String, bool> _visibility = <String, bool>{};

  DashboardLayoutProvider() {
    _initialize();
  }

  List<String> get orderedCardIds => List<String>.from(_order);

  List<DashboardLayoutItem> get itemsForEditor => _order
      .map(
        (id) => DashboardLayoutItem(
          id: id,
          label: _labels[id] ?? id,
          isVisible: _visibility[id] ?? true,
        ),
      )
      .toList(growable: false);

  bool isCardVisible(String id) => _visibility[id] ?? true;

  void reorderCards(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _order.length) return;
    if (newIndex < 0 || newIndex > _order.length) return;
    if (oldIndex < newIndex) newIndex -= 1;
    final moved = _order.removeAt(oldIndex);
    _order.insert(newIndex, moved);
    _save();
    notifyListeners();
  }

  void setCardVisibility(String id, bool value) {
    if (!_order.contains(id)) return;

    if (!value) {
      final visibleCount = _visibility.values.where((v) => v).length;
      if (visibleCount <= 1 && (_visibility[id] ?? true)) {
        return;
      }
    }

    _visibility[id] = value;
    _save();
    notifyListeners();
  }

  void resetDefaults() {
    _order = List<String>.from(_defaultOrder);
    _visibility = {for (final id in _defaultOrder) id: true};
    _save();
    notifyListeners();
  }

  void _initialize() {
    _order = _loadOrder();
    _visibility = _loadVisibility(_order);
    notifyListeners();
  }

  List<String> _loadOrder() {
    final raw = MySharedPreferences.getString(dashboardCardOrderKey).trim();
    if (raw.isEmpty) return List<String>.from(_defaultOrder);

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return List<String>.from(_defaultOrder);
      final parsed = decoded
          .map((e) => e.toString())
          .where(_defaultOrder.contains)
          .toList();

      for (final id in _defaultOrder) {
        if (!parsed.contains(id)) parsed.add(id);
      }
      return parsed;
    } catch (_) {
      return List<String>.from(_defaultOrder);
    }
  }

  Map<String, bool> _loadVisibility(List<String> order) {
    final raw =
        MySharedPreferences.getString(dashboardCardVisibilityKey).trim();
    final defaults = <String, bool>{for (final id in order) id: true};
    if (raw.isEmpty) return defaults;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return defaults;

      for (final id in order) {
        final val = decoded[id];
        if (val is bool) defaults[id] = val;
      }
      if (!defaults.values.any((v) => v)) {
        defaults[order.first] = true;
      }
      return defaults;
    } catch (_) {
      return defaults;
    }
  }

  void _save() {
    MySharedPreferences.setString(
      dashboardCardOrderKey,
      jsonEncode(_order),
    );
    MySharedPreferences.setString(
      dashboardCardVisibilityKey,
      jsonEncode(_visibility),
    );
  }
}

class DashboardLayoutItem {
  final String id;
  final String label;
  final bool isVisible;

  const DashboardLayoutItem({
    required this.id,
    required this.label,
    required this.isVisible,
  });
}
