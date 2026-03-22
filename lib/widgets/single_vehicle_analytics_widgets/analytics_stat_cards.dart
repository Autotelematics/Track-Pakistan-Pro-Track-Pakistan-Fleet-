import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/single_vehicle_analytics_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class AnalyticsStatCards extends StatelessWidget {
  final SingleVehicleAnalyticsProvider provider;

  const AnalyticsStatCards({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (
        icon: Icons.straighten,
        title: l10n.totalDistance,
        value: provider.totalDistance,
        color: AppColors.blueCyan,
      ),
      (
        icon: Icons.speed,
        title: l10n.maximumSpeed,
        value: provider.maxSpeed,
        color: Colors.red,
      ),
      (
        icon: Icons.access_time,
        title: l10n.driveTime,
        value: provider.driveTime,
        color: AppColors.purple,
      ),
      (
        icon: Icons.pause_circle_outline,
        title: l10n.stopTime,
        value: provider.stopTime,
        color: Colors.orange,
      ),
      (
        icon: Icons.local_gas_station_rounded,
        title: l10n.fuelUsed,
        value: provider.fuelUsed,
        color: AppColors.yellow,
      ),
      (
        icon: Icons.attach_money,
        title: l10n.amountSpent,
        value: provider.amountSpent,
        color: Colors.teal,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: .8.h,
        crossAxisSpacing: 2.2.w,
        childAspectRatio: 2.9,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        return _StatCard(
          icon: item.icon,
          title: item.title,
          value: item.value,
          color: item.color,
        );
      },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? Colors.white.withValues(alpha: .06) : AppColors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final primaryText = isDark ? AppColors.white : AppColors.textBlack;
    final secondaryText = isDark ? Colors.white70 : Colors.grey.shade600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: .7.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .18 : .07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 9.0.w,
            height: 4.3.h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(9.sp),
            ),
            child: Icon(icon, color: color, size: 17.sp),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.0.w, vertical: .2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 11.4.sp,
                      color: secondaryText,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                  verticalSpace(height: 0.15.h),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 13.2.sp,
                      color: primaryText,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
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
