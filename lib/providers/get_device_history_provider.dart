import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackerapp/data/models/get_device_history_model.dart';
import 'package:trackerapp/data/repositories/get_device_history_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Trip model for the bottom-sheet trip list
// ──────────────────────────────────────────────────────────────────────────────
class TripSegment {
  final int tripIndex;
  final String startTime;
  final String endTime;
  final String distance;
  final String duration;
  final int startRouteIndex;
  final int endRouteIndex;
  final LatLng? startLatLng;
  final LatLng? endLatLng;

  const TripSegment({
    required this.tripIndex,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.duration,
    required this.startRouteIndex,
    required this.endRouteIndex,
    this.startLatLng,
    this.endLatLng,
  });
}

class DeviceHistoryProvider extends ChangeNotifier {
  final GetDeviceHistoryRepository _repository = GetDeviceHistoryRepository();

  // ── State ──────────────────────────────────────────────────────────────────
  GetDeviceHistoryModel? _deviceHistoryModel;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Map ────────────────────────────────────────────────────────────────────
  final List<Marker> _mapMarkers = [];
  final List<LatLng> _polyLatLng = [];
  final List<LatLng> _parkedLatLngs = [];
  final List<LatLng> _eventsLatLngs = [];
  final Set<Polyline> _routePolyLine = {};

  // ── Playback ───────────────────────────────────────────────────────────────
  final List<LocationItem> _routeList = [];
  int _currentSliderValue = 0;
  int _sliderValueMax = 0;
  bool _isPlaying = false;
  Timer? _playbackTimer;
  final List<int> _playBackTimeSpeeds = [1000, 800, 600, 400, 200];
  int _selectedPlayBackSpeed = 0;

  // ── Car position (direct, no animation timer) ─────────────────────────────
  double _carLat = 0.0;
  double _carLng = 0.0;
  double _carRotation = 0.0;

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
  int _selectedTripIndex = -1; // -1 = all trips

  // ── Getters ────────────────────────────────────────────────────────────────
  GetDeviceHistoryModel? get deviceHistoryModel => _deviceHistoryModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Marker> get mapMarkers => _mapMarkers;
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
  List<int> get playBackTimeSpeeds => _playBackTimeSpeeds;
  List<TripSegment> get tripSegments => _tripSegments;
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
      _errorMessage = e.toString();
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
    for (var historyItem in _deviceHistoryModel!.history) {
      if (historyItem.status == 2) {
        _tripCount++;
        final segStart = _routeList.length;
        _processMovingItems(historyItem.items);
        final segEnd = _routeList.length - 1;
        if (segEnd >= segStart && segEnd >= 0) {
          final startItem = _routeList[segStart];
          final endItem = _routeList[segEnd];
          _tripSegments.add(TripSegment(
            tripIndex: tripIdx++,
            startTime: startItem.rawTime ?? startItem.time ?? '—',
            endTime: endItem.rawTime ?? endItem.time ?? '—',
            distance: historyItem.distance.toStringAsFixed(2),
            duration: historyItem.time ?? '—',
            startRouteIndex: segStart,
            endRouteIndex: segEnd,
            startLatLng: LatLng(startItem.lat, startItem.lng),
            endLatLng: LatLng(endItem.lat, endItem.lng),
          ));
        }
      } else if (historyItem.status == 5) {
        _processEventItems(historyItem.items);
      } else if (historyItem.status == 4) {
        _stopCount++;
        _processStoppedItems(historyItem.items);
      }
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
    for (var item in items) {
      if (item.lat != 0 && item.lng != 0) {
        _routeList.add(item);
        _polyLatLng.add(LatLng(item.lat, item.lng));
      }
    }
  }

  void _processEventItems(List<LocationItem> items) {
    for (var item in items) {
      if (item.lat != 0 && item.lng != 0) {
        _eventsLatLngs.add(LatLng(item.lat, item.lng));
      }
    }
  }

  void _processStoppedItems(List<LocationItem> items) {
    if (items.isNotEmpty && items[0].lat != 0 && items[0].lng != 0) {
      _parkedLatLngs.add(LatLng(items[0].lat, items[0].lng));
    }
  }

