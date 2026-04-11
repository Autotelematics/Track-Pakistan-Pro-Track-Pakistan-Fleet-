import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackerapp/data/models/get_device_history_model.dart';
import 'package:trackerapp/data/repositories/get_device_history_repository.dart';
import 'package:trackerapp/utils/error_message.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Trip model for the bottom-sheet trip list
// ──────────────────────────────────────────────────────────────────────────────
class TripSegment {
  final int tripIndex;
  final String startTime;
  final String endTime;
  final bool? isInProgress;
  final dynamic distance;
  final String duration;
  final dynamic topSpeed;
  final int startRouteIndex;
  final int endRouteIndex;
  final LatLng? startLatLng;
  final LatLng? endLatLng;

  const TripSegment({
    required this.tripIndex,
    required this.startTime,
    required this.endTime,
    this.isInProgress,
    required this.distance,
    required this.duration,
    required this.topSpeed,
    required this.startRouteIndex,
    required this.endRouteIndex,
    this.startLatLng,
    this.endLatLng,
  });
}

class ParkedSegment {
  final String stoppedAt;
  final String nextMoveAt;
  final String duration;
  final int durationSeconds;
  final int anchorRouteIndex;

  const ParkedSegment({
    required this.stoppedAt,
    required this.nextMoveAt,
    required this.duration,
    required this.durationSeconds,
    required this.anchorRouteIndex,
  });
}

class HistoryTimelineEntry {
  final TripSegment? trip;
  final ParkedSegment? parked;
  final bool isParked;

  const HistoryTimelineEntry._({
    this.trip,
    this.parked,
    required this.isParked,
  });

  factory HistoryTimelineEntry.trip(TripSegment segment) =>
      HistoryTimelineEntry._(trip: segment, isParked: false);

  factory HistoryTimelineEntry.parked(ParkedSegment segment) =>
      HistoryTimelineEntry._(parked: segment, isParked: true);
}

class AlertSegment {
  final String message;
  final String time;
  final LatLng position;
  final int anchorRouteIndex;
  final int speed;

  const AlertSegment({
    required this.message,
    required this.time,
    required this.position,
    required this.anchorRouteIndex,
    required this.speed,
  });
}

class _TimeInfo {
  final String label;
  final DateTime? dateTime;

  const _TimeInfo({required this.label, required this.dateTime});
}

class DeviceHistoryProvider extends ChangeNotifier {
  final GetDeviceHistoryRepository _repository = GetDeviceHistoryRepository();
  static const double _vehicleMarkerLogicalHeight = 30.0;
  static const double _statusMarkerLogicalSize = 34.0;
  static const double _markerRenderScale = 3.0;
  static BitmapDescriptor? _cachedStartIcon;
  static BitmapDescriptor? _cachedEndIcon;
  static BitmapDescriptor? _cachedParkingIcon;
  static BitmapDescriptor? _cachedEventsIcon;
  static BitmapDescriptor? _cachedCarIcon;

  // ── State ──────────────────────────────────────────────────────────────────
  GetDeviceHistoryModel? _deviceHistoryModel;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Map ────────────────────────────────────────────────────────────────────
  final List<Marker> _mapMarkers = [];
  Marker? _carMarker;
  final ValueNotifier<Marker?> carMarkerNotifier = ValueNotifier<Marker?>(null);
  final List<LatLng> _polyLatLng = [];
  final List<LatLng> _parkedLatLngs = [];
  final List<LatLng> _eventsLatLngs = [];
  final List<AlertSegment> _alertSegments = [];
  final Set<Polyline> _routePolyLine = {};
  LatLng? _startPacketLatLng;
  LatLng? _endPacketLatLng;

  // ── Playback ───────────────────────────────────────────────────────────────
  final List<LocationItem> _routeList = [];
  int _currentSliderValue = 0;
  final ValueNotifier<int> playbackSliderNotifier = ValueNotifier<int>(0);
  int _sliderValueMax = 0;
  bool _isPlaying = false;
  Timer? _segmentFrameTimer;
  static const int _baseSegmentDurationMs = 1600; // 1x speed baseline
  static const List<double> _playbackSpeedFactors = [0.25, 0.5, 1.0, 1.5, 2.0];
  int _selectedPlayBackSpeed = 0;
  int _segmentFromIndex = 0;
  double _segmentProgress = 0.0;
  DateTime? _segmentStartTime;

  // ── Car position (direct, no animation timer) ─────────────────────────────
  double _carLat = 0.0;
  double _carLng = 0.0;
  double _carRotation = 0.0;
  double? _playbackSmoothedRotation;

  // ── Icons ──────────────────────────────────────────────────────────────────
  BitmapDescriptor? _startIcon;
  BitmapDescriptor? _endIcon;
  BitmapDescriptor? _parkingIcon;
  BitmapDescriptor? _eventsIcon;
  BitmapDescriptor? _carIcon;

