import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart';
import 'package:trackerapp/data/repositories/vehicle_repository.dart';

class VehicleMapProvider extends ChangeNotifier {
  final VehicleRepository repository = VehicleRepository();
  bool _isDisposed = false;
  static const double _sharedMarkerIconPx = 90.0;
  // No-label markers can look visually larger than labeled markers on map,
  // so keep a slightly smaller base size for non-labeled mode.
  static const double _plainMarkerScale = 1.0;
  static const double _labelFontSize = 20.0;
  static const double _labelPadding = 10.0;
  static const double _labelMinWidth = 90.0;

  GetDevicesListModel? deviceListModel;
  Set<Marker> deviceMarkers = {};
  bool isLoading = true;
  String? errorMessage;
  Item? _selectedVehicle;
  Item? get selectedVehicle => _selectedVehicle;

  MapType currentMapType = MapType.normal;
  bool enableTraffic = false;
  bool showMarkerLabels = true;
  bool enableClusterMode = false;
  bool _labelsBeforeCluster = true;
  double _currentZoom = 5.0;

  String _selectedStatus = 'all';
  String get selectedStatus => _selectedStatus;

  Timer? _refreshTimer;
  GoogleMapController? mapController;
  DateTime? _lastRefreshAt;
  DateTime? get lastRefreshAt => _lastRefreshAt;

  final Map<String, BitmapDescriptor> _icons = {};
  final Map<String, BitmapDescriptor> _clusterIcons = {};

  final Map<String, String> _assetPaths = {
    'green_car': 'assets/images/car_green.png',
    'red_car': 'assets/images/car_red.png',
    'yellow_car': 'assets/images/car_yellow.png',
    'blue_car': 'assets/images/car_blue.png',
    'green_bike': 'assets/images/bike_green.png',
    'red_bike': 'assets/images/bike_red.png',
    'yellow_bike': 'assets/images/bike_yellow.png',
    'blue_bike': 'assets/images/bike_blue.png',
    'green_truck': 'assets/images/truck_green.png',
    'red_truck': 'assets/images/truck_red.png',
    'yellow_truck': 'assets/images/Truck_Yellow.png',
    'blue_truck': 'assets/images/truck_blue.png',
    'green_bus': 'assets/images/bus_green.png',
    'red_bus': 'assets/images/bus_red.png',
    'yellow_bus': 'assets/images/bus_yellow.png',
    'blue_bus': 'assets/images/bus_blue.png',
    'green_ambulance': 'assets/images/ambulance_green.png',
    'red_ambulance': 'assets/images/ambulance_red.png',
    'yellow_ambulance': 'assets/images/ambulance_yellow.png',
    'blue_ambulance': 'assets/images/ambulance_blue.png',
  };

  final Map<String, BitmapDescriptor> _labeledIcons = {};

  DateTime? _lastTapTime;
  int? _lastTappedDeviceId;

  VehicleMapProvider() {
    _loadMarkerIcons();
  }

  void _notifySafely() {
    if (_isDisposed) return;
    notifyListeners();
  }

  Future<void> _loadMarkerIcons() async {
    const plainMarkerPx = _sharedMarkerIconPx * _plainMarkerScale;

    for (var entry in _assetPaths.entries) {
      _icons[entry.key] =
          await _createResizedAssetIcon(entry.value, plainMarkerPx.toInt());
      if (_isDisposed) return;
    }

    _notifySafely();
  }

  Future<BitmapDescriptor> _createResizedAssetIcon(
      String assetPath, int targetPx) async {
    final ByteData iconData = await rootBundle.load(assetPath);
    final ui.Codec iconCodec = await ui.instantiateImageCodec(
      iconData.buffer.asUint8List(),
      targetHeight: targetPx,
    );
    final ui.FrameInfo frame = await iconCodec.getNextFrame();
    final ByteData? pngBytes =
        await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(pngBytes!.buffer.asUint8List());
  }

