import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/data/models/get_device_live_tracking_model.dart';
import 'package:trackerapp/data/repositories/get_device_live_tracking_repository.dart';

class VehicleTrackingProvider extends ChangeNotifier {
  final GetDeviceLiveTrackingRepository repository =
      GetDeviceLiveTrackingRepository();
  GetDeviceLiveTrackingModel? deviceData;

  Timer? _refreshTimer;
  bool _isDisposed = false;
  bool isLoading = true;
  bool hasNoData = false;
  String? noDataMessage;
  String? errorMessage;
  DateTime? _lastPacketTime;
  double deviceLat = 0.0;
  double deviceLng = 0.0;
  double deviceRotation = 0.0;
  int deviceSpeed = 0;
  bool isInitial = true;
  double _smoothedCourse = 0.0;
  double _lastMovingCourse = 0.0;
  final double _smoothingAlpha = 0.3;
  final double _minCourseChange = 5.0;

  // Map controls (from lite)
  MapType currentMapType = MapType.normal;
  bool enableTraffic = false;
  double currentZoom = 15.0;
  bool followVehicle = true;
  bool rulerMode = false;
  final List<LatLng> _rulerPoints = [];
  Position? _userPosition;
  bool isLocatingUser = false;
  String? locationError;

  Item? get item => deviceData?.item;

  String get deviceName => item?.name ?? 'Unknown Vehicle';
  String get deviceId => item?.id.toString() ?? 'Unknown Vehicle';
  String get vehicleType => item?.vehicleType ?? '';
  String get status => (item?.online ?? 'offline').toLowerCase();
  double get odometer => _safeDouble(item?.odometer);
  String get totalDistance => odometer.toStringAsFixed(2);
  String get address => item?.addr ?? 'Fetching location...';
  String get lastUpdate => item?.time ?? '';
  List<Sensor>? get sensors => item?.sensors;
  double get latitude => deviceLat;
  double get longitude => deviceLng;
  double get rawCourse => _safeDouble(item?.course) % 360;

  double get course {
    return deviceSpeed > 0 ? _smoothedCourse : _lastMovingCourse;
  }

  String get deviceStopDuration => item?.stopDuration?.toString() ?? '0';
  Position? get userPosition => _userPosition;

  Color get ignitionColor {
    switch (status) {
      case 'online':
      case 'engine':
        return AppColors.green;
      case 'ack':
        return AppColors.red;
      default:
        return AppColors.yellow;
    }
  }

