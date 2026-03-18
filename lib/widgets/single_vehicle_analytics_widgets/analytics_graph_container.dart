import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class AnalyticsGraphContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isEmpty;

  const AnalyticsGraphContainer({
    super.key,
    required this.title,
    required this.child,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? Colors.white.withValues(alpha: .06) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final titleColor = isDark ? AppColors.white : AppColors.textBlack;
    final subtitleColor =
        isDark ? Colors.white70 : AppColors.textBlack.withValues(alpha: .55);

    return Container(
      height: 28.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .18 : 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 1.2.w,
                height: 2.2.h,
                decoration: BoxDecoration(
                  color: AppColors.blueCyan,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 15.5.sp,
                    color: titleColor,
                  ),
                ),
              ),
              if (isEmpty)
                Text(
                  "No data",
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: 12.sp,
                    color: subtitleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          verticalSpace(height: 1.h),
          Expanded(
            child: isEmpty ? _EmptyChart() : child,
          ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
            size: 30.sp,
          ),
          SizedBox(height: 1.h),
          Text(
            "No data available",
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey.shade400,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
