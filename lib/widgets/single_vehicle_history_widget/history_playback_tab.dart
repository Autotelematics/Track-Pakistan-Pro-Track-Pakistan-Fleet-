import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/get_device_history_provider.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'common_widgets.dart';

class HistoryPlaybackTab extends StatelessWidget {
  final DeviceHistoryProvider provider;
  final ScrollController scrollController;
  final GoogleMapController? mapController;

  const HistoryPlaybackTab({
    super.key,
    required this.provider,
    required this.scrollController,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    final hasPosition =
        provider.currentSliderValue < provider.routeList.length;
    final pos =
    hasPosition ? provider.routeList[provider.currentSliderValue] : null;

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      children: [
        if (hasPosition && pos != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InfoChip(icon: Icons.speed, label: '${pos.speed} km/h'),
              InfoChip(icon: Icons.access_alarm, label: pos.rawTime ?? '—'),
              InfoChip(
                  icon: Icons.directions_car,
                  label: '${pos.distance.toStringAsFixed(2)} km'),
            ],
          ),
          verticalSpace(height: 1.5.h),
        ],
        // Playback status indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
          decoration: BoxDecoration(
            color: provider.isPlaying
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10.sp),
            border: Border.all(
              color: provider.isPlaying
                  ? Colors.green.withOpacity(0.4)
                  : Colors.orange.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                provider.isPlaying
                    ? Icons.fiber_manual_record
                    : Icons.pause_circle_outline,
                color: provider.isPlaying ? Colors.green : Colors.orange,
                size: 18.sp,
              ),
              horizontalSpace(width: 1.5.w),
              Text(
                provider.isPlaying
                    ? 'Playing — route highlighted green'
                    : 'Paused',
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 15.sp,
                  color: provider.isPlaying ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        verticalSpace(height: 1.5.h),

        // Slider + controls
        Row(
          children: [
            GestureDetector(
              onTap: provider.playPause,
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: ConstantColor.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  provider.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
            horizontalSpace(width: 3.w),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: provider.isPlaying
                      ? Colors.green
                      : ConstantColor.primaryColor,
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: provider.isPlaying
                      ? Colors.green
                      : ConstantColor.primaryColor,
                  overlayColor: ConstantColor.primaryColor.withOpacity(0.15),
                  thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 16),
                ),
                child: Slider(
                  padding: EdgeInsets.zero,
                  value: provider.currentSliderValue.toDouble(),
                  min: 0,
                  max: provider.sliderValueMax.toDouble(),
                  divisions:
                  provider.sliderValueMax > 0 ? provider.sliderValueMax : 1,
                  onChanged: (v) {
                    provider.seekTo(v.toInt());
                    if (mapController != null &&
                        v.toInt() < provider.routeList.length) {
                      final loc = provider.routeList[v.toInt()];
                      mapController!.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                              target: LatLng(loc.lat, loc.lng), zoom: 17),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            horizontalSpace(width: 3.w),
            GestureDetector(
              onTap: provider.changePlaybackSpeed,
              child: Container(
                padding:
                EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  color: ConstantColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.sp),
                  border: Border.all(
                      color: ConstantColor.primaryColor.withOpacity(0.4)),
                ),
                child: Text(
                  provider.playbackSpeedLabel,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 13.sp,
                    color: ConstantColor.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        verticalSpace(height: 1.5.h),

        // Stats grid
        Row(
          children: [
            Expanded(
              child: Column(children: [
                StatCard("Total Trips", provider.tripCount.toString(),
                    ConstantColor.primaryColor),
                StatCard("Move Time", provider.moveDuration, AppColors.purple),
              ]),
            ),
            Expanded(
              child: Column(children: [
                StatCard("Fuel (LTR)",
                    provider.totalFuelSpent.toStringAsFixed(2), AppColors.yellow),
                StatCard("Stop Time", provider.stopDuration, Colors.orange),
              ]),
            ),
            Expanded(
              child: Column(children: [
                StatCard(
                    "Total Spent",
                    "Rs. ${provider.totalFuelCost.toStringAsFixed(0)}",
                    AppColors.green),
                StatCard("Top Speed", provider.topSpeed, AppColors.red),
              ]),
            ),
          ],
        ),
        verticalSpace(height: 1.h),
      ],
    );
  }
}