  // ── Statistics ─────────────────────────────────────────────────────────────
  int _tripCount = 0;
  int _stopCount = 0;
  double _totalDistance = 0.0;
  String _moveDuration = '';
  String _stopDuration = '';
  String _topSpeed = '';
  double _totalFuelSpent = 0.0;
  double _totalFuelCost = 0.0;

  // ── Trip segments ──────────────────────────────────────────────────────────
  final List<TripSegment> _tripSegments = [];
  final List<ParkedSegment> _parkedSegments = [];
  final List<HistoryTimelineEntry> _timelineEntries = [];
  int _selectedTripIndex = -1; // -1 = all trips

  // ── Getters ────────────────────────────────────────────────────────────────
  GetDeviceHistoryModel? get deviceHistoryModel => _deviceHistoryModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Marker> get mapMarkers =>
      _carMarker == null ? _mapMarkers : [..._mapMarkers, _carMarker!];
  List<Marker> get staticMapMarkers => _mapMarkers;
  Set<Polyline> get routePolyLine => _routePolyLine;
  int get currentSliderValue => _currentSliderValue;
  int get sliderValueMax => _sliderValueMax;
  bool get isPlaying => _isPlaying;
  int get selectedPlayBackSpeed => _selectedPlayBackSpeed;
  int get tripCount => _tripCount;
  int get stopCount => _stopCount;
  double get totalDistance => _totalDistance;
  String get moveDuration => _moveDuration;
  String get stopDuration => _stopDuration;
  String get topSpeed => _topSpeed;
  double get totalFuelSpent => _totalFuelSpent;
  double get totalFuelCost => _totalFuelCost;
  List<LatLng> get polyLatLng => _polyLatLng;
  List<LocationItem> get routeList => _routeList;
  List<int> get playBackTimeSpeeds => _playbackSpeedFactors
      .map((f) => (_baseSegmentDurationMs / f).round())
      .toList();
  List<TripSegment> get tripSegments => _tripSegments;
  List<ParkedSegment> get parkedSegments => _parkedSegments;
  List<AlertSegment> get alertSegments => _alertSegments;
  List<HistoryTimelineEntry> get timelineEntries => _timelineEntries;
  int get selectedTripIndex => _selectedTripIndex;

  // Animated car position getters
  double get carLat => _carLat;
  double get carLng => _carLng;
  double get carRotation => _carRotation;

  // ── Fetch ──────────────────────────────────────────────────────────────────
  Future<void> fetchDeviceHistory({
    required String deviceId,
    required String fromDate,
    required String fromTime,
    required String toDate,
    required String toTime,
    bool snapToRoad = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _deviceHistoryModel = await _repository.getDeviceHistoryApi(
        deviceId: deviceId,
        fromDate: fromDate,
        fromTime: fromTime,
        toDate: toDate,
        toTime: toTime,
        snapToRoad: snapToRoad,
      );
      await _processHistoryData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = AppErrorMessage.normalize(e);
      notifyListeners();
    }
  }

