import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart'
    as device_list;
import 'package:trackerapp/data/models/get_device_live_tracking_model.dart';
import 'package:trackerapp/data/repositories/get_device_live_tracking_repository.dart';
import 'package:trackerapp/utils/session_guard.dart';

class VehicleTrackingProvider extends ChangeNotifier {
  static const bool _kEnableMotionDebugLogs = false;
  static const bool _kEnableAnimationDebugLogs = true;

  final GetDeviceLiveTrackingRepository repository =
      GetDeviceLiveTrackingRepository();
  GetDeviceLiveTrackingModel? deviceData;

  Timer? _refreshTimer;
  bool _isDisposed = false;
  bool _isFetching = false;
  bool _pendingRefresh = false;
  int? _activeDeviceId;
  bool isLoading = true;
  bool hasNoData = false;
  String? noDataMessage;
  String? errorMessage;
  DateTime? _lastPacketTime;
  DateTime? _lastFreshPacketAt;
  String? _lastPacketFingerprint;
  double deviceLat = 0.0;
  double deviceLng = 0.0;
  double deviceRotation = 0.0;
  int deviceSpeed = 0;
  bool isInitial = true;
  String _resolvedOnlineStatus = 'offline';
  String _visualMarkerStatus = 'offline';
  int _nonOnlinePacketStreak = 0;
  DateTime? _lastVisualMovingAt;
  int _markerAnimationDurationMs = _pollIntervalSeconds * 1000;
  double _smoothedCourse = 0.0;
  double _lastMovingCourse = 0.0;
  final double _smoothingAlpha = 0.3;
  final double _minCourseChange = 5.0;
  static const int _pollIntervalSeconds = 8;
  static const int _movingVisualHoldSeconds = 24;
  static final Set<int> _tailConsumedInSession = <int>{};

  // Map controls (from lite)
  MapType currentMapType = MapType.normal;
  bool enableTraffic = false;
  double currentZoom = 15.5;
  bool followVehicle = true;
  bool rulerMode = false;
  final List<LatLng> _rulerPoints = [];
  Position? _userPosition;
  bool isLocatingUser = false;
  String? locationError;

  Item? get item => deviceData?.item;
  device_list.Param? get param => item?.param;

  String get deviceName => item?.name ?? 'Unknown Vehicle';
  String get deviceId => item?.id.toString() ?? 'Unknown Vehicle';
  String get vehicleType => item?.vehicleType ?? '';
  String get status {
    final normalized = _normalizeStatus(item?.online);
    if (normalized.isNotEmpty) return normalized;
    return _resolvedOnlineStatus;
  }

  double get odometer => _safeDouble(item?.odometer);
  String get totalDistance => odometer.toStringAsFixed(2);
  double get paramOdometer => _safeDouble(param?.odometer);
  double get paramTotalDistance => _safeDouble(param?.totaldistance);
  double get engineHours => _safeDouble(param?.enginehours);
  int get batteryLevel => _safeInt(param?.batterylevel);
  int get rssi => _safeInt(param?.rssi);
  String get ignitionParam => param?.ignition ?? '';
  String get motionParam => param?.motion ?? '';
  String get chargeParam => param?.charge ?? '';
  String get blockedParam => param?.blocked ?? '';
  String get address => item?.addr ?? 'Fetching location...';
  String get lastUpdate => item?.time ?? '';
  List<Sensor>? get sensors => item?.sensors;
  double get latitude => deviceLat;
  double get longitude => deviceLng;
  double get rawCourse => _safeDouble(item?.course) % 360;
  String get motionStatusKey {
    if (deviceSpeed > 0 || status == 'online') return 'online';
    final lastMovingAt = _lastVisualMovingAt;
    if (lastMovingAt != null &&
        DateTime.now().difference(lastMovingAt).inSeconds <=
            _movingVisualHoldSeconds) {
      return 'online';
    }
    return status;
  }

  String get markerVisualStatus => _visualMarkerStatus;

  int get secondsSinceLastPacket {
    if (_lastPacketTime == null) return 0;
    final age = DateTime.now().difference(_lastPacketTime!).inSeconds;
    return age < 0 ? 0 : age;
  }

