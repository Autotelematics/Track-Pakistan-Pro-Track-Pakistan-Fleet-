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

  GetDevicesListModel? deviceListModel;
  Set<Marker> deviceMarkers = {};
  bool isLoading = true;
  String? errorMessage;

  MapType currentMapType = MapType.normal;
  bool enableTraffic = false;
  bool showMarkerLabels = true;

  String _selectedStatus = 'all';
  String get selectedStatus => _selectedStatus;

  Timer? _refreshTimer;
  GoogleMapController? mapController;

  final Map<String, BitmapDescriptor> _icons = {};

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
  };

  final Map<String, BitmapDescriptor> _labeledIcons = {};

  DateTime? _lastTapTime;
  int? _lastTappedDeviceId;

  VehicleMapProvider() {
    _loadMarkerIcons();
  }

  Future<void> _loadMarkerIcons() async {
    final config = ImageConfiguration(size: Size(48, 48));

    for (var entry in _assetPaths.entries) {
      _icons[entry.key] = await BitmapDescriptor.fromAssetImage(config, entry.value);
    }

    notifyListeners();
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
      double rotationDegrees,
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
      targetHeight: 120, // Larger icon for labeled markers
    );
    final ui.FrameInfo fi = await iconCodec.getNextFrame();
    final ui.Image baseIcon = fi.image;

    final double iconWidth = baseIcon.width.toDouble();
    final double iconHeight = baseIcon.height.toDouble();

    // Text settings
    const double fontSize = 32.0;
    const double padding = 20.0;
    const double minLabelWidth = 140.0;

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

    const double cornerRadius = 20.0;

    // Arrow (tail) settings
    const double arrowBaseWidth = 40.0;
    const double arrowHeight = 25.0;

    // Space between arrow tip and vehicle icon
    const double gap = 20.0;

    // Total canvas size
    final double totalWidth = math.max(labelWidth, iconWidth + 40);
    final double totalHeight = labelHeight + arrowHeight + gap + iconHeight;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder, Rect.fromLTWH(0, 0, totalWidth, totalHeight));

    // Paints
    final Paint fillPaint = Paint()..color = Colors.white;
    final Paint borderPaint = Paint()
      ..color = statusColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

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

    // Draw rotated vehicle icon
    final double iconLeft = (totalWidth - iconWidth) / 2;
    final double iconTop = labelHeight + arrowHeight + gap;

    final double iconCenterX = iconLeft + iconWidth / 2;
    final double iconCenterY = iconTop + iconHeight / 2;

    canvas.save();
    canvas.translate(iconCenterX, iconCenterY);
    canvas.rotate(rotationDegrees * math.pi / 180);
    canvas.drawImage(baseIcon, Offset(-iconWidth / 2, -iconHeight / 2), Paint());
    canvas.restore();

    final ui.Image finalImage = await recorder.endRecording().toImage(
      totalWidth.toInt(),
      totalHeight.toInt(),
    );
    final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);

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
          return (ol == 'offline' && tl == 'not connected') || ol == 'never_connected';
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

    final ol = (Item i) => i.online?.toLowerCase().trim() ?? '';
    final tl = (Item i) => i.time?.toLowerCase().trim() ?? '';

    switch (key) {
      case 'all':
        return items.length;
      case 'running':
        return items.where((i) => ['online', 'running', 'moving'].contains(ol(i))).length;
      case 'stopped':
        return items.where((i) => ['ack', 'stopped', 'parking'].contains(ol(i))).length;
      case 'idle':
        return items.where((i) => ['idle', 'engine'].contains(ol(i))).length;
      case 'offline':
        return items.where((i) => ol(i) == 'offline' && tl(i) != 'not connected' && tl(i) != 'expired').length;
      case 'nodata':
        return items.where((i) => (ol(i) == 'offline' && tl(i) == 'not connected') || ol(i) == 'never_connected').length;
      case 'expired':
        return items.where((i) => (ol(i) == 'offline' && tl(i) == 'expired') || ol(i) == 'expired').length;
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

  void setSelectedStatus(String newStatus) {
    if (_selectedStatus == newStatus) return;
    _selectedStatus = newStatus;
    _prepareMarkers(_getFilteredItems());
    notifyListeners();
  }

  void zoomIn() {
    mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> fetchVehicleList({required BuildContext context}) async {
    final bool isInitialLoad = deviceListModel == null;

    if (isInitialLoad) {
      isLoading = true;
      errorMessage = null;
      deviceMarkers.clear();
      notifyListeners();
    }

    try {
      final data = await repository.fetchVehicleData(dialogContext: context);
      if (data != null) {
        deviceListModel = data;
        await _prepareMarkers(_getFilteredItems());
      }
    } catch (e) {
      if (isInitialLoad) {
        errorMessage = "Failed to load vehicles. Please try again.";
        deviceMarkers.clear();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _prepareMarkers(List<Item> filteredItems) async {
    // Fast: show normal icons first
    await _prepareNormalMarkers(filteredItems);

    // Slow: upgrade to labeled if enabled
    if (showMarkerLabels) {
      _upgradeToLabeledMarkers(filteredItems);
    }
  }

  Future<void> _prepareNormalMarkers(List<Item> filteredItems) async {
    final Set<Marker> markers = {};
    final Set<String> seenPositions = {};

    for (var item in filteredItems) {
      if (item.lat == null || item.lng == null) continue;

      final positionKey = '${item.lat}_${item.lng}';
      if (seenPositions.contains(positionKey)) continue;
      seenPositions.add(positionKey);

      final icon = _getNormalIcon(item);

      markers.add(Marker(
        markerId: MarkerId(item.id.toString()),
        position: LatLng(double.tryParse(item.lat.toString()) ?? 0.0, double.tryParse(item.lng.toString()) ?? 0.0),
        rotation: (item.course ?? 0).toDouble(),
        icon: icon,
        anchor: const Offset(0.5, 1.0), // Bottom-center anchor for consistency
        infoWindow: InfoWindow(
          title: item.name ?? 'Unknown',
          snippet: "Speed: ${item.speed ?? 0} km/h | ${item.online ?? 'Unknown'}",
        ),
        onTap: () {
          _handleMarkerTap(item.id!, LatLng(double.parse(item.lat.toString()), double.parse(item.lng.toString())));
        },
      ));
    }

    deviceMarkers = markers;
    notifyListeners();
  }

  void _upgradeToLabeledMarkers(List<Item> filteredItems) async {
    final Set<Marker> updated = {};
    final Set<String> seenPositions = {};

    for (var item in filteredItems) {
      if (item.lat == null || item.lng == null) continue;

      final positionKey = '${item.lat}_${item.lng}';
      if (seenPositions.contains(positionKey)) continue;
      seenPositions.add(positionKey);

      final statusColor = _getStatusColor(item.online, item.time);
      final colorStr = _getIconColorKey(item.online, item.time);
      final type = _getVehicleType(item);
      final iconKey = '${colorStr}_$type';
      final assetPath = _assetPaths[iconKey] ?? _assetPaths['blue_car']!;

      final double vehicleRotation = (item.course ?? 0).toDouble();
      final int rotKey = (vehicleRotation ~/ 10) * 10; // Cache in 10-degree buckets for performance

      final cacheKey = '$iconKey|${item.name ?? "Unknown"}|$rotKey';
      final BitmapDescriptor labeledIcon = _labeledIcons[cacheKey] ??=
      await _createLabeledMarker(assetPath, item.name ?? 'Vehicle', statusColor, vehicleRotation);

      updated.add(Marker(
        markerId: MarkerId(item.id.toString()),
        position: LatLng(double.tryParse(item.lat.toString()) ?? 0.0, double.tryParse(item.lng.toString()) ?? 0.0),
        rotation: 0.0, // Rotation is handled inside the bitmap
        icon: labeledIcon,
        anchor: const Offset(0.5, 1.0), // Bottom-center anchor
        infoWindow: const InfoWindow(),
        onTap: () {
          _handleMarkerTap(item.id!, LatLng(double.parse(item.lat.toString()), double.parse(item.lng.toString())));
        },
      ));
    }

    deviceMarkers = updated;
    notifyListeners();
  }

  void _handleMarkerTap(int deviceId, LatLng position) {
    final now = DateTime.now();
    if (_lastTapTime != null && _lastTappedDeviceId == deviceId && now.difference(_lastTapTime!).inMilliseconds < 400) {
      print("DOUBLE TAP! → Navigate to live tracking");
      _lastTapTime = null;
      _lastTappedDeviceId = null;
    } else {
      _lastTapTime = now;
      _lastTappedDeviceId = deviceId;
      mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: position, zoom: 15)));
    }
  }

  void toggleMapType() {
    currentMapType = currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    notifyListeners();
  }

  void toggleTraffic() {
    enableTraffic = !enableTraffic;
    notifyListeners();
  }

  void toggleMarkerLabels() {
    showMarkerLabels = !showMarkerLabels;
    _prepareMarkers(_getFilteredItems());
    notifyListeners();
  }

  void startPeriodicRefresh(BuildContext context) {
    _refreshTimer?.cancel();
    fetchVehicleList(context: context);
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchVehicleList(context: context);
    });
  }

  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void dispose() {
    stopPeriodicRefresh();
    mapController?.dispose();
    super.dispose();
  }
}