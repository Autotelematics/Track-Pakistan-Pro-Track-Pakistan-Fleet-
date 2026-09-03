import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/get_device_history_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

import 'common_widgets.dart';

class HistoryPlaybackTab extends StatelessWidget {
  final DeviceHistoryProvider provider;
  final ScrollController scrollController;
  final GoogleMapController? mapController;
  final bool showSummaryCards;

  const HistoryPlaybackTab({
    super.key,
    required this.provider,
    required this.scrollController,
    required this.mapController,
    this.showSummaryCards = true,
  });

  static const double _playbackZoom = 15.5;
  static const double _playbackYOffset = 0.0;

  Future<void> _focusPlaybackPosition(LatLng target) async {
    if (mapController == null) return;
    try {
      await mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: _playbackZoom),
        ),
      );
      await mapController!.moveCamera(
        CameraUpdate.scrollBy(0, _playbackYOffset),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return ValueListenableBuilder<int>(
      valueListenable: provider.playbackSliderNotifier,
      builder: (context, sliderValue, _) {
        final hasPosition = sliderValue < provider.routeList.length;
        final pos = hasPosition ? provider.routeList[sliderValue] : null;

        return ListView(
          controller: scrollController,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          children: [
            if (hasPosition && pos != null) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InfoChip(
                        icon: Icons.speed,
                        label: '${pos.speed} km/h',
                        wide: true),
                    SizedBox(width: 2.w),
                    InfoChip(
                        icon: Icons.access_alarm,
                        label: provider.formatDateTimeToAMPM(pos.rawTime ?? pos.time),
                        wide: true),
                    SizedBox(width: 2.w),
                    InfoChip(
                        icon: Icons.directions_car,
                        label: '${pos.distance.toStringAsFixed(2)} km',
                        wide: true),
                  ],
                ),
              ),
              verticalSpace(height: 1.h),
            ],
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.9.h),
              decoration: BoxDecoration(
                color: provider.isPlaying
                    ? Colors.green.withValues(alpha: 0.10)
                    : Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.sp),
                border: Border.all(
                  color: provider.isPlaying
                      ? Colors.green.withValues(alpha: 0.40)
                      : Colors.orange.withValues(alpha: 0.30),
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
                        ? l10n.playingRouteHighlightedGreen
                        : l10n.pausedLabel,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 14.0.sp,
                      color: provider.isPlaying ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            verticalSpace(height: 1.1.h),

            // Slider + controls
            Row(
              children: [
                GestureDetector(
                  onTap: provider.playPause,
                  child: Container(
                    padding: EdgeInsets.all(1.6.w),
                    decoration: BoxDecoration(
                      color: ConstantColor.primaryColor.withValues(alpha: .92),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              ConstantColor.primaryColor.withValues(alpha: .30),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      provider.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 18.sp,
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
                      inactiveTrackColor: onSurface.withValues(alpha: .18),
                      thumbColor: provider.isPlaying
                          ? Colors.green
                          : ConstantColor.primaryColor,
                      overlayColor:
                          ConstantColor.primaryColor.withValues(alpha: .15),
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 16),
                    ),
                    child: Slider(
                      padding: EdgeInsets.zero,
                      value: sliderValue.toDouble(),
                      min: 0,
                      max: provider.sliderValueMax.toDouble(),
                      divisions: provider.sliderValueMax > 0
                          ? provider.sliderValueMax
                          : 1,
                      onChangeStart: (_) {
                        if (provider.isPlaying) {
                          provider.pausePlayback();
                        }
                      },
                      onChanged: (v) {
                        provider.seekTo(v.toInt());
                        if (mapController == null ||
                            provider.carLat == 0 ||
                            provider.carLng == 0) {
                          return;
                        }
                        _focusPlaybackPosition(
                          LatLng(provider.carLat, provider.carLng),
                        );
                      },
                      onChangeEnd: (_) {
                        if (mapController == null ||
                            provider.carLat == 0 ||
                            provider.carLng == 0) {
                          return;
                        }
                        _focusPlaybackPosition(
                          LatLng(provider.carLat, provider.carLng),
                        );
                      },
                    ),
                  ),
                ),
                horizontalSpace(width: 3.w),
                GestureDetector(
                  onTap: provider.changePlaybackSpeed,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 2.2.w, vertical: 0.7.h),
                    decoration: BoxDecoration(
                      color: ConstantColor.primaryColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(6.sp),
                      border: Border.all(
                          color: ConstantColor.primaryColor
                              .withValues(alpha: .36)),
                    ),
                    child: Text(
                      provider.playbackSpeedLabel,
                      style: AppStyles.semiboldTextStyle(context).copyWith(
                        fontSize: 14.sp,
                        color: ConstantColor.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (showSummaryCards) ...[
              verticalSpace(height: 1.1.h),
              Wrap(
                spacing: 2.w,
                runSpacing: .8.h,
                children: [
                  StatCard(
                    l10n.totalTrips,
                    provider.tripCount.toString(),
                    ConstantColor.primaryColor,
                    width: 44.w,
                  ),
                  StatCard(
                    l10n.totalDistance,
                    '${provider.totalDistance.toStringAsFixed(2)} km',
                    const Color(0xFF0EA5E9),
                    width: 44.w,
                  ),
                  StatCard(l10n.moveTime, provider.moveDuration,
                      AppColors.purple,
                      width: 44.w),
                  StatCard(
                      l10n.stopTime, provider.stopDuration, Colors.orange,
                      width: 44.w),
                  StatCard(
                      l10n.topSpeed, provider.topSpeed, AppColors.red,
                      width: 44.w),
                  StatCard(
                    l10n.totalSpent,
                    l10n.rsAmount(provider.totalFuelCost.toStringAsFixed(0)),
                    AppColors.green,
                    width: 44.w,
                  ),
                  StatCard(
                      l10n.fuelLtr,
                      provider.totalFuelSpent.toStringAsFixed(2),
                      AppColors.yellow,
                      width: 44.w),
                  StatCard(
                    l10n.averagePerLiter,
                    provider.averagePerLiter > 0
                        ? '${provider.averagePerLiter.toStringAsFixed(2)} km/L'
                        : '—',
                    const Color(0xFF8B5CF6),
                    width: 44.w,
                  ),
                  StatCard(
                    l10n.engineType,
                    provider.appliedFuelType.isNotEmpty
                        ? provider.appliedFuelType
                        : '—',
                    const Color(0xFF6366F1),
                    width: 44.w,
                  ),
                  StatCard(
                    'Fuel Price',
                    provider.appliedFuelPrice > 0
                        ? '${provider.appliedFuelType}: ${l10n.rsAmount(provider.appliedFuelPrice.toStringAsFixed(2))}'
                        : '—',
                    const Color(0xFFF97316),
                    width: 44.w,
                  ),
                ],
              ),
              verticalSpace(height: 1.2.h),
            ],
          ],
        );
      },
    );
  }
}
