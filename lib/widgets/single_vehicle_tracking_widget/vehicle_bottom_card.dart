import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart'
    as device_list;
import 'package:trackerapp/data/models/get_device_live_tracking_model.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

import 'common_small_widgets.dart';

class VehicleBottomCard extends StatefulWidget {
  final String deviceName;
  final String deviceId;
  final String totalDistance;
  final double vehicleOdometer;
  final int deviceSpeed;
  final String deviceAddress;
  final String deviceLatestUpdate;
  final List<Sensor>? sensors;
  final device_list.Param? param;
  final bool isExpired;
  final int? lastStatusTimestamp;
  final int? lastAckTimestamp;
  final String? stopDuration;

  const VehicleBottomCard({
    super.key,
    required this.deviceName,
    required this.totalDistance,
    required this.vehicleOdometer,
    required this.deviceSpeed,
    required this.deviceAddress,
    required this.deviceLatestUpdate,
    this.sensors,
    this.param,
    required this.deviceId,
    this.isExpired = false,
    this.lastStatusTimestamp,
    this.lastAckTimestamp,
    this.stopDuration,
  });

  @override
  State<VehicleBottomCard> createState() => _VehicleBottomCardState();
}

class _VehicleBottomCardState extends State<VehicleBottomCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final isUltraWideLandscape =
        mediaQuery.size.width > mediaQuery.size.height &&
            mediaQuery.size.width >= 1900;
    final isTallPortrait = mediaQuery.size.height > mediaQuery.size.width &&
        mediaQuery.size.height >= 820;
    final isVeryTallPortrait = isTallPortrait &&
        (mediaQuery.size.height / mediaQuery.size.width) >= 2.0;
    final contentScale = isUltraWideLandscape
        ? 1.12
        : (isVeryTallPortrait ? 1.30 : (isTallPortrait ? 1.16 : 1.0));
    final bottomPadding = isUltraWideLandscape
        ? 2.4.h
        : (isVeryTallPortrait ? 2.8.h : (isTallPortrait ? 2.2.h : 1.8.h));
    final systemBottomInset = mediaQuery.viewPadding.bottom;
    final safeBottomInset = defaultTargetPlatform == TargetPlatform.iOS
        ? systemBottomInset.clamp(0.0, 12.0)
        : (systemBottomInset > 0 ? systemBottomInset : 0.0);
    final horizontalPadding =
        isUltraWideLandscape ? 4.6.w : (isTallPortrait ? 4.4.w : 4.w);
    final topPadding = isVeryTallPortrait ? 0.9.h : 0.0.h;

    final cardBg = isDark ? theme.cardColor : AppColors.white;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.6)
        : AppColors.grey.withValues(alpha: 0.4);
    final borderColor =
        isDark ? AppColors.grey.withValues(alpha: 0.3) : AppColors.grey;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 100.w,
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          topPadding,
          horizontalPadding,
          bottomPadding + safeBottomInset,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cardBg,
              isDark
                  ? Colors.grey.shade900.withValues(alpha: .96)
                  : Colors.grey.shade50,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          border: Border.all(color: borderColor, width: 0.65),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 16,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(contentScale),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              VehicleBasicInfo(
                deviceName: widget.deviceName,
                deviceSpeed: widget.deviceSpeed,
                deviceAddress: widget.deviceAddress,
                deviceLatestUpdate: widget.deviceLatestUpdate,
                sensors: widget.sensors,
                param: widget.param,
                fallbackOdometer: widget.vehicleOdometer,
                isExpired: widget.isExpired,
                lastStatusTimestamp: widget.lastStatusTimestamp,
                lastAckTimestamp: widget.lastAckTimestamp,
                stopDuration: widget.stopDuration,
              ),
              Divider(
                height: 1,
                thickness: .8,
                color: isDark ? Colors.white12 : Colors.grey.shade300,
              ),
              verticalSpace(
                height:
                    (isUltraWideLandscape || isTallPortrait) ? 1.25.h : 1.0.h,
              ),
              BottomActions(
                deviceId: widget.deviceId,
              ),
              verticalSpace(
                height:
                    (isUltraWideLandscape || isTallPortrait) ? 0.85.h : 0.5.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