  String _getIconColorKey(String? online, String? time) {
    final ol = (online ?? '').toLowerCase().trim();

    if (['online', 'running', 'moving'].contains(ol)) return 'green';
    if (['ack', 'stopped', 'parking'].contains(ol)) return 'red';
    if (['idle', 'engine'].contains(ol)) return 'yellow';
    return 'blue';
  }

  Color _getStatusColor(String? online, String? time) {
    final ol = (online ?? '').toLowerCase().trim();

    if (['online', 'running', 'moving'].contains(ol)) return Colors.green;
    if (['ack', 'stopped', 'parking'].contains(ol)) return Colors.red;
    if (['idle', 'engine'].contains(ol)) return Colors.orange;
    return Colors.blue;
  }

  String _getVehicleType(Item item) {
    final String? cat = item.vehicleType;
    if (cat == null || cat.isEmpty) return 'car';

    final lower = cat.toLowerCase().trim();
    if (lower.contains('ambulance')) return 'ambulance';
    if (lower.contains('bus')) return 'bus';
    if (lower.contains('bike') || lower.contains('motorcycle')) return 'bike';
    if (lower.contains('truck')) return 'truck';
    return 'car';
  }

  BitmapDescriptor _getNormalIcon(Item item) {
    final colorStr = _getIconColorKey(item.online, item.time);
    final type = _getVehicleType(item);
    final key = '${colorStr}_$type';
    return _icons[key] ?? _icons['blue_car']!;
  }

  Future<BitmapDescriptor> _createLabeledMarker(
    String assetPath,
    String label,
    Color statusColor,
  ) async {
    label = label.trim();
    if (label.isEmpty) {
      // Fallback to normal icon if no label
      final fileName = assetPath.split('/').last.split('.').first.toLowerCase();
      final key = fileName.replaceAll('truck_yellow', 'yellow_truck');
      return _icons[key] ?? _icons['blue_car']!;
    }

    final ByteData iconData = await rootBundle.load(assetPath);
    final ui.Codec iconCodec = await ui.instantiateImageCodec(
      iconData.buffer.asUint8List(),
      targetHeight: _sharedMarkerIconPx.toInt(),
    );
    final ui.FrameInfo fi = await iconCodec.getNextFrame();
    final ui.Image baseIcon = fi.image;

    final double iconWidth = baseIcon.width.toDouble();
    final double iconHeight = baseIcon.height.toDouble();

    // Text settings
    const double fontSize = _labelFontSize;
    const double padding = _labelPadding;
    const double minLabelWidth = _labelMinWidth;

    final TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: label,
      style: TextStyle(
        color: statusColor,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    tp.layout();

    double labelWidth = math.max(tp.width + padding * 2, minLabelWidth);
    double labelHeight = tp.height + padding * 2;

    const double cornerRadius = 14.0;

    // Arrow (tail) settings
    const double arrowBaseWidth = 28.0;
    const double arrowHeight = 16.0;

    // Space between arrow tip and vehicle icon
    const double gap = 12.0;

    // Total canvas size
    final double totalWidth = math.max(labelWidth, iconWidth + 24);
    final double totalHeight = labelHeight + arrowHeight + gap + iconHeight;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas =
        Canvas(recorder, Rect.fromLTWH(0, 0, totalWidth, totalHeight));

    // Paints
    final Paint fillPaint = Paint()..color = Colors.white;
    final Paint borderPaint = Paint()
      ..color = statusColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // Draw label bubble (white background)
    final double bubbleLeft = (totalWidth - labelWidth) / 2;
    final RRect bubbleRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bubbleLeft, 0, labelWidth, labelHeight),
      Radius.circular(cornerRadius),
    );
    canvas.drawRRect(bubbleRRect, fillPaint);
    canvas.drawRRect(bubbleRRect, borderPaint);

    // Draw arrow tail (white fill + status border)
    final Path arrowPath = Path();
    final double arrowBaseLeft = totalWidth / 2 - arrowBaseWidth / 2;
    final double arrowBaseRight = totalWidth / 2 + arrowBaseWidth / 2;
    final double arrowBaseY = labelHeight;
    final double arrowTipY = labelHeight + arrowHeight;

