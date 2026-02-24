import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trackerapp/providers/vehicle_tracking_provider.dart';
import 'package:trackerapp/utils/animated_marker.dart';
import 'package:trackerapp/widgets/single_vehicle_tracking_widget/top_bar.dart';
import 'package:trackerapp/widgets/single_vehicle_tracking_widget/vehicle_bottom_card.dart';

class VehicleTrackingScreen extends StatefulWidget {
  final int deviceId;
  const VehicleTrackingScreen({super.key, required this.deviceId});
  @override
  State<VehicleTrackingScreen> createState() => _VehicleTrackingScreenState();
}
class _VehicleTrackingScreenState extends State<VehicleTrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? mapController;
  late VehicleTrackingProvider provider;
  @override
  void initState() {
    super.initState();
    provider = VehicleTrackingProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.fetchDeviceLiveTracking(
        deviceId: widget.deviceId,
        context: context,
      );

      provider.startPeriodicRefresh(widget.deviceId, context);
    });
  }
  void _onMapCreated(GoogleMapController controller)
  {
    if (!_controller.isCompleted) _controller.complete(controller);
    mapController = controller;
  }
  Future<void> _animateCameraToLocation(LatLng targetLocation, double zoom)
  async {
    if (mapController != null && mounted) {
      try {
        CameraPosition cameraPosition =
        CameraPosition(target: targetLocation, zoom: zoom);
        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition),
        );
      } catch (e) {
        // Optionally log or ignore; map might be disposed or busy
      }
    }
  }
  Future<BitmapDescriptor> _markerIcon(String status) async {
    String path = "assets/images/car_";
    switch (status.toLowerCase()) {
      case "running":
        path += "green.png";
        break;
      case "stopped":
        path += "red.png";
        break;
      case "idle":
        path += "yellow.png";
        break;
      default:
        path += "blue.png";
    }
    return BitmapDescriptor.asset(
      ImageConfiguration(
        size: Size(20, 38),
      ),
      path,
    );
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: Scaffold(
        body: Consumer<VehicleTrackingProvider>(
          builder: (context, prov, child) {
            if (prov.latitude == 0.0 ||
                prov.longitude == 0.0 ||
                prov.deviceData == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final pos = LatLng(prov.latitude, prov.longitude);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _animateCameraToLocation(pos, prov.currentZoom);
            });
            return FutureBuilder<BitmapDescriptor>(
              future: _markerIcon(prov.vehicleStatusText),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final targetMarker = Marker(
                  markerId: const MarkerId("vehicle"),
                  position: pos,
                  rotation: prov.course,
                  flat: true,
                  anchor: const Offset(0.5, 0.5),
                  icon: snap.data!,
                );

                String displayStatus = prov.vehicleStatusText;
                if (prov.status == 'ack') {
                  displayStatus += ' since ${prov.deviceStopDuration}';
                }

                Widget mapWidget;
                if (prov.status == 'online') {
                  mapWidget = AnimatedMarker(
                    animatedMarkers: {targetMarker},
                    duration: const Duration(seconds: 15),
                    fps: 20,
                    curve: Curves.ease,
                    builder: (context, animatedMarkers) {
                      return GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: pos,
                          zoom: prov.currentZoom,
                        ),
                        markers: animatedMarkers,
                        mapType: prov.currentMapType,
                        trafficEnabled: prov.enableTraffic,
                        onMapCreated: _onMapCreated,
                        zoomControlsEnabled: false,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        padding: const EdgeInsets.only(bottom: 200, right: 7, left: 15, top: 15),
                      );
                    },
                  );
                } else {
                  mapWidget = GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: pos,
                      zoom: prov.currentZoom,
                    ),
                    markers: {targetMarker},
                    mapType: prov.currentMapType,
                    trafficEnabled: prov.enableTraffic,
                    onMapCreated: _onMapCreated,
                    zoomControlsEnabled: false,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    padding: const EdgeInsets.only(bottom: 150, right: 7),
                  );
                }

                return Stack(
                  children: [
                    mapWidget,
                    TopBar(status: prov.status),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: VehicleBottomCard(
                        deviceId: prov.deviceId,
                        deviceName: prov.deviceName,
                        deviceSpeed: prov.deviceSpeed,
                        totalDistance: prov.totalDistance,
                        vehicleStatusText: displayStatus,
                        deviceAddress: prov.address,
                        deviceLatestUpdate: prov.lastUpdate,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    provider.dispose();
    mapController?.dispose();
    super.dispose();
  }
}