  int get secondsSinceFreshPacket {
    if (_lastFreshPacketAt == null) return 0;
    final age = DateTime.now().difference(_lastFreshPacketAt!).inSeconds;
    return age < 0 ? 0 : age;
  }

  bool get shouldShowWaitingForPacket {
    final age = secondsSinceFreshPacket;
    return markerVisualStatus == 'online' && age >= (_pollIntervalSeconds + 1);
  }

  String _packetIdentityFromItem(Item item) {
    final ts = item.timestamp;
    if (ts != null && ts > 0) return 'ts:$ts';
    final ackTs = item.acktimestamp;
    if (ackTs != null && ackTs > 0) return 'ack:$ackTs';
    return 'pos:${item.lat ?? ""}|${item.lng ?? ""}|${item.course ?? 0}|${item.speed ?? 0}';
  }

  int get markerAnimationDurationMs => _markerAnimationDurationMs;

  double get course {
    return deviceSpeed > 0 ? _smoothedCourse : _lastMovingCourse;
  }

  String get deviceStopDuration => item?.stopDuration?.toString() ?? '0';
  Position? get userPosition => _userPosition;

  Color get ignitionColor {
    switch (motionStatusKey) {
      case 'online':
        return AppColors.green;
      case 'ack':
        return AppColors.red;
      case 'engine':
        return AppColors.yellow;
      case 'offline':
        return AppColors.blueCyan;
      default:
        return AppColors.blueCyan;
    }
  }

  String get vehicleStatusText {
    switch (motionStatusKey) {
      case 'online':
        return 'Moving';
      case 'ack':
        return 'Stopped';
      case 'engine':
        return 'Idle';
      default:
        return 'Offline';
    }
  }

  String _normalizeStatus(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    switch (value) {
      case 'online':
      case 'running':
      case 'moving':
        return 'online';
      case 'ack':
      case 'stop':
      case 'stopped':
        return 'ack';
      case 'engine':
      case 'idle':
        return 'engine';
      case 'offline':
        return 'offline';
      default:
        return '';
    }
  }

