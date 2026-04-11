import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/get_device_history_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

import 'common_widgets.dart';

class HistoryAlertsTab extends StatelessWidget {
  final DeviceHistoryProvider provider;
  final ScrollController scrollController;
  final GoogleMapController? mapController;

  const HistoryAlertsTab({
    super.key,
    required this.provider,
    required this.scrollController,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final alerts = provider.alertSegments;
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 40.sp, color: Colors.grey.shade400),
            verticalSpace(height: 1.h),
            Text(
              l10n.noHistoryAlertsFound,
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
      itemCount: alerts.length,
      itemBuilder: (context, i) => AlertCard(
        alert: alerts[i],
        onTap: () {
          if (provider.routeList.isEmpty || mapController == null) return;
          final idx = alerts[i]
              .anchorRouteIndex
              .clamp(0, provider.routeList.length - 1);
          provider.seekTo(idx);
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: alerts[i].position,
                zoom: 17,
              ),
            ),
          );
        },
      ),
    );
  }
}
