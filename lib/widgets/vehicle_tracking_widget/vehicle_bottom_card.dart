import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'common_small_widgets.dart';

class VehicleBottomCard extends StatelessWidget {
  const VehicleBottomCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic colors
    final cardBg = isDark ? theme.cardColor : AppColors.white;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.6)
        : AppColors.grey.withOpacity(0.4);
    final borderColor = isDark ? AppColors.grey.withOpacity(0.3) : AppColors.grey;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 100.w,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
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
            verticalSpace(height: 2.h),

            // Already dynamic from previous file
            const VehicleBasicInfo(),
            verticalSpace(height: 2.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfoTile(
                  icon: Icons.gps_fixed,
                  value: "10.8 km",
                  label: "Distance with You",
                ),
                InfoTile(
                  icon: Icons.speed,
                  value: "100 km/h",
                  label: "Average Speed",
                ),
                InfoTile(
                  icon: Icons.thermostat,
                  value: "20° C",
                  label: "Temperature",
                ),
              ],
            ),

            verticalSpace(height: 3.h),
            const BottomActions(),
            verticalSpace(height: 4.h),
          ],
        ),
      ),
    );
  }
}