  // Safe parsing helpers (from lite)
  static double _safeDouble(dynamic val, {double defaultValue = 0.0}) {
    try {
      if (val == null ||
          val.toString().trim().isEmpty ||
          val.toString() == '-' ||
          val.toString() == 'null') {
        if (kDebugMode) {
          debugPrint('Invalid double value: $val, returning $defaultValue');
        }
        return defaultValue;
      }
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.parse(val.toString());
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'Error parsing double: $val, error: $e, returning $defaultValue');
      }
      return defaultValue;
    }
  }

  static int _safeInt(dynamic val, {int defaultValue = 0}) {
    try {
      if (val == null ||
          val.toString().trim().isEmpty ||
          val.toString() == '-' ||
          val.toString() == 'null') {
        if (kDebugMode) {
          debugPrint('Invalid int value: $val, returning $defaultValue');
        }
        return defaultValue;
      }
      if (val is int) return val;
      return int.parse(val.toString());
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'Error parsing int: $val, error: $e, returning $defaultValue');
      }
      return defaultValue;
    }
  }

  // Angle utilities (from lite)
  double radians(double degrees) => degrees * pi / 180;
  double degrees(double radians) => radians * 180 / pi;

  double calculateBearing(LatLng start, LatLng end) {
    double startLat = radians(start.latitude);
    double startLng = radians(start.longitude);
    double endLat = radians(end.latitude);
    double endLng = radians(end.longitude);

    double dLng = endLng - startLng;

    double y = sin(dLng) * cos(endLat);
    double x =
        cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLng);

    double bearing = atan2(y, x);
    return (degrees(bearing) + 360) % 360;
  }

  double _normalizeAngle(double angle) {
    return (angle % 360 + 360) % 360;
  }

  double _angleDifference(double a, double b) {
    double diff = _normalizeAngle(b - a);
    return diff > 180 ? 360 - diff : diff;
  }

  void _updateSmoothedCourse(double newCourse) {
    final normalizedNew = _normalizeAngle(newCourse);
    final diff = _angleDifference(_smoothedCourse, normalizedNew);

    if (diff > _minCourseChange) {
      _smoothedCourse = normalizedNew;
      if (kDebugMode) debugPrint("Significant course change: $_smoothedCourse");
    } else {
      final aRad = _smoothedCourse * pi / 180;
      final bRad = normalizedNew * pi / 180;

      final x = (1 - _smoothingAlpha) * cos(aRad) + _smoothingAlpha * cos(bRad);
      final y = (1 - _smoothingAlpha) * sin(aRad) + _smoothingAlpha * sin(bRad);

      final avg = atan2(y, x) * 180 / pi;
      _smoothedCourse = _normalizeAngle(avg);
      if (kDebugMode) debugPrint("Smoothed course to: $_smoothedCourse");
    }
  }

  // Distance calculation (from lite)
  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371;
    double lat1 = radians(start.latitude);
    double lng1 = radians(start.longitude);
    double lat2 = radians(end.latitude);
    double lng2 = radians(end.longitude);

    double dLat = lat2 - lat1;
    double dLng = lng2 - lng1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in km
  }

  double? get distanceToVehicleKm {
    if (_userPosition == null || deviceLat == 0.0 || deviceLng == 0.0) {
      return null;
    }
    return _calculateDistance(
      LatLng(_userPosition!.latitude, _userPosition!.longitude),
      LatLng(deviceLat, deviceLng),
    );
  }

  String get distanceToVehicleLabel {
    final km = distanceToVehicleKm;
    if (km == null) return 'Distance unavailable';
    if (km < 1) {
      return '${(km * 1000).round()} m away';
    }
    return '${km.toStringAsFixed(2)} km away';
  }

  List<LatLng> get rulerPoints => List.unmodifiable(_rulerPoints);

  double get rulerDistanceKm {
    if (_rulerPoints.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 1; i < _rulerPoints.length; i++) {
      total += _calculateDistance(_rulerPoints[i - 1], _rulerPoints[i]);
    }
    return total;
  }

  String get rulerDistanceLabel {
    if (_rulerPoints.length < 2) return 'Tap points to measure';
    final km = rulerDistanceKm;
    if (km < 1) {
      final meters = (km * 1000).round();
      return '$meters m';
    }
    return '${km.toStringAsFixed(2)} km';
  }

  Set<Marker> get rulerMarkers {
    if (_rulerPoints.isEmpty) return {};
    return _rulerPoints
        .asMap()
        .entries
        .map(
          (entry) => Marker(
            markerId: MarkerId('ruler_point_${entry.key}'),
            position: entry.value,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            anchor: const Offset(0.5, 1),
          ),
        )
        .toSet();
  }

  Set<Polyline> get rulerPolylines {
    if (_rulerPoints.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('ruler_line'),
        points: _rulerPoints,
        width: 4,
        color: AppColors.blueCyan,
      ),
    };
  }

  bool _hasConsumedInitialTail(int deviceId) {
    return _tailConsumedInSession.contains(deviceId);
  }

  Future<void> _markInitialTailConsumed(int deviceId) async {
    _tailConsumedInSession.add(deviceId);
  }

  void _updateMarkerVisualStatus({
    required String packetStatus,
    required int speed,
    required double distanceMeters,
  }) {
    final movingSignal =
        packetStatus == 'online' || speed > 0 || distanceMeters > 2.0;
    if (movingSignal) {
      _visualMarkerStatus = 'online';
      _nonOnlinePacketStreak = 0;
      return;
    }

    _nonOnlinePacketStreak += 1;
    if (_nonOnlinePacketStreak >= 3) {
      _visualMarkerStatus = packetStatus;
    }
  }

  bool _hasValidTailForInitialAnimation() {
    final tail = deviceData?.item?.tail;
    if (tail == null) {
      _motionLog('tail check: tail=null');
      return false;
    }
    if (tail.length < 2) {
      _motionLog('tail check: tail length=${tail.length} (<2)');
      return false;
    }
    final secondLast = tail[tail.length - 2];
    final last = tail.last;
    final lat1 = _safeDouble(secondLast.lat);
    final lng1 = _safeDouble(secondLast.lng);
    final lat2 = _safeDouble(last.lat);
    final lng2 = _safeDouble(last.lng);
    final isValid = lat1 != 0.0 && lng1 != 0.0 && lat2 != 0.0 && lng2 != 0.0;
    _motionLog(
      'tail check: len=${tail.length} p1=($lat1,$lng1) p2=($lat2,$lng2) valid=$isValid',
    );
    return isValid;
  }

  // Animation logic adapted from lite Cubit
  Future<bool> _handleInitialAnimation() async {
    if (_isDisposed) return false;
    if (deviceData?.item == null) {
      if (kDebugMode) debugPrint('No device data for initial animation');
      return false;
    }

    double liveLat = _safeDouble(deviceData!.item!.lat);
    double liveLng = _safeDouble(deviceData!.item!.lng);
    double liveCourse = _safeDouble(deviceData!.item!.course);
    int speed = _safeInt(deviceData!.item!.speed);
    var tailList = deviceData!.item!.tail;

    if (tailList != null &&
        tailList.length >= 2 &&
        liveLat != 0.0 &&
        liveLng != 0.0 &&
        speed != 0) {
      var secondLastTail = tailList[tailList.length - 2];
      var lastTail = tailList.last;
      double lat1 = _safeDouble(secondLastTail.lat);
      double lng1 = _safeDouble(secondLastTail.lng);
      double lat2 = _safeDouble(lastTail.lat);
      double lng2 = _safeDouble(lastTail.lng);

      if (lat1 != 0.0 && lng1 != 0.0 && lat2 != 0.0 && lng2 != 0.0) {
        double tailBearing =
            calculateBearing(LatLng(lat1, lng1), LatLng(lat2, lng2));
        deviceLat = lat1;
        deviceLng = lng1;
        deviceRotation = tailBearing;
        deviceSpeed = speed;
        _updateSmoothedCourse(tailBearing);
        _lastMovingCourse = _smoothedCourse;
        notifyListeners();

        // Drive initial tail motion through AnimatedMarker by publishing only
        // end-points and waiting for the configured duration between them.
        const int tailToTailMs = _pollIntervalSeconds * 1000;
        _markerAnimationDurationMs = tailToTailMs;
        _animationLog(
          'tail-start from=tail[-2] to=tail[-1] durationMs=$tailToTailMs '
          'speed=$speed',
        );
        await Future<void>.delayed(const Duration(milliseconds: 30));
        if (_isDisposed) return false;
        deviceLat = lat2;
        deviceLng = lng2;
        deviceRotation = tailBearing;
        notifyListeners();
        await Future<void>.delayed(Duration(milliseconds: tailToTailMs));
        if (_isDisposed) return false;

        if (lat2 != liveLat || lng2 != liveLng) {
          final endRotation = liveCourse == 0.0 ? tailBearing : liveCourse;
          _markerAnimationDurationMs = 900;
          _animationLog(
            'tail-finish from=tail[-1] to=live durationMs=900 '
            'fromLat=$lat2 fromLng=$lng2 toLat=$liveLat toLng=$liveLng',
          );
          await Future<void>.delayed(const Duration(milliseconds: 30));
          if (_isDisposed) return false;
          deviceLat = liveLat;
          deviceLng = liveLng;
          deviceRotation = endRotation;
          notifyListeners();
          await Future<void>.delayed(const Duration(milliseconds: 900));
          if (_isDisposed) return false;
        }
        return true;
      } else {
        if (kDebugMode) {
          debugPrint(
              'Invalid tail coordinates: lat1=$lat1, lng1=$lng1, lat2=$lat2, lng2=$lng2');
        }
        await _updateDeviceData(isRefresh: false);
        return false;
      }
    } else {
      if (kDebugMode) {
        debugPrint(
            'Invalid data for animation: tailList=$tailList, liveLat=$liveLat, liveLng=$liveLng, course=$liveCourse, speed=$speed');
      }
      await _updateDeviceData(isRefresh: false);
      return false;
    }
  }

  Future<void> _updateDeviceData({required bool isRefresh}) async {
    if (_isDisposed) return;
    if (deviceData?.item == null) {
      if (kDebugMode) debugPrint('No device data for update');
      return;
    }

    double lat = _safeDouble(deviceData!.item!.lat);
    double lng = _safeDouble(deviceData!.item!.lng);
    double course = _safeDouble(deviceData!.item!.course);
    int speed = _safeInt(deviceData!.item!.speed);
    String? deviceTimeStr = deviceData!.item!.time;
    final packetFingerprint = _packetIdentityFromItem(deviceData!.item!);
    if (_lastPacketFingerprint != packetFingerprint) {
      _lastPacketFingerprint = packetFingerprint;
      _lastFreshPacketAt = DateTime.now();
      _motionLog('fresh packet detected');
    }
    DateTime? deviceTime;
    try {
      deviceTime = deviceTimeStr != null && deviceTimeStr.isNotEmpty
          ? DateFormat("dd-MM-yyyy hh:mm:ss a").parse(deviceTimeStr)
          : null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error parsing device time: $deviceTimeStr, error: $e');
      }
      deviceTime = null;
    }
    DateTime now = DateTime.now();
    deviceTime ??= now;

    if (lat == 0.0 || lng == 0.0) {
      if (kDebugMode) debugPrint('Invalid coordinates: lat=$lat, lng=$lng');
      return;
    }

    // Calculate distance and time difference
    double distanceKm = 0.0;
    int timeDiffSeconds = 0;
    double calculatedSpeedKmh = 0.0;
    if (_lastPacketTime != null && deviceLat != 0.0 && deviceLng != 0.0) {
      distanceKm = _calculateDistance(
        LatLng(deviceLat, deviceLng),
        LatLng(lat, lng),
      );
      timeDiffSeconds = deviceTime.difference(_lastPacketTime!).inSeconds;
      if (timeDiffSeconds < 0) {
        _motionLog(
          'stale packet ignored packetTime=$deviceTime lastPacketTime=$_lastPacketTime',
        );
        return;
      }
      if (timeDiffSeconds > 0) {
        calculatedSpeedKmh = (distanceKm / timeDiffSeconds) * 3600; // km/h
      }
      if (kDebugMode) {
        debugPrint(
            'Distance between packets: ${distanceKm.toStringAsFixed(2)} km, '
            'Time difference: $timeDiffSeconds seconds, '
            'Calculated speed: ${calculatedSpeedKmh.toStringAsFixed(2)} km/h');
      }
      _motionLog(
        'packet delta distanceKm=${distanceKm.toStringAsFixed(6)} '
        'timeDiffSec=$timeDiffSeconds calcKmh=${calculatedSpeedKmh.toStringAsFixed(2)} '
        'apiSpeed=$speed',
      );
    }

    // Update last packet time
    _lastPacketTime = deviceTime;

    final distanceMeters = distanceKm * 1000;
    final shouldAnimateOnRefresh =
        isRefresh && (status == 'online' || speed > 0 || distanceMeters >= 15);
    if (shouldAnimateOnRefresh) {
      final isDuplicateZeroDistanceRefresh =
          timeDiffSeconds == 0 &&
          distanceMeters < 1.2 &&
          (deviceRotation - course).abs() < 0.1 &&
          deviceSpeed == speed;
      if (isDuplicateZeroDistanceRefresh) {
        _animationLog(
          'refresh-skip duplicate-zero-distance '
          'packetGapSec=$timeDiffSeconds distanceM=${distanceMeters.toStringAsFixed(2)} '
          'lat=${lat.toStringAsFixed(6)} lng=${lng.toStringAsFixed(6)} '
          'course=${course.toStringAsFixed(1)} speed=$speed status=$status',
        );
        return;
      }

      int durationMs;
      if (timeDiffSeconds >= 10 && timeDiffSeconds <= 15) {
        durationMs = 12000;
      } else if (timeDiffSeconds > 15 && timeDiffSeconds <= 25) {
        durationMs = 20000;
      } else if (timeDiffSeconds > 25) {
        durationMs = 30000;
      } else if (timeDiffSeconds > 0 && timeDiffSeconds < 10) {
        durationMs = timeDiffSeconds * 1000;
      } else {
        // Late packet fallback: derive a longer smooth duration from distance
        // and elapsed gap so large jumps stay visibly animated.
        final byDistanceMs = (distanceMeters * 14).round(); // ~14ms per meter
        final byTimeGapMs =
            timeDiffSeconds > 0 ? (timeDiffSeconds * 220) : 3000;
        durationMs = max(byDistanceMs, byTimeGapMs);
      }
      durationMs = durationMs.clamp(700, 30000);
      _markerAnimationDurationMs = durationMs;
      _animationLog(
        'refresh-start packetGapSec=$timeDiffSeconds durationMs=$durationMs '
        'distanceM=${distanceMeters.toStringAsFixed(2)} '
        'fromLat=${deviceLat.toStringAsFixed(6)} fromLng=${deviceLng.toStringAsFixed(6)} '
        'toLat=${lat.toStringAsFixed(6)} toLng=${lng.toStringAsFixed(6)} '
        'fromCourse=${deviceRotation.toStringAsFixed(1)} toCourse=${course.toStringAsFixed(1)} '
        'speed=$speed status=$status',
      );
      _motionLog(
        'refresh animate decision distanceM=${distanceMeters.toStringAsFixed(2)} '
        'durationMs=$durationMs shouldAnimate=$shouldAnimateOnRefresh',
      );

      if (distanceMeters < 1.2) {
        // Jitter guard: tiny coordinate noise should not animate as movement.
        _motionLog('jitter guard applied (distance < 1.2m), no animation');
        deviceLat = lat;
        deviceLng = lng;
        deviceRotation = course;
        deviceSpeed = speed;
        if (speed > 0 || status == 'online') {
          _lastVisualMovingAt = DateTime.now();
        }
        _updateMarkerVisualStatus(
          packetStatus: status,
          speed: speed,
          distanceMeters: distanceMeters,
        );
        if (speed > 0) {
          _updateSmoothedCourse(course);
          _lastMovingCourse = _smoothedCourse;
        }
        notifyListeners();
      } else {
        // Packet-level state update only. Marker interpolation is handled by
        // AnimatedMarker in UI to avoid double-animation flicker.
        deviceLat = lat;
        deviceLng = lng;
        deviceRotation = course;
        deviceSpeed = speed;
        if (speed > 0 || status == 'online') {
          _lastVisualMovingAt = DateTime.now();
        }
        _updateMarkerVisualStatus(
          packetStatus: status,
          speed: speed,
          distanceMeters: distanceMeters,
        );
        if (speed > 0) {
          _updateSmoothedCourse(course);
          _lastMovingCourse = _smoothedCourse;
        }
        notifyListeners();
      }
    } else {
      _markerAnimationDurationMs = 700;
      deviceLat = lat;
      deviceLng = lng;
      deviceRotation = course;
      deviceSpeed = speed;
      if (speed > 0 || status == 'online') {
        _lastVisualMovingAt = DateTime.now();
      }
      _updateMarkerVisualStatus(
        packetStatus: status,
        speed: speed,
        distanceMeters: distanceKm * 1000,
      );
      if (speed > 0) {
        _updateSmoothedCourse(course);
        _lastMovingCourse = _smoothedCourse;
      }
      notifyListeners();
    }
  }

  // API call
  Future<void> fetchDeviceLiveTracking({
    required int deviceId,
    bool isRefresh = false,
  }) async {
    _activeDeviceId = deviceId;
    if (_isDisposed) return;
    if (_isFetching) {
      if (isRefresh) {
        _pendingRefresh = true;
        _motionLog('refresh queued while fetching');
      }
      return;
    }
    _isFetching = true;
    if (!isRefresh) {
      isLoading = true;
      errorMessage = null;
      hasNoData = false;
      noDataMessage = null;
      notifyListeners();
    }

    try {
      final response = await _fetchLiveWithRetry(deviceId: deviceId);
      if (_isDisposed) return;

      deviceData = response;

      if (deviceData?.item == null) {
        if (kDebugMode) debugPrint('No device data found');
        hasNoData = true;
        noDataMessage = 'No live data available for this vehicle.';
        isLoading = false;
        notifyListeners();
        return;
      }

      final liveItem = deviceData!.item!;
      final rawOnline = (liveItem.online ?? '').trim().toLowerCase();
      final packetFingerprint = _packetIdentityFromItem(liveItem);
      if (_lastPacketFingerprint != packetFingerprint) {
        _lastPacketFingerprint = packetFingerprint;
        _lastFreshPacketAt = DateTime.now();
        _motionLog('fresh packet detected (pre-update)');
      }
      final normalizedStatus = _normalizeStatus(rawOnline);
      if (normalizedStatus.isNotEmpty) {
        _resolvedOnlineStatus = normalizedStatus;
        if (_visualMarkerStatus == 'offline') {
          _visualMarkerStatus = normalizedStatus;
        }
      }
      final lat = _safeDouble(liveItem.lat);
      final lng = _safeDouble(liveItem.lng);
      final time = (liveItem.time ?? '').toLowerCase().trim();
      final noDataStatus = rawOnline == 'never_connected' ||
          (status == 'offline' && time == 'not connected');

      if ((lat == 0.0 || lng == 0.0) && noDataStatus) {
        hasNoData = true;
        noDataMessage = 'This vehicle has no live location data yet.';
        isLoading = false;
        notifyListeners();
        return;
      }

      hasNoData = false;
      noDataMessage = null;
      errorMessage = null;

      // Validate and assign data (from lite)
      deviceName;
      totalDistance;
      status;
      deviceStopDuration;
      deviceSpeed = _safeInt(deviceData!.item!.speed);
      lastUpdate;
      address;

      String? deviceTimeStr = deviceData!.item!.time;
      DateTime? deviceTime;
      try {
        deviceTime = deviceTimeStr != null && deviceTimeStr.isNotEmpty
            ? DateFormat("dd-MM-yyyy hh:mm:ss a").parse(deviceTimeStr)
            : null;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error parsing device time: $deviceTimeStr, error: $e');
        }
        deviceTime = null;
      }
      DateTime now = DateTime.now();
      bool skipInitialAnimation = false;
      if (deviceTime == null || now.difference(deviceTime).inMinutes > 5) {
        skipInitialAnimation = true;
      }

      final hasLiveMovementSignal = status == 'online' || deviceSpeed > 0;
      final tailAlreadyConsumed = _hasConsumedInitialTail(deviceId);
      final hasValidTail = _hasValidTailForInitialAnimation();
      final canUseTail = isInitial &&
          hasLiveMovementSignal &&
          hasValidTail &&
          !tailAlreadyConsumed;
      _motionLog(
        'initial animation gate isInitial=$isInitial skip=$skipInitialAnimation '
        'status=$status speed=$deviceSpeed liveSignal=$hasLiveMovementSignal '
        'hasValidTail=$hasValidTail tailConsumed=$tailAlreadyConsumed '
        'canUseTail=$canUseTail',
      );
      if (canUseTail) {
        _motionLog('using initial tail animation');
        final usedTail = await _handleInitialAnimation();
        if (usedTail) {
          _lastPacketTime = deviceTime ?? now;
          _motionLog('tail animation consumed and persisted');
          await _markInitialTailConsumed(deviceId);
        }
      } else {
        await _updateDeviceData(isRefresh: isRefresh);
      }

      isInitial = false;

      // Update course smoothing / last moving course
      if (deviceSpeed > 0) {
        _updateSmoothedCourse(rawCourse);
        _lastMovingCourse = _smoothedCourse;
        if (kDebugMode) {
          debugPrint("Updated moving course to: $_lastMovingCourse");
        }
      } else {
        if (kDebugMode) {
          debugPrint("Vehicle stopped, keeping course: $_lastMovingCourse");
        }
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (SessionGuard.isSessionExpiredError(e)) {
        await SessionGuard.forceLogout(message: e.toString());
        return;
      }
      if (kDebugMode) debugPrint("Live Tracking Error: $e");
      if (deviceData?.item == null) {
        errorMessage = _friendlyErrorMessage(e);
      }
      isLoading = false;
      notifyListeners();
    } finally {
      _isFetching = false;
      if (_pendingRefresh && !_isDisposed) {
        _pendingRefresh = false;
        _motionLog('running queued refresh');
        unawaited(fetchDeviceLiveTracking(
          deviceId: deviceId,
          isRefresh: true,
        ));
      }
    }
  }

  Future<GetDeviceLiveTrackingModel?> _fetchLiveWithRetry({
    required int deviceId,
  }) async {
    const maxAttempts = 3;
    Object? lastError;
    for (int i = 1; i <= maxAttempts; i++) {
      try {
        final response =
            await repository.getDeviceLiveTrackingApi(deviceId: deviceId);
        if (response != null) return response;
      } catch (e) {
        lastError = e;
        if (!_isLikelyNetworkError(e) || i == maxAttempts) {
          rethrow;
        }
      }
      if (i < maxAttempts) {
        await Future<void>.delayed(Duration(milliseconds: 500 * i));
      }
    }
    if (lastError != null) throw lastError;
    return null;
  }

  bool _isLikelyNetworkError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('no address associated with hostname') ||
        text.contains('network is unreachable') ||
        text.contains('timed out') ||
        text.contains('clientexception');
  }

  String _friendlyErrorMessage(Object error) {
    if (_isLikelyNetworkError(error)) {
      return 'Network connection issue. Please check internet and try again.';
    }
    final raw = error.toString().trim();
    if (raw.startsWith('Exception:')) {
      return raw.replaceFirst('Exception:', '').trim();
    }
    return raw;
  }

  void startPeriodicRefresh(int deviceId,
      {int intervalSeconds = _pollIntervalSeconds}) {
    if (_isDisposed) return;
    _activeDeviceId = deviceId;
    _motionLog('start periodic refresh interval=${intervalSeconds}s');
    // Fetch immediately once, then continue on the configured interval.
    _refreshTimer?.cancel();
    // Immediately fetch once, then schedule periodic
    fetchDeviceLiveTracking(deviceId: deviceId, isRefresh: false);
    _refreshTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      if (_isDisposed) return;
      _motionLog('periodic refresh tick');
      fetchDeviceLiveTracking(deviceId: deviceId, isRefresh: true);
    });
  }

  void _motionLog(String message) {
    if (!kDebugMode || !_kEnableMotionDebugLogs) return;
    final id = _activeDeviceId?.toString() ?? '-';
    debugPrint('[SVT][device:$id] $message');
  }

  void _animationLog(String message) {
    if (!kDebugMode || !_kEnableAnimationDebugLogs) return;
    final id = _activeDeviceId?.toString() ?? '-';
    debugPrint('[SVT-ANIM][device:$id] $message');
  }

  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // Toggle methods (from lite, adapted)
  void toggleMapType() {
    currentMapType =
        currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    if (kDebugMode) {
      debugPrint('Toggled map type to: $currentMapType');
    }
    notifyListeners();
  }

  void toggleTraffic() {
    enableTraffic = !enableTraffic;
    if (kDebugMode) {
      debugPrint('Toggled traffic to: $enableTraffic');
    }
    notifyListeners();
  }

  // Zoom adjust (added for buttons)
  void adjustZoom(double newZoom) {
    currentZoom = newZoom.clamp(1.0, 20.0);
    notifyListeners();
  }

  // Center on vehicle (notifies for UI to animate)
  void centerOnVehicle() {
    followVehicle = true;
    notifyListeners(); // UI will animate on change
  }

  void toggleFollowVehicle() {
    followVehicle = !followVehicle;
    notifyListeners();
  }

  void toggleRulerMode() {
    rulerMode = !rulerMode;
    if (rulerMode) {
      // Manual point selection should not fight camera follow updates.
      followVehicle = false;
    } else {
      _rulerPoints.clear();
    }
    notifyListeners();
  }

  void handleRulerTap(LatLng point) {
    if (!rulerMode) return;
    _rulerPoints.add(point);
    notifyListeners();
  }

  void clearRulerPoints() {
    if (_rulerPoints.isEmpty) return;
    _rulerPoints.clear();
    notifyListeners();
  }

  Future<bool> fetchUserLocation() async {
    try {
      locationError = null;
      isLocatingUser = true;
      notifyListeners();

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationError = 'Location services are disabled';
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        locationError = 'Location permission denied';
        return false;
      }
      if (permission == LocationPermission.deniedForever) {
        locationError = 'Enable location permission in Settings';
        return false;
      }

      _userPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _userPosition ??= await Geolocator.getLastKnownPosition();
      if (_userPosition == null) {
        locationError = 'No GPS fix available';
        return false;
      }
      return true;
    } catch (e) {
      try {
        _userPosition = await Geolocator.getLastKnownPosition();
      } catch (_) {}
      if (_userPosition != null) {
        locationError = null;
        return true;
      }
      locationError = 'Unable to get current location';
      return false;
    } finally {
      isLocatingUser = false;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    stopPeriodicRefresh();
    super.dispose();
  }
}
