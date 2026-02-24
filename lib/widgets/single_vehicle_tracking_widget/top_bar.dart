import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackerapp/providers/vehicle_tracking_provider.dart';
import 'package:trackerapp/widgets/single_vehicle_tracking_widget/right_side_buttons.dart';
import 'common_small_widgets.dart';

class TopBar extends StatelessWidget {
  final String status;
  const TopBar({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleTrackingProvider>(
      builder: (context, provider, child) {
        String displayStatusText = provider.status == "online" ? "Moving" : "Stopped";


        return Positioned(
          top: 8.h,
          left: 3.w,
          right: 3.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(),
              MovingChip(
                text: displayStatusText,
                color: provider.ignitionColor,
              ),
              // Right buttons
              RightSideButtons(
                status: provider.status,
                onToggleMap: provider.toggleMapType,
                onToggleTraffic: provider.toggleTraffic,
                onCenter: () {
                  provider.centerOnVehicle();
                },
                onZoomIn: () {
                  provider.adjustZoom(provider.currentZoom + 1);
                },
                onZoomOut: () {
                  provider.adjustZoom(provider.currentZoom - 1);
                },
                onShare: () {
                  final lat = provider.latitude;
                  final lng = provider.longitude;
                  final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                  Share.share('Vehicle Location: $url');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}