  // ── Process ────────────────────────────────────────────────────────────────
  Future<void> _processHistoryData() async {
    if (_deviceHistoryModel == null) return;
    _resetAllData();

    final summary = _deviceHistoryModel!.summary;
    _totalDistance =
        double.tryParse(summary.totalDistance.replaceAll(' Km', '')) ?? 0.0;
    _moveDuration = summary.moveDuration;
    _topSpeed = summary.topSpeed;
    _totalFuelSpent = summary.fuelSpent.totalFuelSpent;
    _totalFuelCost = summary.fuelSpent.totalFuelCost;
    _stopDuration = summary.stopDuration1;

    int tripIdx = 0;
    int? activeTripStartIndex;
    double activeTripDistanceKm = 0.0;
    int activeTripDurationSec = 0;
    double activeTripTopSpeed = 0.0;
    _TimeInfo? pendingStop;
    int pendingStopRouteIndex = 0;

    for (var historyItem in _deviceHistoryModel!.history) {
      if (historyItem.status == 1) {
        final moveStart =
            _extractTimeInfo(historyItem.items, preferLast: false);
        if (pendingStop != null) {
          final diffSec = pendingStop.dateTime != null &&
                  moveStart.dateTime != null
              ? moveStart.dateTime!.difference(pendingStop.dateTime!).inSeconds
              : 0;
          final parkedDurationSec = diffSec > 0 ? diffSec : 0;
          final parked = ParkedSegment(
            stoppedAt: pendingStop.label,
            nextMoveAt: moveStart.label,
            duration: _formatDuration(parkedDurationSec),
            durationSeconds: parkedDurationSec,
            anchorRouteIndex: pendingStopRouteIndex,
          );
          _parkedSegments.add(parked);
          _timelineEntries.add(HistoryTimelineEntry.parked(parked));
          pendingStop = null;
        }

        // status 1: moving points
        final prevLen = _routeList.length;
        _processMovingItems(historyItem.items);
        final addedPoints = _routeList.length - prevLen;
        if (addedPoints <= 0) continue;

        activeTripStartIndex ??= prevLen;
        activeTripDistanceKm += historyItem.distance;
        activeTripDurationSec += historyItem.timeSeconds ?? 0;
        final currentTopSpeed = historyItem.topSpeed is num
            ? (historyItem.topSpeed as num).toDouble()
            : double.tryParse('${historyItem.topSpeed ?? 0}') ?? 0.0;

        if (currentTopSpeed > activeTripTopSpeed) {
          activeTripTopSpeed = currentTopSpeed;
        }
      } else if (historyItem.status == 2) {
        // status 2: stop event, this closes one trip (move -> stop = 1 trip)
        _stopCount++;
        _appendRepresentativePointFromItems(
          historyItem.items,
          preferLast: false,
          includeInRoute: true,
        );
        _processStoppedItems(historyItem.items);

        if (activeTripStartIndex case final segStart?
            when segStart < _routeList.length) {
          final segEnd = _routeList.length - 1;
          final startItem = _routeList[segStart];
          final endItem = _routeList[segEnd];
          final seg = TripSegment(
            tripIndex: tripIdx++,
            startTime: startItem.rawTime ?? startItem.time ?? '—',
            endTime: endItem.rawTime ?? endItem.time ?? '—',
            isInProgress: false,
            distance: activeTripDistanceKm.toStringAsFixed(2),
            duration: _formatDuration(activeTripDurationSec),
            topSpeed: activeTripTopSpeed,
            startRouteIndex: segStart,
            endRouteIndex: segEnd,
            startLatLng: LatLng(startItem.lat, startItem.lng),
            endLatLng: LatLng(endItem.lat, endItem.lng),
          );
          _tripSegments.add(seg);
          _timelineEntries.add(HistoryTimelineEntry.trip(seg));
          _tripCount = _tripSegments.length;
          activeTripStartIndex = null;
          activeTripDistanceKm = 0.0;
          activeTripDurationSec = 0;
          activeTripTopSpeed = 0.0;
        }
        pendingStop = _extractTimeInfo(historyItem.items, preferLast: false);
        pendingStopRouteIndex =
            _routeList.isNotEmpty ? _routeList.length - 1 : 0;
      } else if (historyItem.status == 3) {
        // status 3: first packet of selected range
        _startPacketLatLng = _extractNormalizedPoint(
          historyItem.items,
          preferLast: false,
        );
        _appendRepresentativePointFromItems(
          historyItem.items,
          preferLast: false,
          includeInRoute: _routeList.isEmpty,
        );
      } else if (historyItem.status == 4) {
        // status 4: last packet of selected range
        _endPacketLatLng = _extractNormalizedPoint(
          historyItem.items,
          preferLast: true,
        );
        _appendRepresentativePointFromItems(
          historyItem.items,
          preferLast: true,
          includeInRoute: true,
        );
        if (activeTripStartIndex case final segStart?
            when segStart < _routeList.length) {
          final segEnd = _routeList.length - 1;
          final startItem = _routeList[segStart];
          final endItem = _routeList[segEnd];
          final seg = TripSegment(
            tripIndex: tripIdx++,
            startTime: startItem.rawTime ?? startItem.time ?? '—',
            endTime: endItem.rawTime ?? endItem.time ?? '—',
            isInProgress: true,
            distance: activeTripDistanceKm.toStringAsFixed(2),
            duration: _formatDuration(activeTripDurationSec),
            topSpeed: activeTripTopSpeed,
            startRouteIndex: segStart,
            endRouteIndex: segEnd,
            startLatLng: LatLng(startItem.lat, startItem.lng),
            endLatLng: LatLng(endItem.lat, endItem.lng),
          );
          _tripSegments.add(seg);
          _timelineEntries.add(HistoryTimelineEntry.trip(seg));
          _tripCount = _tripSegments.length;
          activeTripStartIndex = null;
          activeTripDistanceKm = 0.0;
          activeTripDurationSec = 0;
          activeTripTopSpeed = 0.0;
        }
      } else if (historyItem.status == 5) {
        _processAlertItems(historyItem);
      }
    }

    // Fallback close if API ended with moving block without explicit stop.
    if (activeTripStartIndex != null &&
        activeTripStartIndex < _routeList.length) {
      final segStart = activeTripStartIndex;
      final segEnd = _routeList.length - 1;
      final startItem = _routeList[segStart];
      final endItem = _routeList[segEnd];
      final seg = TripSegment(
        tripIndex: tripIdx++,
        startTime: startItem.rawTime ?? startItem.time ?? '—',
        endTime: endItem.rawTime ?? endItem.time ?? '—',
        isInProgress: true,
        distance: activeTripDistanceKm.toStringAsFixed(2),
        duration: _formatDuration(activeTripDurationSec),
        topSpeed: activeTripTopSpeed,
        startRouteIndex: segStart,
        endRouteIndex: segEnd,
        startLatLng: LatLng(startItem.lat, startItem.lng),
        endLatLng: LatLng(endItem.lat, endItem.lng),
      );
      _tripSegments.add(seg);
      _timelineEntries.add(HistoryTimelineEntry.trip(seg));
      _tripCount = _tripSegments.length;
    }

    _sliderValueMax = _routeList.isEmpty ? 0 : _routeList.length - 1;

    if (_routeList.isNotEmpty) {
      await _loadMapIcons();
      _setCompleteRoutePolyline(isPlaying: false);
      _setStartAndEndMarkers();
      _setParkingMarkers();
      _setEventsMarkers();
      _updateCarMarker(0);
    }
  }