  // ── Icons ──────────────────────────────────────────────────────────────────
  Future<void> _loadMapIcons() async {
    final String iconPath =
    Platform.isAndroid ? 'assets/images/' : 'assets/images/ios/';

    _startIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(100, 100)),
      '${iconPath}start.png',
    );
    _endIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(100, 100)),
      '${iconPath}end.png',
    );
    _parkingIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(32, 32)),
      '${iconPath}stops.png',
    );
    _eventsIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(32, 32)),
      '${iconPath}alert.png',
    );
    // Always use car_green.png for history playback car
    _carIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(20, 38)),
      'assets/images/car_green.png',
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
    _mapMarkers.removeWhere(
            (m) => m.markerId == const MarkerId('start') || m.markerId == const MarkerId('end'));

    _mapMarkers.add(Marker(
      markerId: const MarkerId('start'),
      position: LatLng(_routeList.first.lat, _routeList.first.lng),
      icon: _startIcon!,
      anchor: const Offset(0.5, 0.5),
      zIndex: 7,
    ));
    _mapMarkers.add(Marker(
      markerId: const MarkerId('end'),
      position: LatLng(_routeList.last.lat, _routeList.last.lng),
      icon: _endIcon!,
      anchor: const Offset(0.5, 0.5),
      zIndex: 8,
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
        zIndex: 5,
      ));
      index++;
    }
  }

  void _setEventsMarkers() {
    if (_eventsIcon == null) return;
    int index = 0;
    for (var position in _eventsLatLngs) {
      _mapMarkers.add(Marker(
        markerId: MarkerId('event_$index'),
        position: position,
        icon: _eventsIcon!,
        anchor: const Offset(0.5, 0.5),
        zIndex: 5,
      ));
      index++;
    }
  }

  // ── Car marker (direct update, no animation timer) ────────────────────────
  void _updateCarMarker(int index) {
    if (index >= _routeList.length || _carIcon == null) return;

    _mapMarkers.removeWhere((m) => m.markerId == const MarkerId('car'));

    final location = _routeList[index];
    _carLat = location.lat;
    _carLng = location.lng;
    _carRotation = location.course?.toDouble() ?? 0.0;

    _mapMarkers.add(Marker(
      markerId: const MarkerId('car'),
      position: LatLng(_carLat, _carLng),
      icon: _carIcon!,
      anchor: const Offset(0.5, 0.5),
      rotation: _carRotation,
      flat: true,
      zIndex: 10,
      infoWindow: InfoWindow(
        title: 'Speed: ${location.speed} km/h',
        snippet: location.time ?? '',
      ),
    ));

    _currentSliderValue = index;
    notifyListeners();
  }

  // ── Playback controls ──────────────────────────────────────────────────────
  void playPause() => _isPlaying ? pausePlayback() : startPlayback();

  void startPlayback() {
    if (_routeList.isEmpty) return;
    _isPlaying = true;
    _setCompleteRoutePolyline(isPlaying: true);
    notifyListeners();

    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(
      Duration(milliseconds: _playBackTimeSpeeds[_selectedPlayBackSpeed]),
          (timer) {
        if (_currentSliderValue >= _sliderValueMax) {
          pausePlayback();
          return;
        }
        _updateCarMarker(_currentSliderValue + 1);
      },
    );
  }

  void pausePlayback() {
    _isPlaying = false;
    _playbackTimer?.cancel();
    _setCompleteRoutePolyline(isPlaying: false);
    notifyListeners();
  }

  void stopPlayback() {
    _isPlaying = false;
    _playbackTimer?.cancel();
    _currentSliderValue = 0;
    _setCompleteRoutePolyline(isPlaying: false);
    _updateCarMarker(0);
  }

  void seekTo(int value) {
    if (value < 0 || value > _sliderValueMax) return;
    _updateCarMarker(value);
  }

  void changePlaybackSpeed() {
    _selectedPlayBackSpeed =
        (_selectedPlayBackSpeed + 1) % _playBackTimeSpeeds.length;
    if (_isPlaying) {
      _playbackTimer?.cancel();
      startPlayback();
    }
    notifyListeners();
  }

  String get playbackSpeedLabel {
    const speeds = ['0.5x', '1x', '1.5x', '2x', '3x'];
    return speeds[_selectedPlayBackSpeed];
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
    _polyLatLng.clear();
    _parkedLatLngs.clear();
    _eventsLatLngs.clear();
    _routePolyLine.clear();
    _routeList.clear();
    _tripSegments.clear();
    _currentSliderValue = 0;
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
    _isPlaying = false;
    _playbackTimer?.cancel();
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}