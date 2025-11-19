import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/dashboard_data.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/providers/motion_bottom_bar_provider.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'vehicle_summary_card.dart';

class HeaderWidget extends StatelessWidget {
  final DashboardData data;
  final GetDashboardModel data1;
  final String currentTime;

  const HeaderWidget({
    super.key,
    required this.data,
    required this.currentTime,
    required this.data1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 42.h,
      width: 100.w,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            height: 34.h,
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surface : null,
              gradient: isDark ? null : AppColors.mainGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(38),
                bottomRight: Radius.circular(38),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.4)
                      : Colors.black.withOpacity(0.12),
                  offset: const Offset(0, 4),
                  blurRadius: isDark ? 16 : 20,
                ),
              ],
            ),
            child: Column(
              children: [
                verticalSpace(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 3.h,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(Icons.account_circle,
                          size: 6.h, color: Colors.white),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context
                              .read<MotionBottomBarProvider>()
                              .setIndex(4),
                          child: Icon(Icons.settings,
                              size: 3.h, color: Colors.white),
                        ),
                        SizedBox(width: 5.w),
                        GestureDetector(
                          onTap: () => context
                              .read<MotionBottomBarProvider>()
                              .setIndex(3),
                          child: Icon(Icons.notifications,
                              size: 3.h, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                verticalSpace(height: 1.2.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 1.w),
                    child: Text(
                      currentTime,
                      style: AppStyles.regularTextStyle(context).copyWith(
                        fontSize: 18.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Overlapping Vehicle Summary Card
          Positioned(
            top: 18.h,
            left: 5.w,
            right: 5.w,
            child: VehicleSummaryCard(data1: data1),
          ),
        ],
      ),
    );
  }
}