  void _processMovingItems(List<LocationItem> items) {
    LatLng? previous = _polyLatLng.isNotEmpty ? _polyLatLng.last : null;
    for (var item in items) {
      final point = _normalizedPoint(item, previous: previous);
      if (point == null) continue;
      final normalizedItem =
          _copyWithLatLng(item, point.latitude, point.longitude);
      _routeList.add(normalizedItem);
      _polyLatLng.add(point);
      previous = point;
    }
  }

  void _processAlertItems(HistoryItem historyItem) {
    for (var item in historyItem.items) {
      final previous = _eventsLatLngs.isNotEmpty ? _eventsLatLngs.last : null;
      final point = _normalizedPoint(item, previous: previous);
      if (point == null) continue;

      _eventsLatLngs.add(point);
      final message = (historyItem.message ?? '').trim().isNotEmpty
          ? historyItem.message!.trim()
          : 'Alert';
      final time = item.rawTime ?? item.time ?? historyItem.rawTime;
      final anchorRouteIndex = _nearestRouteIndex(point);
      _alertSegments.add(
        AlertSegment(
          message: message,
          time: time,
          position: point,
          anchorRouteIndex: anchorRouteIndex,
          speed: item.speed,
        ),
      );
    }
  }

  int _nearestRouteIndex(LatLng point) {
    if (_routeList.isEmpty) return 0;
    var minDistance = double.infinity;
    var minIndex = 0;
    for (var i = 0; i < _routeList.length; i++) {
      final p = LatLng(_routeList[i].lat, _routeList[i].lng);
      final dist = _distanceMeters(point, p);
      if (dist < minDistance) {
        minDistance = dist;
        minIndex = i;
      }
    }
    return minIndex;
  }

  void _processStoppedItems(List<LocationItem> items) {
    if (items.isEmpty) return;
    final previous = _parkedLatLngs.isNotEmpty ? _parkedLatLngs.last : null;
    final point = _normalizedPoint(items[0], previous: previous);
    if (point == null) return;
    final isDuplicate = _parkedLatLngs.isNotEmpty &&
        (_parkedLatLngs.last.latitude - point.latitude).abs() < 0.000001 &&
        (_parkedLatLngs.last.longitude - point.longitude).abs() < 0.000001;
    if (isDuplicate) return;
    _parkedLatLngs.add(point);
  }

  LatLng? _extractNormalizedPoint(
    List<LocationItem> items, {
    required bool preferLast,
  }) {
    if (items.isEmpty) return null;
    final iterable = preferLast ? items.reversed : items;
    final previous = _polyLatLng.isNotEmpty ? _polyLatLng.last : null;
    for (final item in iterable) {
      final point = _normalizedPoint(item, previous: previous);
      if (point != null) return point;
    }
    return null;
  }

  LocationItem _copyWithLatLng(LocationItem source, double lat, double lng) {
    return LocationItem(
      id: source.id,
      rawTime: source.rawTime,
      altitude: source.altitude,
      course: source.course,
      speed: source.speed,
      lat: lat,
      lng: lng,
      distance: source.distance,
      valid: source.valid,
      other: source.other,
      time: source.time,
    );
  }

  String _formatDuration(int totalSec) {
    if (totalSec <= 0) return '0s';
    final h = totalSec ~/ 3600;
    final m = (totalSec % 3600) ~/ 60;
    final s = totalSec % 60;
    final parts = <String>[];
    if (h > 0) parts.add('${h}h');
    if (m > 0) parts.add('${m}m');
    if (s > 0 || parts.isEmpty) parts.add('${s}s');
    return parts.join(' ');
  }

