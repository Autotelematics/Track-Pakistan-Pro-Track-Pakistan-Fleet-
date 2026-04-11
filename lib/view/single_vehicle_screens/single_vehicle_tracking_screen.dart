import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/providers/vehicle_tracking_provider.dart';
import 'package:trackerapp/utils/animated_marker.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/single_vehicle_tracking_widget/top_bar.dart';
import 'package:trackerapp/widgets/single_vehicle_tracking_widget/tracking_scale.dart';
import 'package:trackerapp/widgets/single_vehicle_tracking_widget/vehicle_bottom_card.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleTrackingScreen extends StatefulWidget {
  final int deviceId;
  final String? initialVehicleType;
  const VehicleTrackingScreen({
    super.key,
    required this.deviceId,
    this.initialVehicleType,
  });
  @override
  State<VehicleTrackingScreen> createState() => _VehicleTrackingScreenState();
}

class _VehicleTrackingScreenState extends State<VehicleTrackingScreen>
    with WidgetsBindingObserver {
  static const double _vehicleMarkerLogicalHeight = 30.0;
  static const double _vehicleMarkerRenderScale = 3.0;
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? mapController;
  late VehicleTrackingProvider provider;
  bool _isDisposing = false;
  LatLng? _lastCameraTarget;
  double? _lastCameraZoom;
  bool _isCameraAnimating = false;
  LatLng? _pendingCameraTarget;
  double? _pendingCameraZoom;
  bool _showUserDistanceBanner = false;
  final Map<String, BitmapDescriptor> _markerIconCache = {};
  String? _loadingMarkerIconKey;
  BitmapDescriptor? _activeMarkerIcon;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    provider = VehicleTrackingProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.startPeriodicRefresh(widget.deviceId);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    if (_isDisposing) {
      try {
        controller.dispose();
      } catch (_) {}
      return;
    }
    if (!_controller.isCompleted) _controller.complete(controller);
    mapController = controller;
  }

  Future<void> _animateCameraToLocation(
      LatLng targetLocation, double zoom) async {
    if (_isDisposing) return;
    if (_isCameraAnimating) {
      _pendingCameraTarget = targetLocation;
      _pendingCameraZoom = zoom;
      return;
    }
    if (mapController != null && mounted) {
      _isCameraAnimating = true;
      try {
        CameraPosition cameraPosition =
            CameraPosition(target: targetLocation, zoom: zoom);
        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition),
        );
      } catch (e) {
        // Optionally log or ignore; map might be disposed or busy
      } finally {
        _isCameraAnimating = false;
        final pendingTarget = _pendingCameraTarget;
        final pendingZoom = _pendingCameraZoom;
        _pendingCameraTarget = null;
        _pendingCameraZoom = null;
        if (pendingTarget != null &&
            pendingZoom != null &&
            mounted &&
            !_isDisposing) {
          final shouldRunNext = _lastCameraTarget == null ||
              (pendingTarget.latitude - _lastCameraTarget!.latitude).abs() >
                  0.000001 ||
              (pendingTarget.longitude - _lastCameraTarget!.longitude).abs() >
                  0.000001 ||
              pendingZoom != _lastCameraZoom;
          if (shouldRunNext) {
            await _animateCameraToLocation(pendingTarget, pendingZoom);
          }
        }
      }
    }
  }

  Future<void> _resetNorth({
    required LatLng fallbackTarget,
    required double zoom,
  }) async {
    if (_isDisposing) return;
    if (mapController == null || !mounted) return;
    LatLng target = fallbackTarget;
    try {
      final bounds = await mapController!.getVisibleRegion();
      target = LatLng(
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );
    } catch (_) {
      // Keep fallback target if visible region cannot be read.
    }
    try {
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: zoom,
            bearing: 0,
            tilt: 0,
          ),
        ),
      );
    } catch (_) {}
  }

  Future<void> _locateUserAndMeasure(VehicleTrackingProvider prov) async {
    // Toggle behavior:
    // 1st tap -> show both locations and distance banner
    // 2nd tap -> return to vehicle and hide banner
    if (_showUserDistanceBanner) {
      if (mounted) {
        setState(() => _showUserDistanceBanner = false);
      }
      final vehicle = LatLng(prov.latitude, prov.longitude);
      prov.centerOnVehicle();
      await _animateCameraToLocation(vehicle, prov.currentZoom);
      return;
    }

    final ok = await prov.fetchUserLocation();
    if (!ok || !mounted) {
      if (mounted) {
        setState(() => _showUserDistanceBanner = false);
      }
      return;
    }
    final user = prov.userPosition;
    if (user == null || mapController == null) {
      if (mounted) {
        setState(() => _showUserDistanceBanner = false);
      }
      return;
    }

    final vehicle = LatLng(prov.latitude, prov.longitude);
    final myLoc = LatLng(user.latitude, user.longitude);

    final bounds = LatLngBounds(
      southwest: LatLng(
        min(vehicle.latitude, myLoc.latitude),
        min(vehicle.longitude, myLoc.longitude),
      ),
      northeast: LatLng(
        max(vehicle.latitude, myLoc.latitude),
        max(vehicle.longitude, myLoc.longitude),
      ),
    );

    try {
      await mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 90),
      );
    } catch (_) {
      return;
    }
    if (mounted) {
      setState(() => _showUserDistanceBanner = true);
    }
  }

  Future<void> _openDirectionsToVehicle(VehicleTrackingProvider prov) async {
    final l10n = context.l10n;
    final destinationLat = prov.latitude;
    final destinationLng = prov.longitude;

    if (destinationLat == 0.0 || destinationLng == 0.0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.vehicleLocationUnavailable)),
      );
      return;
    }

    LatLng? origin;
    final hasLocation = await prov.fetchUserLocation();
    if (hasLocation && prov.userPosition != null) {
      origin =
          LatLng(prov.userPosition!.latitude, prov.userPosition!.longitude);
    }

    final directionsUrl = origin == null
        ? 'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&travelmode=driving'
        : 'https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}&destination=$destinationLat,$destinationLng&travelmode=driving';

    final uri = Uri.parse(directionsUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unableOpenDirections)),
      );
    }
  }

  Future<BitmapDescriptor> _markerIcon(
    String status,
    String vehicleType, {
    required double markerLogicalHeight,
  }) async {
    final typeLower = vehicleType.toLowerCase().trim();
    String baseType = "car";
    if (typeLower.contains("ambulance")) {
      baseType = "ambulance";
    } else if (typeLower.contains("bus")) {
      baseType = "bus";
    } else if (typeLower.contains("bike") || typeLower.contains("motorcycle")) {
      baseType = "bike";
    } else if (typeLower.contains("truck")) {
      baseType = "truck";
    }

    String color = "blue";
    switch (status.toLowerCase().trim()) {
      case "online":
      case "running":
      case "moving":
        color = "green";
        break;
      case "ack":
      case "stopped":
        color = "red";
        break;
      case "engine":
      case "idle":
        color = "yellow";
        break;
      default:
        color = "blue";
    }

    final primaryPath = baseType == "truck" && color == "yellow"
        ? "assets/images/Truck_Yellow.png"
        : "assets/images/${baseType}_$color.png";

    Future<BitmapDescriptor> fromAssetPath(String path) async {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetHeight:
            (markerLogicalHeight * 1.22 * _vehicleMarkerRenderScale).round(),
      );
      final frame = await codec.getNextFrame();
      final bytes =
          await frame.image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      }
      return BitmapDescriptor.bytes(
        bytes.buffer.asUint8List(),
        width: frame.image.width.toDouble() / _vehicleMarkerRenderScale,
        height: frame.image.height.toDouble() / _vehicleMarkerRenderScale,
        imagePixelRatio: _vehicleMarkerRenderScale,
      );
    }

    try {
      return await fromAssetPath(primaryPath);
    } catch (_) {
      final fallbackPath = "assets/images/car_$color.png";
      try {
        return await fromAssetPath(fallbackPath);
      } catch (_) {
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        );
      }
    }
  }

  String _markerIconCacheKey({
    required String status,
    required String vehicleType,
    required double markerLogicalHeight,
  }) {
    return '${status.trim().toLowerCase()}|${vehicleType.trim().toLowerCase()}|${markerLogicalHeight.toStringAsFixed(2)}';
  }

  void _ensureMarkerIconLoaded({
    required String status,
    required String vehicleType,
    required double markerLogicalHeight,
  }) {
    final key = _markerIconCacheKey(
      status: status,
      vehicleType: vehicleType,
      markerLogicalHeight: markerLogicalHeight,
    );

    final cached = _markerIconCache[key];
    if (cached != null) {
      _activeMarkerIcon = cached;
      return;
    }

    if (_loadingMarkerIconKey == key) return;
    _loadingMarkerIconKey = key;
    _markerIcon(
      status,
      vehicleType,
      markerLogicalHeight: markerLogicalHeight,
    ).then((icon) {
      if (!mounted || _isDisposing) return;
      _markerIconCache[key] = icon;
      _loadingMarkerIconKey = null;
      setState(() {
        _activeMarkerIcon = icon;
      });
    }).catchError((_) {
      if (!mounted || _isDisposing) return;
      _loadingMarkerIconKey = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textScale = trackingTextScale(context);
    final iconScale = trackingIconScale(context);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    const waitingBannerTop = 68.0;
    const infoBannerTop = 92.0;
    const rulerBannerTop = 130.0;
    final markerLogicalHeight = _adaptiveMarkerLogicalHeight(context);
    return ChangeNotifierProvider.value(
      value: provider,
      child: Scaffold(
        body: Consumer<VehicleTrackingProvider>(
          builder: (context, prov, child) {
            if (prov.isLoading && prov.deviceData == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (prov.hasNoData) {
              return _buildStatusState(
                icon: Icons.sensors_off_rounded,
                title: l10n.noLiveData,
                subtitle: prov.noDataMessage ?? l10n.noVehicleDataAvailable,
              );
            }
            if (prov.errorMessage != null && prov.deviceData == null) {
              return _buildStatusState(
                icon: Icons.error_outline_rounded,
                title: l10n.unableLoadTracking,
                subtitle: prov.errorMessage!,
              );
            }
            if (prov.latitude == 0.0 ||
                prov.longitude == 0.0 ||
                prov.deviceData == null) {
              return _buildStatusState(
                icon: Icons.location_off_rounded,
                title: l10n.locationUnavailable,
                subtitle: l10n.liveLocationUnavailableVehicle,
              );
            }
            final pos = LatLng(prov.latitude, prov.longitude);
            final markerMotionStatus = prov.markerVisualStatus;
            if (prov.followVehicle) {
              final shouldAnimate = _lastCameraTarget == null ||
                  (pos.latitude - _lastCameraTarget!.latitude).abs() >
                      0.00001 ||
                  (pos.longitude - _lastCameraTarget!.longitude).abs() >
                      0.00001 ||
                  _lastCameraZoom != prov.currentZoom;
              if (shouldAnimate) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _animateCameraToLocation(pos, prov.currentZoom);
                });
                _lastCameraTarget = pos;
                _lastCameraZoom = prov.currentZoom;
              }
            }
            final vehicleType = prov.vehicleType.trim().isNotEmpty
                ? prov.vehicleType
                : (widget.initialVehicleType ?? '');
            _ensureMarkerIconLoaded(
              status: markerMotionStatus,
              vehicleType: vehicleType,
              markerLogicalHeight: markerLogicalHeight,
            );

            final targetMarker = Marker(
              markerId: const MarkerId("vehicle"),
              position: pos,
              rotation: prov.course,
              flat: false,
              anchor: const Offset(0.5, 0.5),
              icon: _activeMarkerIcon ??
                  BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
            );
            final userPosition = prov.userPosition;
            final userMarker = userPosition == null
                ? null
                : Marker(
                    markerId: const MarkerId("my_location"),
                    position: LatLng(
                      userPosition.latitude,
                      userPosition.longitude,
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                    infoWindow: InfoWindow(title: l10n.yourLocation),
                  );

            final mapWidget = AnimatedMarker(
              animatedMarkers: {targetMarker},
              staticMarkers: {
                ...prov.rulerMarkers,
                if (userMarker != null) userMarker,
              },
              duration: Duration(
                milliseconds: prov.markerAnimationDurationMs,
              ),
              fps: 30,
              curve: Curves.linear,
              builder: (context, animatedMarkers) {
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: pos,
                    zoom: prov.currentZoom,
                  ),
                  markers: animatedMarkers,
                  polylines: prov.rulerPolylines,
                  mapType: prov.currentMapType,
                  trafficEnabled: prov.enableTraffic,
                  onMapCreated: _onMapCreated,
                  onTap: prov.handleRulerTap,
                  zoomControlsEnabled: false,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  padding: EdgeInsets.only(
                    bottom: 150 + bottomInset,
                    right: 7,
                  ),
                );
              },
            );

            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: IconTheme(
                data: IconTheme.of(context).copyWith(size: 24 * iconScale),
                child: Stack(
                  children: [
                    mapWidget,
                    TopBar(
                      status: prov.status,
                      onResetNorth: () => _resetNorth(
                        fallbackTarget: pos,
                        zoom: prov.currentZoom,
                      ),
                      onLocateUser: () => _locateUserAndMeasure(prov),
                      onOpenDirections: () => _openDirectionsToVehicle(prov),
                    ),
                    Positioned(
                      top: waitingBannerTop,
                      left: 4.w,
                      child: _WaitingPacketBanner(
                        show: prov.shouldShowWaitingForPacket,
                      ),
                    ),
                    if (_showUserDistanceBanner && prov.userPosition != null)
                      Positioned(
                        top: infoBannerTop,
                        left: 4.w,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .62),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Vehicle is ${prov.distanceToVehicleLabel}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (prov.isLocatingUser)
                      Positioned(
                        top: infoBannerTop,
                        left: 4.w,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .62),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Locating your phone...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (prov.rulerMode)
                      Positioned(
                        top: rulerBannerTop,
                        left: 4.w,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .62),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Ruler: ${prov.rulerDistanceLabel}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (prov.rulerPoints.isNotEmpty) ...[
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: prov.clearRulerPoints,
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: VehicleBottomCard(
                        deviceId: prov.deviceId,
                        deviceName: prov.deviceName,
                        deviceSpeed: prov.deviceSpeed,
                        totalDistance: prov.totalDistance,
                        vehicleOdometer: prov.odometer,
                        deviceAddress: prov.address,
                        deviceLatestUpdate: prov.lastUpdate,
                        sensors: prov.sensors,
                        param: prov.param,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _adaptiveMarkerLogicalHeight(BuildContext context) {
    const baselineShortest = 393.0; // iPhone 15 Pro baseline
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final scale = (shortest / baselineShortest).clamp(1.0, 1.45);
    return _vehicleMarkerLogicalHeight * scale;
  }

  @override
  void dispose() {
    _isDisposing = true;
    WidgetsBinding.instance.removeObserver(this);
    provider.dispose();
    try {
      mapController?.dispose();
    } catch (_) {}
    mapController = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposing) return;
    if (state == AppLifecycleState.resumed) {
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (!mounted || _isDisposing) return;
        provider.fetchDeviceLiveTracking(
          deviceId: widget.deviceId,
          isRefresh: true,
        );
      });
    }
  }

  Widget _buildStatusState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36.sp, color: Colors.grey.shade500),
            SizedBox(height: 1.4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: .8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaitingPacketBanner extends StatefulWidget {
  final bool show;

  const _WaitingPacketBanner({required this.show});

  @override
  State<_WaitingPacketBanner> createState() => _WaitingPacketBannerState();
}

class _WaitingPacketBannerState extends State<_WaitingPacketBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: .45, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: widget.show
          ? FadeTransition(
              key: const ValueKey('waiting-packet-banner'),
              opacity: _opacity,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1FBF75).withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF1FBF75).withValues(alpha: .32),
                  ),
                ),
                child: Text(
                  'Waiting for new packet',
                  style: TextStyle(
                    color: const Color(0xFF138A53),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(
              key: ValueKey('no-waiting-packet-banner'),
            ),
    );
  }
}