    arrowPath.moveTo(arrowBaseLeft, arrowBaseY);
    arrowPath.lineTo(totalWidth / 2, arrowTipY);
    arrowPath.lineTo(arrowBaseRight, arrowBaseY);
    arrowPath.close();

    canvas.drawPath(arrowPath, fillPaint);
    canvas.drawPath(arrowPath, borderPaint);

    // Draw label text (status color with black shadow for visibility)
    final double textLeft = (totalWidth - tp.width) / 2;
    final double textTop = (labelHeight - tp.height) / 2;
    tp.paint(canvas, Offset(textLeft, textTop));

    // Draw vehicle icon without rotation; marker rotation will handle heading
    final double iconLeft = (totalWidth - iconWidth) / 2;
    final double iconTop = labelHeight + arrowHeight + gap;
    canvas.drawImage(baseIcon, Offset(iconLeft, iconTop), Paint());

    final ui.Image finalImage = await recorder.endRecording().toImage(
          totalWidth.toInt(),
          totalHeight.toInt(),
        );
    final ByteData? byteData =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  List<Item> _getFilteredItems() {
    if (deviceListModel?.items == null) return [];
    final items = deviceListModel!.items!;
    if (_selectedStatus == 'all') return items;

    return items.where((item) {
      final ol = item.online?.toLowerCase().trim() ?? '';
      final tl = item.time?.toLowerCase().trim() ?? '';

      switch (_selectedStatus) {
        case 'running':
          return ['online', 'running', 'moving'].contains(ol);
        case 'stopped':
          return ['ack', 'stopped', 'parking'].contains(ol);
        case 'idle':
          return ['idle', 'engine'].contains(ol);
        case 'offline':
          return ol == 'offline' && tl != 'not connected' && tl != 'expired';
        case 'nodata':
          return (ol == 'offline' && tl == 'not connected') ||
              ol == 'never_connected';
        case 'expired':
          return (ol == 'offline' && tl == 'expired') || ol == 'expired';
        default:
          return true;
      }
    }).toList();
  }

  int getStatusCount(String key) {
    if (deviceListModel?.items == null) return 0;
    final items = deviceListModel!.items!;

    String ol(Item i) => i.online?.toLowerCase().trim() ?? '';
    String tl(Item i) => i.time?.toLowerCase().trim() ?? '';

    switch (key) {
      case 'all':
        return items.length;
      case 'running':
        return items
            .where((i) => ['online', 'running', 'moving'].contains(ol(i)))
            .length;
      case 'stopped':
        return items
            .where((i) => ['ack', 'stopped', 'parking'].contains(ol(i)))
            .length;
      case 'idle':
        return items.where((i) => ['idle', 'engine'].contains(ol(i))).length;
      case 'offline':
        return items
            .where((i) =>
                ol(i) == 'offline' &&
                tl(i) != 'not connected' &&
                tl(i) != 'expired')
            .length;
      case 'nodata':
        return items
            .where((i) =>
                (ol(i) == 'offline' && tl(i) == 'not connected') ||
                ol(i) == 'never_connected')
            .length;
      case 'expired':
        return items
            .where((i) =>
                (ol(i) == 'offline' && tl(i) == 'expired') ||
                ol(i) == 'expired')
            .length;
      default:
        return 0;
    }
  }

  String getSelectedStatusTitle() {
    const map = {
      'all': 'All',
      'running': 'Running',
      'stopped': 'Stopped',
      'idle': 'Idle',
      'offline': 'Offline',
      'nodata': 'No Data',
      'expired': 'Expired',
    };
    return map[_selectedStatus] ?? 'Selected';
  }

  Future<void> setSelectedStatus(String newStatus) async {
    final hasStatusChanged = _selectedStatus != newStatus;
    if (hasStatusChanged) {
      _selectedStatus = newStatus;
    }
    if (_selectedVehicle != null) {
      _selectedVehicle = null;
    }
    await _prepareMarkers(_getFilteredItems());
    _notifySafely();
    await _fitToVisibleMarkers();
  }

