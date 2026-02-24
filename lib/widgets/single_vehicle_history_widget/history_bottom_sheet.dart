import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/providers/get_device_history_provider.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'common_widgets.dart';
import 'history_playback_tab.dart';
import 'history_trips_tab.dart';

class HistoryBottomSheet extends StatefulWidget {
  final DeviceHistoryProvider provider;
  final GoogleMapController? mapController;

  const HistoryBottomSheet({
    super.key,
    required this.provider,
    required this.mapController,
  });

  @override
  State<HistoryBottomSheet> createState() => _HistoryBottomSheetState();
}

class _HistoryBottomSheetState extends State<HistoryBottomSheet> {
  int _bottomTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.13,
      maxChildSize: 0.88,
      snap: true,
      snapSizes: const [0.13, 0.38, 0.88],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Container(
                  width: 10.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Tab row
              Padding(
                padding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  children: [
                    SheetTab(
                      label: 'Playback',
                      icon: Icons.play_circle_outline_rounded,
                      isSelected: _bottomTabIndex == 0,
                      onTap: () => setState(() => _bottomTabIndex = 0),
                    ),
                    horizontalSpace(width: 2.w),
                    SheetTab(
                      label:
                      'Trips (${widget.provider.tripSegments.length})',
                      icon: Icons.route_outlined,
                      isSelected: _bottomTabIndex == 1,
                      onTap: () => setState(() => _bottomTabIndex = 1),
                    ),
                  ],
                ),
              ),
              // Tab content
              Expanded(
                child: _bottomTabIndex == 0
                    ? HistoryPlaybackTab(
                  provider: widget.provider,
                  scrollController: scrollController,
                  mapController: widget.mapController,
                )
                    : HistoryTripsTab(
                  provider: widget.provider,
                  scrollController: scrollController,
                  mapController: widget.mapController,
                  onTripPlay: () =>
                      setState(() => _bottomTabIndex = 0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}