import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class MaintenanceCard extends StatelessWidget {
  final GetDashboardModel data;

  const MaintenanceCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Ignore items where current = 0
    final valid = data.maintenance.where((m) => m.current != 0).toList();

    // All Maintenance Count
    final allCount = valid.length.toString();
    // Due = percent == 100 OR percent > 100
    final due = valid.where((m) => m.percent < 100).toList();
    final dueCount = due.length.toString();
    // Overdue = percent > 100 OR status == "expired"
    final overdue =
    valid.where((m) =>m.percent==100|| m.percent > 100).toList();
    final overdueCount = overdue.length.toString();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 3.w),
      margin: EdgeInsets.symmetric(horizontal: 6.w),
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
          Row(
            children: [
              Text(
                "Maintenance Reminder",
                style: AppStyles.semiboldTextStyle(context),
              ),

            ],
          ),

          verticalSpace(height: 2.h),

          /// ALL
          _maintenanceRow(
            context,
            title: "All",
            iconColor: Colors.blue,
            count: allCount,
          ),
          verticalSpace(height: 1.5.h),

          Divider(color: onSurface.withOpacity(0.2)),
          verticalSpace(height: 1.5.h),

          /// DUE
          _maintenanceRow(
            context,
            title: "Due",
            iconColor: Colors.orange,
            count: dueCount,
          ),
          verticalSpace(height: 1.5.h),

          Divider(color: onSurface.withOpacity(0.2)),
          verticalSpace(height: 1.5.h),

          /// OVERDUE
          _maintenanceRow(
            context,
            title: "Overdue",
            iconColor: Colors.red,
            count: overdueCount,
          ),
        ],
      ),
    );
  }

  Widget _maintenanceRow(
      BuildContext context, {
        required String title,
        required Color iconColor,
        required String count,
      }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Icon(title=="All"?Icons.build_circle:Icons.calendar_month, color: iconColor, size: 20.sp),
        horizontalSpace(width: 3.w),

        Expanded(
          child: Text(
            title,
            style: AppStyles.regularTextStyle(context).copyWith(fontSize: 15.sp),
          ),
        ),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 1.2.h, vertical: 0.6.h),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
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
