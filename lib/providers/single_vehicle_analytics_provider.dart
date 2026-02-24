import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trackerapp/data/models/get_device_history_model.dart';
import 'package:trackerapp/data/repositories/get_device_history_repository.dart';

class AnalyticsChartData {
  final String label;
  final double value;
  AnalyticsChartData(this.label, this.value);
}

class AnalyticsBarChartData {
  final String label;
  final double value;
  AnalyticsBarChartData(this.label, this.value);
}

/// Tells the UI which grouping mode is active so it can show/hide charts
enum AnalyticsGroupMode { hourly, daily }

class SingleVehicleAnalyticsProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  List<LocationItem> _allPoints = [];
  List<HistoryItem> _historyItems = [];

  // ── Summary stats ──────────────────────────────────────────────
  String totalDistance = "0 km";
  String maxSpeed = "0 km/h";
  String driveTime = "0h 0m";
  String stopTime = "0h 0m";
  String fuelUsed = "0 LTR";
  String amountSpent = "PKR 0";

  // ── Chart data ─────────────────────────────────────────────────
  List<AnalyticsChartData> speedChartData = [];
  List<AnalyticsChartData> distanceChartData = [];
  List<AnalyticsChartData> fuelChartData = [];       // only valid in hourly mode
  List<AnalyticsBarChartData> stopDurationChartData = [];
  List<AnalyticsChartData> engineHoursChartData = [];

  /// Whether charts are grouped by hour (single day) or by date (multi-day)
  AnalyticsGroupMode groupMode = AnalyticsGroupMode.hourly;

  // ── Internals ──────────────────────────────────────────────────
  final _repo = GetDeviceHistoryRepository();
  final _apiDateFmt = DateFormat("yyyy-MM-dd");
  final _apiDateTimeFmt = DateFormat("yyyy-MM-dd HH:mm:ss");

  // ══════════════════════════════════════════════════════════════
  //  Public API
  // ══════════════════════════════════════════════════════════════

  Future<void> fetchAnalytics({
    required String deviceId,
    required String fromDate,
    required String fromTime,
    required String toDate,
    required String toTime,
  }) async {
    isLoading = true;
    errorMessage = null;
    _clearData();
    notifyListeners();

    // Decide grouping mode BEFORE fetching
    groupMode = _isMultiDay(fromDate, toDate)
        ? AnalyticsGroupMode.daily
        : AnalyticsGroupMode.hourly;

    try {
      final result = await _repo.getDeviceHistoryApi(
        deviceId: deviceId,
        fromDate: fromDate,
        fromTime: fromTime,
        toDate: toDate,
        toTime: toTime,
        snapToRoad: false,
      );

      _historyItems = result.history;
      _allPoints = _historyItems.expand((item) => item.items).toList();

      _computeStatsFromSummary(result.summary);
      _buildChartData();
    } catch (e) {
      errorMessage = "Failed to load analytics: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════
  //  Private helpers
  // ══════════════════════════════════════════════════════════════

  bool _isMultiDay(String fromDate, String toDate) => fromDate != toDate;

  void _clearData() {
    _allPoints = [];
    _historyItems = [];
    speedChartData = [];
    distanceChartData = [];
    fuelChartData = [];
    stopDurationChartData = [];
    engineHoursChartData = [];
  }

  void _computeStatsFromSummary(HistorySummary summary) {
    totalDistance = summary.totalDistance.isNotEmpty ? summary.totalDistance : "0 km";
    maxSpeed = summary.topSpeed.isNotEmpty ? summary.topSpeed : "0 km/h";
    driveTime = summary.moveDuration.isNotEmpty ? summary.moveDuration : "0h 0m";
    stopTime = summary.stopDuration1.isNotEmpty ? summary.stopDuration1 : "0h 0m";
    fuelUsed = "${summary.fuelSpent.totalFuelSpent.toStringAsFixed(2)} LTR";
    amountSpent = "PKR ${summary.fuelSpent.totalFuelCost.toStringAsFixed(0)}";
  }

  // ── Master chart builder ───────────────────────────────────────

  void _buildChartData() {
    if (_allPoints.isEmpty) return;

    if (groupMode == AnalyticsGroupMode.hourly) {
      _buildHourlyCharts();
    } else {
      _buildDailyCharts();
    }

    // Stop duration works the same regardless of grouping mode
    _buildStopDurations();
  }

  // ── HOURLY (single day) ────────────────────────────────────────

  void _buildHourlyCharts() {
    final Map<String, List<LocationItem>> buckets = {};
    for (final point in _allPoints) {
      final label = _hourLabel(point.rawTime);
      buckets.putIfAbsent(label, () => []).add(point);
    }

    final sortedKeys = buckets.keys.toList()
      ..sort((a, b) => _parseHourLabel(a).compareTo(_parseHourLabel(b)));

    // Speed – max speed per hour
    speedChartData = sortedKeys.map((key) {
      final pts = buckets[key]!;
      final maxSpd = pts.map((p) => p.speed.toDouble()).reduce((a, b) => a > b ? a : b);
      return AnalyticsChartData(key, maxSpd);
    }).toList();

    // Distance – cumulative distance at last point of each hour
    distanceChartData = sortedKeys.map((key) {
      final pts = buckets[key]!;
      return AnalyticsChartData(key, pts.last.distance);
    }).toList();

    // Fuel – proportional to distance per hour
    final totalDist = _allPoints.last.distance;
    final totalFuel = _parseFuel();
    fuelChartData = distanceChartData.map((d) {
      final fuelVal = totalDist > 0 ? (d.value / totalDist) * totalFuel : 0.0;
      return AnalyticsChartData(d.label, double.parse(fuelVal.toStringAsFixed(2)));
    }).toList();

    // Engine hours – cumulative moving time per hour bucket
    engineHoursChartData = _buildEngineHours(sortedKeys, buckets);
  }

  // ── DAILY (multi-day) ──────────────────────────────────────────

  void _buildDailyCharts() {
    // Group points by date string "dd MMM" e.g. "14 Feb"
    final Map<String, List<LocationItem>> buckets = {};
    for (final point in _allPoints) {
      final label = _dateLabel(point.rawTime);
      buckets.putIfAbsent(label, () => []).add(point);
    }

    final sortedKeys = buckets.keys.toList()
      ..sort((a, b) => _parseDateLabel(a).compareTo(_parseDateLabel(b)));

    // Speed – max speed per day
    speedChartData = sortedKeys.map((key) {
      final pts = buckets[key]!;
      final maxSpd = pts.map((p) => p.speed.toDouble()).reduce((a, b) => a > b ? a : b);
      return AnalyticsChartData(key, maxSpd);
    }).toList();

    // Distance – total distance covered each day
    // We compute per-day distance from first to last point of that day
    distanceChartData = sortedKeys.map((key) {
      final pts = buckets[key]!;
      // Distance field is cumulative across entire trip; so day delta = last - first
      final dayDelta = (pts.last.distance - pts.first.distance).clamp(0, double.infinity).toDouble();
      return AnalyticsChartData(key, double.parse(dayDelta.toStringAsFixed(2)));
    }).toList();

    // Fuel graph is NOT shown in daily mode (fuelChartData stays empty)
    fuelChartData = [];

    // Engine hours – cumulative moving seconds per day
    engineHoursChartData = _buildEngineHoursDaily(sortedKeys, buckets);
  }

  // ── Engine hours helpers ───────────────────────────────────────

  /// Hourly cumulative engine hours
  List<AnalyticsChartData> _buildEngineHours(
      List<String> sortedKeys,
      Map<String, List<LocationItem>> buckets,
      ) {
    double cumulativeHours = 0;
    final result = <AnalyticsChartData>[];
    DateTime? prevTime;

    for (final key in sortedKeys) {
      final pts = buckets[key]!;
      for (final p in pts) {
        final currentTime = _parseTime(p.rawTime);
        if (p.speed > 0 && prevTime != null) {
          final diffSecs = currentTime.difference(prevTime!).inSeconds.abs();
          cumulativeHours += diffSecs / 3600.0;
        }
        prevTime = currentTime;
      }
      result.add(AnalyticsChartData(key, double.parse(cumulativeHours.toStringAsFixed(2))));
    }
    return result;
  }

  /// Daily engine hours (moving time per day, not cumulative across days)
  List<AnalyticsChartData> _buildEngineHoursDaily(
      List<String> sortedKeys,
      Map<String, List<LocationItem>> buckets,
      ) {
    final result = <AnalyticsChartData>[];

    for (final key in sortedKeys) {
      final pts = buckets[key]!;
      double dayHours = 0;
      DateTime? prevTime;

      for (final p in pts) {
        final currentTime = _parseTime(p.rawTime);
        if (p.speed > 0 && prevTime != null) {
          final diffSecs = currentTime.difference(prevTime!).inSeconds.abs();
          dayHours += diffSecs / 3600.0;
        }
        prevTime = currentTime;
      }
      result.add(AnalyticsChartData(key, double.parse(dayHours.toStringAsFixed(2))));
    }
    return result;
  }

  // ── Stop durations ─────────────────────────────────────────────

  void _buildStopDurations() {
    final stops = <AnalyticsBarChartData>[];
    int stopCount = 0;

    for (final item in _historyItems) {
      if (item.status == 0 && item.timeSeconds != null && item.timeSeconds! > 0) {
        stopCount++;
        final mins = (item.timeSeconds! / 60).roundToDouble();
        stops.add(AnalyticsBarChartData("Stop $stopCount", mins));
      }
    }

    // Fallback: derive stops from speed == 0 runs in LocationItems
    if (stops.isEmpty && _allPoints.isNotEmpty) {
      int fallbackCount = 0;
      DateTime? stopStart;

      for (int i = 0; i < _allPoints.length; i++) {
        final p = _allPoints[i];
        if (p.speed == 0) {
          stopStart ??= _parseTime(p.rawTime);
        } else {
          if (stopStart != null) {
            final stopEnd = _parseTime(_allPoints[i - 1].rawTime);
            final mins = stopEnd.difference(stopStart!).inMinutes.abs();
            if (mins > 0) {
              fallbackCount++;
              stops.add(AnalyticsBarChartData("Stop $fallbackCount", mins.toDouble()));
            }
            stopStart = null;
          }
        }
      }
    }

    stopDurationChartData = stops;
  }

  // ── Label helpers ──────────────────────────────────────────────

  /// e.g. "2PM", "11AM"
  String _hourLabel(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return "00";
    try {
      final parts = rawTime.split(' ');
      final timePart = parts.length > 1 ? parts[1] : parts[0];
      final hour = int.parse(timePart.split(':')[0]);
      final suffix = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0
          ? 12
          : hour > 12
          ? hour - 12
          : hour;
      return "$displayHour$suffix";
    } catch (_) {
      return rawTime ?? "00";
    }
  }

  int _parseHourLabel(String label) {
    try {
      final isPm = label.endsWith('PM');
      final h = int.parse(label.replaceAll(RegExp(r'[APM]'), '').trim());
      if (isPm && h != 12) return h + 12;
      if (!isPm && h == 12) return 0;
      return h;
    } catch (_) {
      return 0;
    }
  }

  /// e.g. "14 Feb", "01 Mar"
  String _dateLabel(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return "??";
    try {
      final dt = _parseTime(rawTime);
      return DateFormat("dd MMM").format(dt);
    } catch (_) {
      return rawTime ?? "??";
    }
  }

  DateTime _parseDateLabel(String label) {
    try {
      return DateFormat("dd MMM").parse(label);
    } catch (_) {
      return DateTime(2000);
    }
  }

  DateTime _parseTime(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return DateTime.now();
    try {
      if (rawTime.contains(' ')) {
        return _apiDateTimeFmt.parse(rawTime);
      }
      final now = DateTime.now();
      final t = rawTime.split(':');
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(t[0]),
        int.parse(t[1]),
        t.length > 2 ? int.parse(t[2]) : 0,
      );
    } catch (_) {
      return DateTime.now();
    }
  }

  double _parseFuel() {
    try {
      return double.parse(fuelUsed.replaceAll(' LTR', '').trim());
    } catch (_) {
      return 0.0;
    }
  }
}