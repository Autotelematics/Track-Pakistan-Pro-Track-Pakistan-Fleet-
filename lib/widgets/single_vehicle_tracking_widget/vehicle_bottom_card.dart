import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
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

  const VehicleBottomCard({
    super.key,
    required this.deviceName,
    required this.totalDistance,
    required this.vehicleOdometer,
    required this.deviceSpeed,
    required this.deviceAddress,
    required this.deviceLatestUpdate,
    this.sensors,
    required this.deviceId,
  });

  @override
  State<VehicleBottomCard> createState() => _VehicleBottomCardState();
}

class _VehicleBottomCardState extends State<VehicleBottomCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? theme.cardColor : AppColors.white;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.6)
        : AppColors.grey.withOpacity(0.4);
    final borderColor =
        isDark ? AppColors.grey.withOpacity(0.3) : AppColors.grey;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 100.w,
        padding: EdgeInsets.fromLTRB(4.w, 0.0.h, 4.w, 1.8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cardBg,
              isDark
                  ? Colors.grey.shade900.withOpacity(.96)
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VehicleBasicInfo(
              deviceName: widget.deviceName,
              deviceSpeed: widget.deviceSpeed,
              deviceAddress: widget.deviceAddress,
              deviceLatestUpdate: widget.deviceLatestUpdate,
              sensors: widget.sensors,
              fallbackOdometer: widget.vehicleOdometer,
            ),
            Divider(
              height: 1,
              thickness: .8,
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
            verticalSpace(height: 1.0.h),
            BottomActions(
              deviceId: widget.deviceId,
            ),
            verticalSpace(height: 0.5.h),
          ],
        ),
      ),
    );
  }
}
