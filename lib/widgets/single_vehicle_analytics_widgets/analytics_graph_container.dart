import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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
    return Container(
      height: 28.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.semiboldTextStyle(context)
                .copyWith(fontSize: 16.sp),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, color: Colors.grey.shade300, size: 30.sp),
          SizedBox(height: 1.h),
          Text(
            "No data available",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}