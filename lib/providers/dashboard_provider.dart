import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trackerapp/data/models/dashboard_data.dart';
import 'package:trackerapp/data/models/get_device_status_model.dart'
    as status_model;
import 'package:trackerapp/data/models/get_dashboard_history_model.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/data/repositories/dashboard_repository.dart';
import 'package:trackerapp/data/repositories/get_device_status_repository.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();
  final GetDeviceStatusRepository _statusRepository =
      GetDeviceStatusRepository();

  // Dashboard data
  DashboardData? _dashboardData;
  GetDashboardModel? _dashboardModel;

  // Dashboard History data
  GetDashboardHistoryModel? _dashboardHistoryModel;
  List<OfflineVehicleInfo> _offlineVehiclesOver24h = [];

  int _selectedStatusIndex = -1;
  int _touchedIndex = -1;

  bool _isLoading = false;
  String? _error;

  // Getters
  DashboardData? get dashboardData => _dashboardData;
  GetDashboardModel? get dashboardModel => _dashboardModel;
  GetDashboardHistoryModel? get dashboardHistoryModel => _dashboardHistoryModel;
  List<OfflineVehicleInfo> get offlineVehiclesOver24h =>
      _offlineVehiclesOver24h;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedStatusIndex => _selectedStatusIndex;
  int get touchedIndex => _touchedIndex;

  String get _token => MySharedPreferences.getString(authTokenKey);

  DashboardProvider() {
    fetchData();
  }

  void setSelectedStatusIndex(int index) {
    _selectedStatusIndex = index;
    notifyListeners();
  }

  void clearSelection() {
    _selectedStatusIndex = -1;
    notifyListeners();
  }

  void setTouchedIndex(int index) {
    _touchedIndex = index;
    notifyListeners();
  }

  // Fetch Dashboard main data
  Future<void> getDashboardProvider({bool forceLoading = false}) async {
    final hadData = _dashboardModel != null;
    if (!hadData || forceLoading) {
      _isLoading = true;
      notifyListeners();
    }
    _error = null;
    try {
      final response = await _getDashboardWithRetry();
      if (response != null) {
        _dashboardModel = response;
        if (response.userEmail.trim().isNotEmpty) {
          await MySharedPreferences.setString(userEmailKey, response.userEmail);
        }
        await fetchOfflineVehiclesOver24h();
      } else {
        if (!hadData) {
          _error = "Unable to load dashboard right now. Please try again.";
        }
      }
    } catch (e) {
      if (!hadData) {
        _error = _friendlyErrorMessage(e);
        AppSnackBar.error(message: _error!);
      }
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Fetch Dashboard history data
  Future<void> getDashboardHistoryProvider({bool forceRefresh = false}) async {
    if (!forceRefresh && _dashboardHistoryModel != null) return;

    _isLoading = true;
    if (_dashboardModel == null) {
      _error = null;
    }
    notifyListeners();

    try {
      final response = await _getDashboardHistoryWithRetry();
      if (response != null) {
        _dashboardHistoryModel = response;
      } else {
        if (_dashboardModel == null) {
          _error = "Unable to load dashboard history right now.";
        }
      }
    } catch (e) {
      if (_dashboardModel == null) {
        _error = _friendlyErrorMessage(e);
        AppSnackBar.error(message: _error!);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Dashboard dummy data
  Future<void> fetchData() async {
    try {
      _dashboardData = await _repository.fetchDashboardData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Get greeting based on time
  String getTimePeriod() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "Good Morning";
    if (hour >= 12 && hour < 17) return "Good Afternoon";
    if (hour >= 17 && hour < 20) return "Good Evening";
    return "Good Night";
  }

  Future<void> fetchOfflineVehiclesOver24h() async {
    try {
      final data = await _statusRepository.getDeviceStatusApi();
      final items = data?.items ?? const <status_model.Item>[];
      final now = DateTime.now();
      final List<OfflineVehicleInfo> result = [];

      for (final vehicle in items) {
        final online = _onlineToString(vehicle.online);
        final timeText = (vehicle.time).toLowerCase().trim();
        final isOffline = online == 'offline' &&
            timeText != 'not connected' &&
            timeText != 'expired';
        if (!isOffline) continue;

        final since = _resolveSince(vehicle);
        if (since == null) continue;

        final duration = now.difference(since);
        if (duration.inHours < 24) continue;

        result.add(
          OfflineVehicleInfo(
            vehicleName: vehicle.name,
            duration: duration,
            since: since,
          ),
        );
      }

      result.sort((a, b) => b.duration.compareTo(a.duration));
      _offlineVehiclesOver24h = result;
      notifyListeners();
    } catch (_) {
      // Keep dashboard resilient if this secondary list fails.
      _offlineVehiclesOver24h = [];
      notifyListeners();
    }
  }

  String _onlineToString(status_model.Online value) {
    switch (value) {
      case status_model.Online.ack:
        return 'ack';
      case status_model.Online.online:
        return 'online';
      case status_model.Online.offline:
        return 'offline';
    }
  }

  DateTime? _resolveSince(status_model.Item vehicle) {
    return _parseTimeTextToDateTime(vehicle.time);
  }

  DateTime? _parseTimeTextToDateTime(String? raw) {
    if (raw == null) return null;
    final text = raw.trim();
    if (text.isEmpty) return null;

    final lower = text.toLowerCase();
    if (lower == 'not connected' || lower == 'expired' || lower == 'n/a') {
      return null;
    }

    const formats = [
      "dd-MM-yyyy hh:mm:ss a",
      "dd-MM-yyyy HH:mm:ss",
      "yyyy-MM-dd HH:mm:ss",
      "yyyy-MM-dd hh:mm:ss a",
    ];
    for (final f in formats) {
      try {
        return DateFormat(f).parse(text, true).toLocal();
      } catch (_) {}
    }

    final iso = DateTime.tryParse(text);
    if (iso != null) return iso.toLocal();

    final matches = RegExp(
            r'(\d+)\s*(years?|y|months?|mo|days?|d|hours?|h|minutes?|mins?|m|seconds?|secs?|s)')
        .allMatches(lower);
    if (matches.isEmpty) return null;

    int totalSeconds = 0;
    for (final m in matches) {
      final value = int.tryParse(m.group(1) ?? '') ?? 0;
      final unit = m.group(2) ?? '';
      if (value <= 0) continue;
      if (unit.startsWith('y')) {
        totalSeconds += value * 365 * 24 * 3600;
      } else if (unit.startsWith('mo')) {
        totalSeconds += value * 30 * 24 * 3600;
      } else if (unit.startsWith('d')) {
        totalSeconds += value * 24 * 3600;
      } else if (unit.startsWith('h')) {
        totalSeconds += value * 3600;
      } else if (unit.startsWith('m')) {
        totalSeconds += value * 60;
      } else {
        totalSeconds += value;
      }
    }
    if (totalSeconds <= 0) return null;
    return DateTime.now().subtract(Duration(seconds: totalSeconds));
  }

  Future<void> refreshOnResume() async {
    await getDashboardProvider(forceLoading: true);
    await getDashboardHistoryProvider(forceRefresh: true);
  }

  Future<GetDashboardModel?> _getDashboardWithRetry() async {
    const maxAttempts = 3;
    for (int i = 1; i <= maxAttempts; i++) {
      final response = await _repository.getDashboardData(token: _token);
      if (response != null) return response;
      if (i < maxAttempts) {
        await Future<void>.delayed(Duration(milliseconds: 500 * i));
      }
    }
    return null;
  }

  Future<GetDashboardHistoryModel?> _getDashboardHistoryWithRetry() async {
    const maxAttempts = 3;
    for (int i = 1; i <= maxAttempts; i++) {
      final response = await _repository.getDashboardHistoryData(token: _token);
      if (response != null) return response;
      if (i < maxAttempts) {
        await Future<void>.delayed(Duration(milliseconds: 500 * i));
      }
    }
    return null;
  }

  String _friendlyErrorMessage(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('no address associated with hostname') ||
        text.contains('network is unreachable') ||
        text.contains('timed out') ||
        text.contains('clientexception')) {
      return "Network connection issue. Please check internet and try again.";
    }
    final raw = error.toString().trim();
    if (raw.startsWith('Exception:')) {
      return raw.replaceFirst('Exception:', '').trim();
    }
    return raw;
  }
}

class OfflineVehicleInfo {
  final String vehicleName;
  final DateTime since;
  final Duration duration;

  OfflineVehicleInfo({
    required this.vehicleName,
    required this.since,
    required this.duration,
  });
}
