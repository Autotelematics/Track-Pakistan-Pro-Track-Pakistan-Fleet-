import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/single_vehicle_analytics_provider.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class AnalyticsStatCards extends StatelessWidget {
  final SingleVehicleAnalyticsProvider provider;

  const AnalyticsStatCards({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatCard(
          icon: Icons.straighten,
          title: "Total Distance",
          value: provider.totalDistance,
          color: AppColors.blueCyan,
        ),
        verticalSpace(height: 1.5.h),
        _StatCard(
          icon: Icons.speed,
          title: "Maximum Speed",
          value: provider.maxSpeed,
          color: Colors.red,
        ),
        verticalSpace(height: 1.5.h),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.access_time,
                title: "Drive Time",
                value: provider.driveTime,
                color: AppColors.purple,
              ),
            ),
            horizontalSpace(width: 3.w),
            Expanded(
              child: _StatCard(
                icon: Icons.pause_circle_outline,
                title: "Stop Time",
                value: provider.stopTime,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        verticalSpace(height: 1.5.h),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.local_gas_station_rounded,
                title: "Fuel Used",
                value: provider.fuelUsed,
                color: AppColors.yellow,
              ),
            ),
            horizontalSpace(width: 3.w),
            Expanded(
              child: _StatCard(
                icon: Icons.attach_money,
                title: "Amount Spent",
                value: provider.amountSpent,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.sp),
                bottomLeft: Radius.circular(10.sp),
              ),
            ),
            child: Icon(icon, color: AppColors.white, size: 24.sp),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  verticalSpace(height: 0.5.h),
                  Text(
                    value,
                    style: AppStyles.semiboldTextStyle(context)
                        .copyWith(fontSize: 15.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}