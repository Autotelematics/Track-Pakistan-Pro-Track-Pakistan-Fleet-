import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/providers/vehicle_tracking_provider.dart';
import 'package:trackerapp/widgets/single_vehicle_tracking_widget/right_side_buttons.dart';

class TopBar extends StatelessWidget {
  final String status;
  final VoidCallback? onResetNorth;
  final VoidCallback? onLocateUser;
  final VoidCallback? onOpenDirections;
  const TopBar({
    super.key,
    required this.status,
    this.onResetNorth,
    this.onLocateUser,
    this.onOpenDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleTrackingProvider>(
      builder: (context, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final panelBase = isDark ? const Color(0xFF1B1D24) : AppColors.white;
        final panelText = isDark ? AppColors.white : AppColors.textBlack;
        final panelSubText = isDark ? Colors.white70 : Colors.black54;
        final lastUpdateText =
            provider.lastUpdate.trim().isEmpty ? "N/A" : provider.lastUpdate;
        final String displayStatus = provider.vehicleStatusText;
        final statusColor = provider.ignitionColor;
        final isRunning = provider.status == 'online';

        return Positioned(
          top: 5.2.h,
          left: 3.w,
          right: 3.w,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  constraints: BoxConstraints(minHeight: 4.6.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.8.w, vertical: .7.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        panelBase.withOpacity(.98),
                        isDark
                            ? const Color(0xFF252933).withOpacity(.98)
                            : const Color(0xFFF7F9FC).withOpacity(.98),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                      width: .7,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? .28 : .12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 2.7.h,
                        height: 2.7.h,
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.radar_rounded,
                          color: AppColors.green,
                          size: 1.6.h,
                        ),
                      ),
                      SizedBox(width: 1.9.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Live Tracking",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: panelText,
                                fontSize: 12.8.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: .2,
                              ),
                            ),
                            SizedBox(height: .2.h),
                            Row(
                              children: [
                                Text(
                                  'Updated at : $lastUpdateText',
                                  style: TextStyle(
                                    color: panelSubText,
                                    fontSize: 10.8.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (provider.enableTraffic) ...[
                                  SizedBox(width: 1.5.w),
                                  Container(
                                    width: .6.h,
                                    height: .6.h,
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: .9.w),
                                  Text(
                                    "Traffic",
                                    style: TextStyle(
                                      color: panelSubText,
                                      fontSize: 10.8.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isRunning) ...[
                        SizedBox(width: 1.2.w),
                        Shimmer.fromColors(
                          baseColor: AppColors.green,
                          highlightColor: AppColors.green.withOpacity(.42),
                          period: const Duration(milliseconds: 1200),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${provider.deviceSpeed}',
                                  style: TextStyle(
                                    color: AppColors.green,
                                    fontSize: 13.6.sp,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                                TextSpan(
                                  text: ' km/h',
                                  style: TextStyle(
                                    color: AppColors.green,
                                    fontSize: 10.3.sp,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'monospace',
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      SizedBox(width: 5.4.w),
                      Container(
                        constraints: BoxConstraints(maxWidth: 22.w),
                        padding: EdgeInsets.symmetric(
                            horizontal: 1.9.w, vertical: .30.h),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(.14),
                          borderRadius: BorderRadius.circular(999),
                          border:
                              Border.all(color: statusColor.withOpacity(.35)),
                        ),
                        child: Text(
                          displayStatus,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9.8.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 2.5.w),
              RightSideButtons(
                status: provider.status,
                onToggleFollow: provider.toggleFollowVehicle,
                onToggleMap: provider.toggleMapType,
                onResetNorth: onResetNorth,
                onToggleRuler: provider.toggleRulerMode,
                onLocateUser: onLocateUser,
                onLaunch: onOpenDirections,
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
                  final url =
                      'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
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