  _TimeInfo _extractTimeInfo(
    List<LocationItem> items, {
    required bool preferLast,
  }) {
    if (items.isEmpty) return const _TimeInfo(label: '—', dateTime: null);
    final iterable = preferLast ? items.reversed : items;
    for (final item in iterable) {
      final label = item.rawTime ?? item.time ?? '—';
      final dt = _parseHistoryDateTime(item.rawTime ?? item.time);
      return _TimeInfo(label: label, dateTime: dt);
    }
    return const _TimeInfo(label: '—', dateTime: null);
  }

  DateTime? _parseHistoryDateTime(String? raw) {
    if (raw == null) return null;
    final text = raw.trim();
    if (text.isEmpty) return null;
    final normalized = text.replaceAll('T', ' ');
    final parts = normalized.split(' ');
    if (parts.length >= 2) {
      final date = parts[0];
      final time = parts[1];
      final d = date.split('-');
      final t = time.split(':');
      if (d.length == 3 && t.length >= 2) {
        final year = int.tryParse(d[0]);
        final month = int.tryParse(d[1]);
        final day = int.tryParse(d[2]);
        final hour = int.tryParse(t[0]);
        final minute = int.tryParse(t[1]);
        final second = t.length >= 3 ? int.tryParse(t[2]) ?? 0 : 0;
        if (year != null &&
            month != null &&
            day != null &&
            hour != null &&
            minute != null) {
          return DateTime(year, month, day, hour, minute, second);
        }
      }
    }
    return DateTime.tryParse(text);
  }

  void _appendRepresentativePointFromItems(
    List<LocationItem> items, {
    required bool preferLast,
    required bool includeInRoute,
  }) {
    if (items.isEmpty) return;
    final ordered = preferLast ? items.reversed : items;
    for (final item in ordered) {
      final previous = _polyLatLng.isNotEmpty ? _polyLatLng.last : null;
      final point = _normalizedPoint(item, previous: previous);
      if (point == null) continue;
      if (includeInRoute) {
        final isDuplicate = _polyLatLng.isNotEmpty &&
            (_polyLatLng.last.latitude - point.latitude).abs() < 0.000001 &&
            (_polyLatLng.last.longitude - point.longitude).abs() < 0.000001;
        if (!isDuplicate) {
          final normalizedItem =
              _copyWithLatLng(item, point.latitude, point.longitude);
          _routeList.add(normalizedItem);
          _polyLatLng.add(point);
        }
      }
      break;
    }
  }

  LatLng? _normalizedPoint(LocationItem item, {LatLng? previous}) {
    final lat = item.lat;
    final lng = item.lng;

    final direct = _isValidLatLng(lat, lng) ? LatLng(lat, lng) : null;
    final swapped = _isValidLatLng(lng, lat) ? LatLng(lng, lat) : null;

    if (direct == null && swapped == null) return null;
    if (direct != null && swapped == null) return direct;
    if (direct == null && swapped != null) return swapped;
    if (previous == null) return direct;

    final directDistance = _distanceMeters(previous, direct!);
    final swappedDistance = _distanceMeters(previous, swapped!);

    // Prefer the orientation that keeps route continuity and avoids big jumps.
    if (swappedDistance + 1 < directDistance) return swapped;
    return direct;
  }

  bool _isValidLatLng(double lat, double lng) {
    if (!lat.isFinite || !lng.isFinite) return false;
    if (lat == 0 || lng == 0) return false;
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;
    return true;
  }

  double _distanceMeters(LatLng a, LatLng b) {
    const earthRadius = 6371000.0;
    final dLat = _radians(b.latitude - a.latitude);
    final dLng = _radians(b.longitude - a.longitude);
    final lat1 = _radians(a.latitude);
    final lat2 = _radians(b.latitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return earthRadius * c;
  }

  double _radians(double degrees) => degrees * (math.pi / 180.0);

  // ── Icons ──────────────────────────────────────────────────────────────────
  Future<void> _loadMapIcons() async {
    _cachedStartIcon ??= await _buildStatusMarker(
      bgColor: Colors.green,
      letter: 'S',
      letterColor: Colors.white,
    );
    _cachedEndIcon ??= await _buildStatusMarker(
      bgColor: Colors.blue,
      letter: 'E',
      letterColor: Colors.white,
    );
    _cachedParkingIcon ??= await _buildStatusMarker(
      bgColor: Colors.red,
      letter: 'P',
      letterColor: Colors.white,
    );
    _cachedEventsIcon ??= await _buildStatusMarker(
      bgColor: Colors.red,
      icon: Icons.notifications_active_rounded,
      letterColor: Colors.white,
    );
    // Always use car_green.png for history playback car
    _cachedCarIcon ??=
        await _buildVehicleIconFromAsset('assets/images/car_green.png');

    _startIcon = _cachedStartIcon;
    _endIcon = _cachedEndIcon;
    _parkingIcon = _cachedParkingIcon;
    _eventsIcon = _cachedEventsIcon;
    _carIcon = _cachedCarIcon;
  }

  Future<BitmapDescriptor> _buildVehicleIconFromAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight:
          (_vehicleMarkerLogicalHeight * 1.22 * _markerRenderScale).round(),
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ByteData? bytes =
        await frame.image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
    return BitmapDescriptor.bytes(
      bytes.buffer.asUint8List(),
      width: frame.image.width.toDouble() / _markerRenderScale,
      height: frame.image.height.toDouble() / _markerRenderScale,
      imagePixelRatio: _markerRenderScale,
    );
  }