  String get vehicleStatusText {
    switch (status) {
      case 'online':
        return 'Running';
      case 'ack':
        return 'Stopped';
      case 'engine':
        return 'Idle';
      default:
        return 'Offline';
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
        debugPrint('Error parsing double: $val, error: $e, returning $defaultValue');
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
        debugPrint('Error parsing int: $val, error: $e, returning $defaultValue');
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

  double _interpolateRotation(double start, double end, double t) {
    double diff = (end - start) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return (start + diff * t) % 360;
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

  // Animation logic adapted from lite Cubit
  Future<void> _handleInitialAnimation() async {
    if (_isDisposed) return;
    if (deviceData?.item == null) {
      if (kDebugMode) debugPrint('No device data for initial animation');
      return;
    }

    double liveLat = _safeDouble(deviceData!.item!.lat);
    double liveLng = _safeDouble(deviceData!.item!.lng);
    double course = _safeDouble(deviceData!.item!.course);
    int speed = _safeInt(deviceData!.item!.speed);
    var tailList = deviceData!.item!.tail;

    if (tailList != null &&
        tailList.length >= 2 &&
        liveLat != 0.0 &&
        liveLng != 0.0 &&
        course != 0.0 &&
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

        const int steps = 10;
        const int durationMs = 400;
        const int stepDurationMs = durationMs ~/ steps;

        for (int i = 1; i <= steps; i++) {
          await Future.delayed(Duration(milliseconds: stepDurationMs));
          if (_isDisposed) return;
          double t = i / steps;
          deviceLat = lat1 + (lat2 - lat1) * t;
          deviceLng = lng1 + (lng2 - lng1) * t;
          deviceRotation = tailBearing;
          notifyListeners();
        }
        if (lat2 != liveLat || lng2 != liveLng) {
          for (int i = 1; i <= steps; i++) {
            await Future.delayed(
                Duration(milliseconds: durationMs + stepDurationMs * i));
            if (_isDisposed) return;
            double t = i / steps;
            deviceLat = lat2 + (liveLat - lat2) * t;
            deviceLng = lng2 + (liveLng - lng2) * t;
            deviceRotation = course;
            notifyListeners();
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint(
              'Invalid tail coordinates: lat1=$lat1, lng1=$lng1, lat2=$lat2, lng2=$lng2');
        }
        await _updateDeviceData(isRefresh: false);
      }
    } else {
      if (kDebugMode) {
        debugPrint(
            'Invalid data for animation: tailList=$tailList, liveLat=$liveLat, liveLng=$liveLng, course=$course, speed=$speed');
      }
      await _updateDeviceData(isRefresh: false);
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
      if (timeDiffSeconds > 0) {
        calculatedSpeedKmh = (distanceKm / timeDiffSeconds) * 3600; // km/h
      }
      if (kDebugMode) {
        debugPrint('Distance between packets: ${distanceKm.toStringAsFixed(2)} km, '
            'Time difference: $timeDiffSeconds seconds, '
            'Calculated speed: ${calculatedSpeedKmh.toStringAsFixed(2)} km/h');
      }
    }

    // Update last packet time
    _lastPacketTime = deviceTime;

    if (status == 'online' && isRefresh) {
      int durationMs = 500;
      if (timeDiffSeconds > 0 && timeDiffSeconds <= 40) {
        durationMs = timeDiffSeconds * 1000;
      }
      const int steps = 20;
      final int stepDurationMs = durationMs ~/ steps;
      double startLat = deviceLat;
      double startLng = deviceLng;
      double startRotation = deviceRotation;

      for (int i = 1; i <= steps; i++) {
        await Future.delayed(Duration(milliseconds: stepDurationMs));
        if (_isDisposed) return;
        double t = i / steps;
        deviceLat = startLat + (lat - startLat) * t;
        deviceLng = startLng + (lng - startLng) * t;
        deviceRotation = _interpolateRotation(startRotation, course, t);
        deviceSpeed = speed;
        notifyListeners();
      }
    } else {
      deviceLat = lat;
      deviceLng = lng;
      deviceRotation = course;
      deviceSpeed = speed;
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
    required BuildContext context,
  }) async {
    if (_isDisposed) return;
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
      final lat = _safeDouble(liveItem.lat);
      final lng = _safeDouble(liveItem.lng);
      final online = (liveItem.online ?? '').toLowerCase().trim();
      final time = (liveItem.time ?? '').toLowerCase().trim();
      final noDataStatus = online == 'never_connected' ||
          (online == 'offline' && time == 'not connected');

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

      // Update last packet time
      _lastPacketTime = deviceTime ?? now;

      if (isInitial && !skipInitialAnimation && status == 'online') {
        await _handleInitialAnimation();
      } else {
        await _updateDeviceData(isRefresh: isRefresh);
      }

      isInitial = false;

      // Update course smoothing / last moving course
      if (deviceSpeed > 0) {
        _updateSmoothedCourse(rawCourse);
        _lastMovingCourse = _smoothedCourse;
        if (kDebugMode) debugPrint("Updated moving course to: $_lastMovingCourse");
      } else {
        if (kDebugMode) {
          debugPrint("Vehicle stopped, keeping course: $_lastMovingCourse");
        }
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint("Live Tracking Error: $e");
      if (deviceData?.item == null) {
        errorMessage = _friendlyErrorMessage(e);
      }
      isLoading = false;
      notifyListeners();
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

  void startPeriodicRefresh(int deviceId, BuildContext context,
      {int intervalSeconds = 8}) {
    if (_isDisposed) return;
    // Matched lite's 8s
    _refreshTimer?.cancel();
    // Immediately fetch once, then schedule periodic
    fetchDeviceLiveTracking(
        deviceId: deviceId, context: context, isRefresh: false);
    _refreshTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      if (_isDisposed) return;
      fetchDeviceLiveTracking(
          deviceId: deviceId, context: context, isRefresh: true);
    });
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
