import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/dashboard_data.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_verticle_space.dart';
class MaintenanceCard extends StatelessWidget {
  final DashboardData data;

  const MaintenanceCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 6.w),
      margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Maintenance Reminder",
            style: AppStyles.boldTextStyle(context)
                .copyWith(fontSize: 17.sp, fontWeight: FontWeight.w800),
          ),
          verticalSpace(height: 1.h),
          _maintenanceRow(context, "Due", Colors.orange, data.maintenanceDue),
          verticalSpace(height: 1.h),
          Divider(color: onSurface.withOpacity(0.2)),
          verticalSpace(height: 1.h),
          _maintenanceRow(context, "Overdue", Colors.red, data.maintenanceOverdue),
        ],
      ),
    );
  }

  Widget _maintenanceRow(
      BuildContext context, String title, Color iconColor, String count) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Icon(Icons.calendar_month, color: iconColor, size: 20.sp),
        horizontalSpace(width: 3.w),
        Expanded(
          child: Text(
            title,
            style: AppStyles.regularTextStyle(context)
                .copyWith(fontWeight: FontWeight.w700, fontSize: 15.sp),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 1.h, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            count,
            style: AppStyles.regularTextStyle(context)
                .copyWith(fontWeight: FontWeight.w700, fontSize: 14.sp),
          ),
        ),
        horizontalSpace(width: 1.h),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18.sp,
          color: onSurface.withOpacity(0.5),
        ),
      ],
    );
  }
}