  // ── Polyline ───────────────────────────────────────────────────────────────
  void _setCompleteRoutePolyline({required bool isPlaying}) {
    _routePolyLine.clear();
    final color = isPlaying ? Colors.green : Colors.deepOrange;
    if (_polyLatLng.isNotEmpty) {
      _routePolyLine.add(Polyline(
        polylineId: const PolylineId('complete_route'),
        points: _polyLatLng,
        color: color,
        width: 4,
        zIndex: 0,
      ));
    }
  }

  // ── Static markers ─────────────────────────────────────────────────────────
  void _setStartAndEndMarkers() {
    if (_routeList.isEmpty || _startIcon == null || _endIcon == null) return;
    _mapMarkers.removeWhere((m) =>
        m.markerId == const MarkerId('start') ||
        m.markerId == const MarkerId('end'));
    final startPos = _startPacketLatLng ??
        LatLng(_routeList.first.lat, _routeList.first.lng);
    final endPos =
        _endPacketLatLng ?? LatLng(_routeList.last.lat, _routeList.last.lng);

    _mapMarkers.add(Marker(
      markerId: const MarkerId('start'),
      position: startPos,
      icon: _startIcon!,
      anchor: const Offset(0.5, 0.5),
      zIndexInt: 7,
    ));
    _mapMarkers.add(Marker(
      markerId: const MarkerId('end'),
      position: endPos,
      icon: _endIcon!,
      anchor: const Offset(0.5, 0.5),
      zIndexInt: 8,
    ));
  }

  void _setParkingMarkers() {
    if (_parkingIcon == null) return;
    int index = 0;
    for (var position in _parkedLatLngs) {
      _mapMarkers.add(Marker(
        markerId: MarkerId('parking_$index'),
        position: position,
        icon: _parkingIcon!,
        anchor: const Offset(0.5, 0.5),
        zIndexInt: 5,
      ));
      index++;
    }
  }

  void _setEventsMarkers() {
    if (_eventsIcon == null) return;
    int index = 0;
    for (var event in _alertSegments) {
      _mapMarkers.add(Marker(
        markerId: MarkerId('event_$index'),
        position: event.position,
        icon: _eventsIcon!,
        anchor: const Offset(0.5, 0.5),
        zIndexInt: 5,
        infoWindow: InfoWindow(
          title: event.message,
          snippet: event.time,
        ),
      ));
      index++;
    }
  }

  // ── Car marker (direct update, no animation timer) ────────────────────────
  void _updateCarMarker(int index) {
    if (index >= _routeList.length || _carIcon == null) return;

    final location = _routeList[index];
    final resolvedRotation = _resolvedPlaybackRotationForIndex(index);
    _playbackSmoothedRotation = resolvedRotation;
    _setCarMarkerPosition(
      lat: location.lat,
      lng: location.lng,
      rotation: resolvedRotation,
      speed: location.speed,
      snippet: location.time ?? '',
    );

    _currentSliderValue = index;
    playbackSliderNotifier.value = _currentSliderValue;
    _segmentFromIndex = index.clamp(0, _sliderValueMax);
    _segmentProgress = 0.0;
    _segmentStartTime = null;
    notifyListeners();
  }

  void _setCarMarkerPosition({
    required double lat,
    required double lng,
    required double rotation,
    required int speed,
    required String snippet,
  }) {
    if (_carIcon == null) return;
    const carMarkerId = MarkerId('car');
    final latDelta = (lat - _carLat).abs();
    final lngDelta = (lng - _carLng).abs();
    final angleDelta = _rotationDelta(rotation, _carRotation);
    if (latDelta < 0.0000008 && lngDelta < 0.0000008 && angleDelta < 0.6) {
      return;
    }

    _carLat = lat;
    _carLng = lng;
    _carRotation = rotation;

    final nextPosition = LatLng(_carLat, _carLng);
    if (_carMarker != null) {
      _carMarker = _carMarker!.copyWith(
        positionParam: nextPosition,
        rotationParam: _carRotation,
      );
      carMarkerNotifier.value = _carMarker;
      return;
    }

    _carMarker = Marker(
      markerId: carMarkerId,
      position: nextPosition,
      icon: _carIcon!,
      anchor: const Offset(0.5, 0.5),
      rotation: _carRotation,
      flat: false,
      zIndexInt: 10,
      infoWindow: InfoWindow(
        title: 'Speed: $speed km/h',
        snippet: snippet,
      ),
    );
    carMarkerNotifier.value = _carMarker;
  }

