import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackerapp/widgets/vehicle_tracking_widget/top_bar.dart';
import 'package:trackerapp/widgets/vehicle_tracking_widget/vehicle_bottom_card.dart';

class VehicleTrackingScreen extends StatefulWidget {
  const VehicleTrackingScreen({super.key});

  @override
  State<VehicleTrackingScreen> createState() => _VehicleTrackingScreenState();
}

class _VehicleTrackingScreenState extends State<VehicleTrackingScreen> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _carIcon;

  @override
  void initState() {
    super.initState();
    _loadCarIcon();
  }

  Future<void> _loadCarIcon() async {
    final icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/car_top_view.png',
    );
    setState(() => _carIcon = icon);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final theme = Theme.of(context);
    if (theme.brightness == Brightness.dark) {
      _mapController!.setMapStyle(_darkMapStyle);
    }
  }
  final String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{ "color": "#212121" }]
    },
    {
      "elementType": "labels.icon",
      "stylers": [{ "visibility": "off" }]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{ "color": "#757575" }]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{ "color": "#212121" }]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{ "color": "#2c2c2c" }]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [{ "color": "#8a8a8a" }]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{ "color": "#000000" }]
    }
  ]
  ''';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(24.849269, 67.005017),
                zoom: 15.5,
              ),
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: _onMapCreated,
              markers: {
                Marker(
                  markerId: const MarkerId('vehicle'),
                  position: const LatLng(24.849269, 67.005017),
                  icon: _carIcon ?? BitmapDescriptor.defaultMarkerWithHue(120),
                  rotation: 45,
                ),
              },
            ),
            const TopBar(),
            const VehicleBottomCard(),
          ],
        ),

    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_mapController != null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      _mapController!.setMapStyle(isDark ? _darkMapStyle : '');
    }
  }
}