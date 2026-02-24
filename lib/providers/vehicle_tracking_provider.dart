import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/data/models/get_device_live_tracking_model.dart';
import 'package:trackerapp/data/repositories/get_device_live_tracking_repository.dart';

class VehicleTrackingProvider extends ChangeNotifier {
  final GetDeviceLiveTrackingRepository repository = GetDeviceLiveTrackingRepository();
  GetDeviceLiveTrackingModel? deviceData;

  Timer? _refreshTimer;
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

  Item? get item => deviceData?.item;

  String get deviceName => item?.name ?? 'Unknown Vehicle';
  String get deviceId => item?.id.toString() ?? 'Unknown Vehicle';
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
          print('Invalid double value: $val, returning $defaultValue');
        }
        return defaultValue;
      }
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.parse(val.toString());
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing double: $val, error: $e, returning $defaultValue');
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
          print('Invalid int value: $val, returning $defaultValue');
        }
        return defaultValue;
      }
      if (val is int) return val;
      return int.parse(val.toString());
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing int: $val, error: $e, returning $defaultValue');
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
      if (kDebugMode) print("Significant course change: $_smoothedCourse");
    } else {
      final aRad = _smoothedCourse * pi / 180;
      final bRad = normalizedNew * pi / 180;

      final x = (1 - _smoothingAlpha) * cos(aRad) + _smoothingAlpha * cos(bRad);
      final y = (1 - _smoothingAlpha) * sin(aRad) + _smoothingAlpha * sin(bRad);

      final avg = atan2(y, x) * 180 / pi;
      _smoothedCourse = _normalizeAngle(avg);
      if (kDebugMode) print("Smoothed course to: $_smoothedCourse");
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

  // Animation logic adapted from lite Cubit
  Future<void> _handleInitialAnimation() async {
    if (deviceData?.item == null) {
      if (kDebugMode) print('No device data for initial animation');
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
            double t = i / steps;
            deviceLat = lat2 + (liveLat - lat2) * t;
            deviceLng = lng2 + (liveLng - lng2) * t;
            deviceRotation = course;
            notifyListeners();
          }
        }
      } else {
        if (kDebugMode) {
          print(
              'Invalid tail coordinates: lat1=$lat1, lng1=$lng1, lat2=$lat2, lng2=$lng2');
        }
        await _updateDeviceData(isRefresh: false);
      }
    } else {
      if (kDebugMode) {
        print(
            'Invalid data for animation: tailList=$tailList, liveLat=$liveLat, liveLng=$liveLng, course=$course, speed=$speed');
      }
      await _updateDeviceData(isRefresh: false);
    }
  }

  Future<void> _updateDeviceData({required bool isRefresh}) async {
    if (deviceData?.item == null) {
      if (kDebugMode) print('No device data for update');
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
        print('Error parsing device time: $deviceTimeStr, error: $e');
      }
      deviceTime = null;
    }
    DateTime now = DateTime.now();
    deviceTime ??= now;

    if (lat == 0.0 || lng == 0.0) {
      if (kDebugMode) print('Invalid coordinates: lat=$lat, lng=$lng');
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
        print('Distance between packets: ${distanceKm.toStringAsFixed(2)} km, '
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
    try {
      final response = await repository.getDeviceLiveTrackingApi(deviceId: deviceId);

      deviceData = response;

      if (deviceData?.item == null) {
        if (kDebugMode) print('No device data found');
        return;
      }

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
          print('Error parsing device time: $deviceTimeStr, error: $e');
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

      if (isInitial &&
          !skipInitialAnimation &&
          status == 'online') {
        await _handleInitialAnimation();
      } else {
        await _updateDeviceData(isRefresh: isRefresh);
      }

      isInitial = false;

      // Update course smoothing / last moving course
      if (deviceSpeed > 0) {
        _updateSmoothedCourse(rawCourse);
        _lastMovingCourse = _smoothedCourse;
        if (kDebugMode) print("Updated moving course to: $_lastMovingCourse");
      } else {
        if (kDebugMode) print("Vehicle stopped, keeping course: $_lastMovingCourse");
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Live Tracking Error: $e");
      // keep previous state; don't throw to UI
    }
  }

  void startPeriodicRefresh(int deviceId, BuildContext context, {int intervalSeconds = 8}) {  // Matched lite's 8s
    _refreshTimer?.cancel();
    // Immediately fetch once, then schedule periodic
    fetchDeviceLiveTracking(deviceId: deviceId, context: context, isRefresh: false);
    _refreshTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      fetchDeviceLiveTracking(deviceId: deviceId, context: context, isRefresh: true);
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
      print('Toggled map type to: $currentMapType');
    }
    notifyListeners();
  }

  void toggleTraffic() {
    enableTraffic = !enableTraffic;
    if (kDebugMode) {
      print('Toggled traffic to: $enableTraffic');
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
    notifyListeners(); // UI will animate on change
  }

  @override
  void dispose() {
    stopPeriodicRefresh();
    super.dispose();
  }
}