  double _interpolateRotation(double start, double end, double t) {
    double diff = (end - start) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return (start + diff * t) % 360;
  }

  double _rotationDelta(double a, double b) {
    var diff = (a - b).abs() % 360;
    if (diff > 180) diff = 360 - diff;
    return diff;
  }

  double _resolvedPlaybackRotationForIndex(int index) {
    final current = _routeList[index];
    final currentCourse = (current.course ?? 0).toDouble();
    final hasUsableCourse = currentCourse > 0.1;
    final isStopped = current.speed <= 0;

    if (hasUsableCourse) {
      return currentCourse;
    }

    if (isStopped) {
      return _playbackSmoothedRotation ?? _carRotation;
    }

    return _playbackSmoothedRotation ?? _carRotation;
  }

  Future<BitmapDescriptor> _buildStatusMarker({
    required Color bgColor,
    String? letter,
    IconData? icon,
    Color letterColor = Colors.white,
  }) async {
    const double size = _statusMarkerLogicalSize;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(
        0,
        0,
        size * _markerRenderScale,
        size * _markerRenderScale,
      ),
    )..scale(_markerRenderScale);
    final center = Offset(size / 2, size / 2);
    final radius = size * 0.34;

    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.22);
    canvas.drawCircle(center.translate(0, size * 0.04), radius, shadowPaint);

    final circlePaint = Paint()..color = bgColor;
    canvas.drawCircle(center, radius, circlePaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.05;
    canvas.drawCircle(center, radius, borderPaint);

    final glyph =
        icon != null ? String.fromCharCode(icon.codePoint) : (letter ?? '');
    final textStyle = TextStyle(
      color: letterColor,
      fontSize: icon != null ? size * 0.48 : size * 0.40,
      fontWeight: FontWeight.w800,
      fontFamily: icon?.fontFamily,
      package: icon?.fontPackage,
    );
    final tp = TextPainter(
      text: TextSpan(text: glyph, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        center.dx - (tp.width / 2),
        center.dy - (tp.height / 2),
      ),
    );

    final image = await recorder.endRecording().toImage(
          (size * _markerRenderScale).round(),
          (size * _markerRenderScale).round(),
        );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
    return BitmapDescriptor.bytes(
      Uint8List.view(data.buffer),
      width: size,
      height: size,
      imagePixelRatio: _markerRenderScale,
    );
  }

  // ── Playback controls ──────────────────────────────────────────────────────
  void playPause() => _isPlaying ? pausePlayback() : startPlayback();

  void startPlayback() {
    if (_routeList.isEmpty) return;
    if (_currentSliderValue >= _sliderValueMax) {
      _updateCarMarker(0);
    }

    _isPlaying = true;
    _setCompleteRoutePolyline(isPlaying: true);
    notifyListeners();

    _segmentFrameTimer?.cancel();
    _segmentFromIndex = _currentSliderValue.clamp(0, _sliderValueMax);
    _playbackSmoothedRotation ??= _carRotation;
    final segmentMs = _currentSegmentDurationMs;
    _segmentStartTime = DateTime.now().subtract(
      Duration(
        milliseconds: (segmentMs * _segmentProgress).round(),
      ),
    );

    // Smoothly interpolate between route points to avoid visible marker jumps.
    _segmentFrameTimer = Timer.periodic(const Duration(milliseconds: 36), (_) {
      if (!_isPlaying || _routeList.length < 2) return;
      if (_segmentFromIndex >= _sliderValueMax) {
        pausePlayback();
        return;
      }

      final segmentMs = _currentSegmentDurationMs;
      final from = _routeList[_segmentFromIndex];
      final to = _routeList[_segmentFromIndex + 1];
      _segmentStartTime ??= DateTime.now();
      final elapsedMs =
          DateTime.now().difference(_segmentStartTime!).inMilliseconds;
      final t = (elapsedMs / segmentMs).clamp(0.0, 1.0);
      _segmentProgress = t;

      final lat = from.lat + ((to.lat - from.lat) * t);
      final lng = from.lng + ((to.lng - from.lng) * t);
      final fromCourse = _resolvedPlaybackRotationForIndex(_segmentFromIndex);
      final toCourse = _resolvedPlaybackRotationForIndex(_segmentFromIndex + 1);
      final interpolatedCourse = _interpolateRotation(fromCourse, toCourse, t);
      final previousRotation = _playbackSmoothedRotation ?? interpolatedCourse;
      final rotation =
          _interpolateRotation(previousRotation, interpolatedCourse, 0.22);
      _playbackSmoothedRotation = rotation;
      final speed = (from.speed + ((to.speed - from.speed) * t)).round();
      final snippet = t < 0.5 ? (from.time ?? '') : (to.time ?? '');

      _setCarMarkerPosition(
        lat: lat,
        lng: lng,
        rotation: rotation,
        speed: speed,
        snippet: snippet,
      );

      if (t >= 1.0) {
        _currentSliderValue = _segmentFromIndex + 1;
        playbackSliderNotifier.value = _currentSliderValue;
        _segmentFromIndex = _currentSliderValue;
        _segmentProgress = 0.0;
        _segmentStartTime = DateTime.now();
      }
    });
  }

  void pausePlayback() {
    _isPlaying = false;
    _segmentFrameTimer?.cancel();
    _setCompleteRoutePolyline(isPlaying: false);
    notifyListeners();
  }

  void stopPlayback() {
    _isPlaying = false;
    _segmentFrameTimer?.cancel();
    _currentSliderValue = 0;
    playbackSliderNotifier.value = _currentSliderValue;
    _segmentFromIndex = 0;
    _segmentProgress = 0.0;
    _segmentStartTime = null;
    _playbackSmoothedRotation = null;
    _setCompleteRoutePolyline(isPlaying: false);
    _updateCarMarker(0);
  }

  void seekTo(int value) {
    if (value < 0 || value > _sliderValueMax) return;
    _segmentFromIndex = value.clamp(0, _sliderValueMax);
    playbackSliderNotifier.value = value.clamp(0, _sliderValueMax);
    _segmentProgress = 0.0;
    _segmentStartTime = null;
    _playbackSmoothedRotation = null;
    _updateCarMarker(value);
  }

  void changePlaybackSpeed() {
    _selectedPlayBackSpeed =
        (_selectedPlayBackSpeed + 1) % _playbackSpeedFactors.length;
    if (_isPlaying) {
      _segmentFrameTimer?.cancel();
      startPlayback();
    }
    notifyListeners();
  }

  String get playbackSpeedLabel {
    const speeds = ['0.25x', '0.5x', '1x', '1.5x', '2x'];
    return speeds[_selectedPlayBackSpeed];
  }

  int get _currentSegmentDurationMs {
    final factor = _playbackSpeedFactors[_selectedPlayBackSpeed];
    final duration = (_baseSegmentDurationMs / factor).round();
    return duration < 120 ? 120 : duration;
  }

  // ── Trip selection ─────────────────────────────────────────────────────────
  /// Jump playback to the start of a specific trip
  void selectTrip(int tripIndex) {
    if (tripIndex < 0 || tripIndex >= _tripSegments.length) return;
    _selectedTripIndex = tripIndex;
    final seg = _tripSegments[tripIndex];
    seekTo(seg.startRouteIndex);
    notifyListeners();
  }

  void clearTripSelection() {
    _selectedTripIndex = -1;
    notifyListeners();
  }

  // ── Bounds ─────────────────────────────────────────────────────────────────
  LatLngBounds? calculateBounds() {
    if (_polyLatLng.isEmpty) return null;
    double minLat = _polyLatLng.first.latitude;
    double maxLat = _polyLatLng.first.latitude;
    double minLng = _polyLatLng.first.longitude;
    double maxLng = _polyLatLng.first.longitude;

    for (final p in _polyLatLng) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  LatLngBounds? calculateTripBounds(TripSegment seg) {
    final points = _polyLatLng.sublist(
      seg.startRouteIndex.clamp(0, _polyLatLng.length - 1),
      (seg.endRouteIndex + 1).clamp(0, _polyLatLng.length),
    );
    if (points.isEmpty) return null;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _resetAllData() {
    _mapMarkers.clear();
    _carMarker = null;
    carMarkerNotifier.value = null;
    _polyLatLng.clear();
    _parkedLatLngs.clear();
    _eventsLatLngs.clear();
    _alertSegments.clear();
    _routePolyLine.clear();
    _routeList.clear();
    _tripSegments.clear();
    _parkedSegments.clear();
    _timelineEntries.clear();
    _currentSliderValue = 0;
    playbackSliderNotifier.value = 0;
    _sliderValueMax = 0;
    _tripCount = 0;
    _stopCount = 0;
    _totalDistance = 0.0;
    _moveDuration = '';
    _stopDuration = '';
    _topSpeed = '';
    _totalFuelSpent = 0.0;
    _totalFuelCost = 0.0;
    _carLat = 0.0;
    _carLng = 0.0;
    _carRotation = 0.0;
    _selectedTripIndex = -1;
    _startPacketLatLng = null;
    _endPacketLatLng = null;
    _isPlaying = false;
    _segmentFrameTimer?.cancel();
  }

  @override
  void dispose() {
    _segmentFrameTimer?.cancel();
    carMarkerNotifier.dispose();
    playbackSliderNotifier.dispose();
    super.dispose();
  }
}
