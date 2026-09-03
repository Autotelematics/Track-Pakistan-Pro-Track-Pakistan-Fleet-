import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/providers/vehicle_tracking_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/single_vehicle_tracking_widget/right_side_buttons.dart';
import 'package:trackerapp/widgets/single_vehicle_tracking_widget/tracking_scale.dart';

class TopBar extends StatelessWidget {
  final String status;
  final bool isExpired;
  final VoidCallback? onResetNorth;
  final VoidCallback? onLocateUser;
  final VoidCallback? onOpenDirections;
  const TopBar({
    super.key,
    required this.status,
    this.isExpired = false,
    this.onResetNorth,
    this.onLocateUser,
    this.onOpenDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleTrackingProvider>(
      builder: (context, provider, child) {
        final topOffset = (MediaQuery.sizeOf(context).height * 0.0055)
            .clamp(4.0, 7.0)
            .toDouble();
        final l10n = context.l10n;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final panelBase = isDark ? const Color(0xFF1B1D24) : AppColors.white;
        final panelText = isDark ? AppColors.white : AppColors.textBlack;
        final panelSubText = isDark ? Colors.white70 : Colors.black54;
        final textScale = trackingTextScale(context);
        final width = MediaQuery.sizeOf(context).width;
        final liveTitleScale = width >= 430 ? textScale * 0.92 : textScale;
        final blocked = provider.param?.blocked?.trim().toLowerCase() ?? '';
        final out1 = provider.param?.out1?.trim().toLowerCase() ?? '';
        final isEngineKilled =
            blocked.isNotEmpty ? blocked == 'true' : out1 == 'true';
        final lastUpdateText = provider.lastUpdate.trim().isEmpty
            ? l10n.notAvailableShort
            : provider.lastUpdate;
        final String displayStatus = provider.vehicleStatusText;
        final statusColor = provider.ignitionColor;
        final isRunning = provider.status == 'online';
        final isNoData = lastUpdateText.toLowerCase() == 'not connected';

        String statusLabel = "";
        final s = provider.status;
        if (s == 'online') {
          statusLabel = "running";
        } else if (s == 'ack') {
          statusLabel = "stop";
        } else if (s == 'engine') {
          statusLabel = "idle";
        } else {
          statusLabel = "offline";
        }

        final durationText = provider.item?.activityMetric?.value ?? provider.item?.stopDuration ?? "";
        final formattedDuration = durationText.replaceAll('min', 'm');

        return Positioned(
          top: topOffset,
          left: 3.w,
          right: 3.w,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: BoxConstraints(minHeight: 4.6.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.8.w,
                        vertical: .7.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            panelBase.withValues(alpha: .98),
                            isDark
                                ? const Color(0xFF252933).withValues(alpha: .98)
                                : const Color(0xFFF7F9FC)
                                    .withValues(alpha: .98),
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
                            color: Colors.black
                                .withValues(alpha: isDark ? .28 : .12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 2.7.h,
                                      height: 2.7.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.green
                                            .withValues(alpha: .12),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            l10n.liveTracking,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: panelText,
                                              fontSize:
                                                  (13.6 * liveTitleScale).sp,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: .2,
                                            ),
                                          ),
                                          if (isExpired || isNoData)
                                            Text(
                                              "${l10n.status}: ${isExpired ? l10n.vehicleStatusExpired : l10n.vehicleStatusNoData}",
                                              style: TextStyle(
                                                color: isExpired ? Colors.purple : AppColors.red,
                                                fontSize: (11.0 * textScale).sp,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            )
                                          else ...[
                                            Text(
                                              l10n.updatedAt(lastUpdateText),
                                              maxLines: 2,
                                              overflow: TextOverflow.fade,
                                              style: TextStyle(
                                                color: panelSubText,
                                                fontSize: (10.8 * textScale).sp,
                                                fontWeight: FontWeight.w500,
                                                height: 1.15,
                                              ),
                                            ),
                                            if (formattedDuration.isNotEmpty)
                                              Padding(
                                                padding: EdgeInsets.only(top: .15.h),
                                                child: Text(
                                                  "${l10n.status}: $statusLabel ($formattedDuration)",
                                                  style: TextStyle(
                                                    color: isRunning
                                                        ? AppColors.green
                                                        : (statusLabel == 'idle'
                                                            ? Colors.orange
                                                            : (statusLabel == 'stop'
                                                                ? AppColors.red
                                                                : panelSubText)),
                                                    fontSize: (11.0 * textScale).sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                          ],
                                          SizedBox(height: .2.h),
                                          Row(
                                            children: [
                                              if (provider.enableTraffic) ...[
                                                SizedBox(width: 1.5.w),
                                                Container(
                                                  width: .6.h,
                                                  height: .6.h,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.orange,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                SizedBox(width: .9.w),
                                                Flexible(
                                                  child: Text(
                                                    l10n.traffic,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: panelSubText,
                                                      fontSize:
                                                          (12.0 * textScale).sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 2.2.w),
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 220),
                                      switchInCurve: Curves.easeOut,
                                      switchOutCurve: Curves.easeIn,
                                      child: isRunning
                                          ? Shimmer.fromColors(
                                              key: const ValueKey('speed-slot'),
                                              baseColor: AppColors.green,
                                              highlightColor: AppColors.green
                                                  .withValues(alpha: .42),
                                              period: const Duration(
                                                  milliseconds: 1200),
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          '${provider.deviceSpeed}',
                                                      style: TextStyle(
                                                        color: AppColors.green,
                                                        fontSize:
                                                            (14.8 * textScale)
                                                                .sp,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontFamily: 'monospace',
                                                        fontFeatures: const [
                                                          FontFeature
                                                              .tabularFigures()
                                                        ],
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: ' km/h',
                                                      style: TextStyle(
                                                        color: AppColors.green,
                                                        fontSize:
                                                            (12.2 * textScale)
                                                                .sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontFamily: 'monospace',
                                                        fontFeatures: const [
                                                          FontFeature
                                                              .tabularFigures()
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(
                                              key:
                                                  const ValueKey('status-slot'),
                                              constraints: BoxConstraints(
                                                  maxWidth: 22.w),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 1.9.w,
                                                vertical: .30.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: statusColor.withValues(
                                                    alpha: .14),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                border: Border.all(
                                                  color: statusColor.withValues(
                                                      alpha: .35),
                                                ),
                                              ),
                                              child: Text(
                                                displayStatus,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: statusColor,
                                                  fontSize:
                                                      (11.0 * textScale).sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isEngineKilled) ...[
                      SizedBox(height: .8.h),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.4.w,
                            vertical: .45.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.red.withValues(alpha: .24),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.red,
                                size: 1.55.h,
                              ),
                              SizedBox(width: 1.1.w),
                              Text(
                                l10n.engineKilled,
                                style: TextStyle(
                                  color: AppColors.red,
                                  fontSize: (10.8 * textScale).sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
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
                  SharePlus.instance.share(
                    ShareParams(text: l10n.vehicleLocationShare(url)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
