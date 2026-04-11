import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/get_device_history_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

import 'common_widgets.dart';

class HistoryParkedTab extends StatelessWidget {
  final DeviceHistoryProvider provider;
  final ScrollController scrollController;
  final GoogleMapController? mapController;

  const HistoryParkedTab({
    super.key,
    required this.provider,
    required this.scrollController,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final parked = provider.parkedSegments;
    if (parked.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_parking, size: 40.sp, color: Colors.grey.shade400),
            verticalSpace(height: 1.h),
            Text(
              l10n.noParkedIntervals,
              style: AppStyles.regularTextStyle(context)
                  .copyWith(fontSize: 15.sp, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      itemCount: parked.length,
      itemBuilder: (context, i) => ParkedCard(
        parked: parked[i],
        onTap: () {
          if (provider.routeList.isEmpty || mapController == null) return;
          final idx = parked[i]
              .anchorRouteIndex
              .clamp(0, provider.routeList.length - 1);
          provider.seekTo(idx);
          final loc = provider.routeList[idx];
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(loc.lat, loc.lng),
                zoom: 17,
              ),
            ),
          );
        },
      ),
    );
  }
}
