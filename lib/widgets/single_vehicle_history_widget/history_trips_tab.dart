import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/get_device_history_provider.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'common_widgets.dart';

class HistoryTripsTab extends StatelessWidget {
  final DeviceHistoryProvider provider;
  final ScrollController scrollController;
  final GoogleMapController? mapController;
  final VoidCallback onTripPlay;

  const HistoryTripsTab({
    super.key,
    required this.provider,
    required this.scrollController,
    required this.mapController,
    required this.onTripPlay,
  });

  @override
  Widget build(BuildContext context) {
    final trips = provider.tripSegments;

    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route, size: 40.sp, color: Colors.grey.shade400),
            verticalSpace(height: 1.h),
            Text('No trips found',
                style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: 15.sp, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      itemCount: trips.length,
      itemBuilder: (context, i) {
        final trip = trips[i];
        final isSelected = provider.selectedTripIndex == i;
        return TripCard(
          trip: trip,
          tripNumber: i + 1,
          isSelected: isSelected,
          onTap: () {
            provider.selectTrip(i);
            final bounds = provider.calculateTripBounds(trip);
            if (bounds != null && mapController != null) {
              mapController!.animateCamera(
                  CameraUpdate.newLatLngBounds(bounds, 60));
            }
          },
          onPlay: () {
            provider.selectTrip(i);
            provider.seekTo(trip.startRouteIndex);
            provider.startPlayback();
            onTripPlay();
          },
        );
      },
    );
  }
}