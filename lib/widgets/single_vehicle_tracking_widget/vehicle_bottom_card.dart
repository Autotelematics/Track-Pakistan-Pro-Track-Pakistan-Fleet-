  import 'package:flutter/material.dart';
  import 'package:responsive_sizer/responsive_sizer.dart';
  import 'package:trackerapp/app/theme/app_colors.dart';
  import 'package:trackerapp/data/models/get_device_list_model.dart';
  import 'package:trackerapp/widgets/get_vertical_space.dart';
  import 'common_small_widgets.dart';

  class VehicleBottomCard extends StatelessWidget {
    final String deviceName;
    final String deviceId;
    final String totalDistance;
    final int deviceSpeed;
    final String vehicleStatusText;
    final String deviceAddress;
    final String deviceLatestUpdate;
    final List<Sensor>? sensors;

    const VehicleBottomCard({
      super.key,
      required this.deviceName,
      required this.totalDistance,
      required this.deviceSpeed,
      required this.vehicleStatusText,
      required this.deviceAddress,
      required this.deviceLatestUpdate,
      this.sensors, required this.deviceId,
    });

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
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            border: Border.all(color: borderColor, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              VehicleBasicInfo(
                deviceName: deviceName,
                deviceSpeed: deviceSpeed, deviceAddress: deviceAddress, deviceLatestUpdate: deviceLatestUpdate,
              ),
              verticalSpace(height: 2.h),
               BottomActions(deviceId: deviceId,),

              verticalSpace(height: 2.h),
            ],
          ),
        ),
      );
    }
  }
