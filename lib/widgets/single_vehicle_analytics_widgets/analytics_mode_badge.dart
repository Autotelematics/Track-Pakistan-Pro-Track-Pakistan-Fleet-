import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';

class AnalyticsModeBadge extends StatelessWidget {
  final bool isMultiDay;

  const AnalyticsModeBadge({super.key, required this.isMultiDay});

  @override
  Widget build(BuildContext context) {
    final color = isMultiDay ? AppColors.purple : AppColors.blueCyan;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.sp),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMultiDay ? Icons.calendar_month : Icons.access_time,
            size: 16.sp,
            color: color,
          ),
          horizontalSpace(width: 1.5.w),
          Text(
            isMultiDay ? "Charts grouped by date" : "Charts grouped by hour",
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 13.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}