  void zoomIn() {
    mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void setMapType(MapType type) {
    if (currentMapType == type) return;
    currentMapType = type;
    _notifySafely();
  }

  Future<void> fitAllVehicles() async {
    if (_selectedVehicle != null) {
      _selectedVehicle = null;
      _notifySafely();
    }
    if (mapController == null || deviceMarkers.isEmpty) return;

    final positions = deviceMarkers.map((m) => m.position).toList();
    if (positions.length == 1) {
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: positions.first, zoom: 15),
        ),
      );
      return;
    }

    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final pos in positions) {
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 68),
    );
  }

  Future<void> _fitToVisibleMarkers() async {
    if (mapController == null || deviceMarkers.isEmpty) return;
    final positions = deviceMarkers.map((m) => m.position).toList();
    if (positions.length == 1) {
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: positions.first, zoom: 14.5),
        ),
      );
      return;
    }

    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final pos in positions) {
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    await mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 68),
    );
  }

  List<Item> searchVehiclesByName(String query) {
    final items = _getFilteredItems();
    if (query.trim().isEmpty) return items;
    final q = query.toLowerCase().trim();
    return items
        .where((i) => (i.name ?? '').toLowerCase().contains(q))
        .toList();
  }

  Future<void> focusOnVehicle(Item item) async {
    final lat = double.tryParse(item.lat.toString());
    final lng = double.tryParse(item.lng.toString());
    if (lat == null || lng == null || mapController == null) return;

    await mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 16),
      ),
    );
  }

  Future<void> setClusterMode(bool enabled) async {
    if (enableClusterMode == enabled) return;
    if (enabled) {
      _labelsBeforeCluster = showMarkerLabels;
      showMarkerLabels = false;
    } else {
      showMarkerLabels = _labelsBeforeCluster;
    }
    enableClusterMode = enabled;
    if (mapController != null) {
      _currentZoom = await mapController!.getZoomLevel();
    }
    await _prepareMarkers(_getFilteredItems());
    _notifySafely();
  }

  Future<void> fetchVehicleList({required BuildContext context}) async {
    if (_isDisposed) return;
    final bool isInitialLoad = deviceListModel == null;

    if (isInitialLoad) {
      isLoading = true;
      errorMessage = null;
      deviceMarkers.clear();
      _selectedVehicle = null;
      _notifySafely();
    }

    try {
      final data = await _fetchWithRetry();
      if (_isDisposed) return;
      if (data != null) {
        deviceListModel = data;
        _lastRefreshAt = DateTime.now();
        errorMessage = null;
        await _prepareMarkers(_getFilteredItems());
      } else if (isInitialLoad) {
        errorMessage = "Unable to load vehicles right now. Please try again.";
        deviceMarkers.clear();
      }
    } catch (e) {
      if (_isDisposed) return;
      if (isInitialLoad) {
        errorMessage = _friendlyErrorMessage(e);
        deviceMarkers.clear();
      } else {
        // Keep existing markers for transient failures.
        errorMessage = null;
      }
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        _notifySafely();
      }
    }
  }

  Future<GetDevicesListModel?> _fetchWithRetry() async {
    const maxAttempts = 3;
    Object? lastError;
    for (int i = 1; i <= maxAttempts; i++) {
      try {
        final data = await repository.fetchVehicleData();
        if (data != null) return data;
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
      return "Network connection issue. Please check internet and try again.";
    }
    final raw = error.toString().trim();
    if (raw.startsWith('Exception:')) {
      return raw.replaceFirst('Exception:', '').trim();
    }
    return raw;
  }

  Future<void> _prepareMarkers(List<Item> filteredItems) async {
    if (_isDisposed) return;
    if (enableClusterMode) {
      await _prepareStrictClusterMarkers(filteredItems);
      return;
    }
    // Render a single marker mode per refresh to avoid size flicker/jump.
    if (showMarkerLabels) {
      await _upgradeToLabeledMarkers(filteredItems);
    } else {
      await _prepareNormalMarkers(filteredItems);
    }
  }

  Future<void> _prepareNormalMarkers(List<Item> filteredItems) async {
    if (_isDisposed) return;
    final Set<Marker> markers = {};

    for (var item in filteredItems) {
      if (_isDisposed) return;
      if (item.id == null || item.lat == null || item.lng == null) continue;

      final icon = _getNormalIcon(item);
      final lat = double.tryParse(item.lat.toString());
      final lng = double.tryParse(item.lng.toString());
      if (lat == null || lng == null) continue;

      markers.add(Marker(
        markerId: MarkerId(item.id.toString()),
        position: LatLng(lat, lng),
        rotation: (item.course ?? 0).toDouble(),
        icon: icon,
        anchor: const Offset(0.5, 1.0), // Bottom-center anchor for consistency
        infoWindow: InfoWindow(
          title: item.name ?? 'Unknown',
          snippet:
              "Speed: ${item.speed ?? 0} km/h | ${item.online ?? 'Unknown'}",
        ),
        onTap: () {
          _handleMarkerTap(item.id!, LatLng(lat, lng));
        },
      ));
    }

    if (_isDisposed) return;
    deviceMarkers = markers;
    _notifySafely();
  }

  Future<void> _upgradeToLabeledMarkers(List<Item> filteredItems) async {
    if (_isDisposed) return;
    final Set<Marker> updated = {};

    for (var item in filteredItems) {
      if (_isDisposed) return;
      if (item.id == null || item.lat == null || item.lng == null) continue;

      final statusColor = _getStatusColor(item.online, item.time);
      final colorStr = _getIconColorKey(item.online, item.time);
      final type = _getVehicleType(item);
      final iconKey = '${colorStr}_$type';
      final assetPath = _assetPaths[iconKey] ?? _assetPaths['blue_car']!;
      final lat = double.tryParse(item.lat.toString());
      final lng = double.tryParse(item.lng.toString());
      if (lat == null || lng == null) continue;

      final double vehicleRotation = (item.course ?? 0).toDouble();
      final int rotKey =
          vehicleRotation.round(); // Keep label direction close to exact course

      final cacheKey = '$iconKey|${item.name ?? "Unknown"}|$rotKey';
      final BitmapDescriptor labeledIcon = _labeledIcons[cacheKey] ??=
          await _createLabeledMarker(
              assetPath, item.name ?? 'Vehicle', statusColor);
      if (_isDisposed) return;

      updated.add(Marker(
        markerId: MarkerId(item.id.toString()),
        position: LatLng(lat, lng),
        rotation: vehicleRotation,
        icon: labeledIcon,
        anchor: const Offset(0.5, 1.0), // Bottom-center anchor
        infoWindow: const InfoWindow(),
        onTap: () {
          _handleMarkerTap(item.id!, LatLng(lat, lng));
        },
      ));
    }

    if (_isDisposed) return;
    deviceMarkers = updated;
    _notifySafely();
  }

  void _handleMarkerTap(int deviceId, LatLng position) {
    _selectedVehicle = null;
    final items = deviceListModel?.items;
    if (items != null) {
      for (final i in items) {
        if (i.id == deviceId) {
          _selectedVehicle = i;
          break;
        }
      }
    }
    final now = DateTime.now();
    if (_lastTapTime != null &&
        _lastTappedDeviceId == deviceId &&
        now.difference(_lastTapTime!).inMilliseconds < 400) {
      print("DOUBLE TAP! → Navigate to live tracking");
      _lastTapTime = null;
      _lastTappedDeviceId = null;
    } else {
      _lastTapTime = now;
      _lastTappedDeviceId = deviceId;
      mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 15)));
    }
    _notifySafely();
  }

  Future<void> _prepareStrictClusterMarkers(List<Item> filteredItems) async {
    if (_isDisposed) return;

    if (_currentZoom >= 8.0) {
      await _prepareNormalMarkers(filteredItems);
      return;
    }

    final Map<String, List<Item>> buckets = {};
    final cellSize = _clusterCellSize(_currentZoom);

    for (final item in filteredItems) {
      final lat = double.tryParse(item.lat.toString());
      final lng = double.tryParse(item.lng.toString());
      if (lat == null || lng == null) continue;
      final row = (lat / cellSize).floor();
      final col = (lng / cellSize).floor();
      final key = '$row:$col';
      buckets.putIfAbsent(key, () => <Item>[]).add(item);
    }

    final Set<Marker> clusteredMarkers = {};
    for (final entry in buckets.entries) {
      final list = entry.value;
      if (list.isEmpty) continue;

      double sumLat = 0;
      double sumLng = 0;
      for (final item in list) {
        final lat = double.tryParse(item.lat.toString());
        final lng = double.tryParse(item.lng.toString());
        if (lat == null || lng == null) continue;
        sumLat += lat;
        sumLng += lng;
      }
      final center = LatLng(sumLat / list.length, sumLng / list.length);
      final count = list.length;

      clusteredMarkers.add(
        Marker(
          markerId: MarkerId('cluster_${entry.key}'),
          position: center,
          icon: await _clusterIcon(count),
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(title: '$count vehicles'),
          onTap: () async {
            if (mapController == null) return;
            _selectedVehicle = null;
            _notifySafely();
            final nextZoom = (_currentZoom + 2).clamp(6.0, 18.0);
            await mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: center, zoom: nextZoom),
              ),
            );
          },
        ),
      );
    }

    deviceMarkers = clusteredMarkers;
    _notifySafely();
  }

  double _clusterCellSize(double zoom) {
    if (zoom <= 5.5) return 2.2;
    if (zoom <= 7.0) return 1.2;
    if (zoom <= 8.5) return 0.65;
    if (zoom <= 10.0) return 0.34;
    if (zoom <= 11.5) return 0.2;
    return 0.12;
  }

  Future<BitmapDescriptor> _clusterIcon(int count) async {
    final label = count > 99 ? '99+' : '$count';
    if (_clusterIcons.containsKey(label)) return _clusterIcons[label]!;

    const size = 110.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, size, size));
    final center = const Offset(size / 2, size / 2);

    final outer = Paint()..color = Colors.white;
    final border = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    final inner = Paint()..color = Colors.blue.shade500;

    canvas.drawCircle(center, 43, outer);
    canvas.drawCircle(center, 43, border);
    canvas.drawCircle(center, 36, inner);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));

    final image =
        await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final icon = BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
    _clusterIcons[label] = icon;
    return icon;
  }

  void toggleMapType() {
    currentMapType =
        currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    _notifySafely();
  }

  void toggleTraffic() {
    enableTraffic = !enableTraffic;
    _notifySafely();
  }

  Future<void> toggleMarkerLabels() async {
    if (enableClusterMode) {
      enableClusterMode = false;
    }
    showMarkerLabels = !showMarkerLabels;
    await _prepareMarkers(_getFilteredItems());
    _notifySafely();
  }

  void startPeriodicRefresh(BuildContext context) {
    if (_isDisposed) return;
    _refreshTimer?.cancel();
    fetchVehicleList(context: context);
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isDisposed) return;
      fetchVehicleList(context: context);
    });
  }

  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
  }

  void setMapController(GoogleMapController controller) {
    if (_isDisposed) return;
    mapController = controller;
  }

  void clearSelectedVehicle() {
    if (_selectedVehicle == null) return;
    _selectedVehicle = null;
    _notifySafely();
  }

  Future<void> onCameraIdle() async {
    if (_isDisposed || mapController == null || !enableClusterMode) return;
    final latestZoom = await mapController!.getZoomLevel();
    if ((latestZoom - _currentZoom).abs() < .15) return;
    _currentZoom = latestZoom;
    await _prepareMarkers(_getFilteredItems());
  }

  @override
  void dispose() {
    _isDisposed = true;
    stopPeriodicRefresh();
    mapController?.dispose();
    super.dispose();
  }
}
