import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/providers/motion_bottom_bar_provider.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/widgets/dashboard_widgets/dashboard_scale.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

import 'vehicle_summary_card.dart';

class HeaderWidget extends StatelessWidget {
  final GetDashboardModel data1;
  final String currentTime;

  const HeaderWidget({
    super.key,
    required this.currentTime,
    required this.data1,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.90;
    final isCompactSummary = cardWidth < 335;
    final summaryTop = isCompactSummary ? 16.5.h : 18.h;
    final headerHeight = isCompactSummary ? 49.h : 37.h;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foregroundColor = isDark ? theme.colorScheme.onSurface : Colors.white;
    final iconScale = dashboardIconScale(context);
    final savedProfilePath = MySharedPreferences.getString(profileImagePathKey);
    final profileFile = File(savedProfilePath);
    final hasLocalProfileImage =
        savedProfilePath.isNotEmpty && profileFile.existsSync();
    final emailFromApi = data1.userEmail.trim();
    final storedEmail = MySharedPreferences.getString(userEmailKey).trim();
    final userEmail = emailFromApi.isNotEmpty ? emailFromApi : storedEmail;
    final hiText = userEmail.isNotEmpty ? "Hi, $userEmail" : "Hi";

    return SizedBox(
      height: headerHeight,
      width: 100.w,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            height: 32.h,
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
                      ? Colors.black.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.12),
                  offset: const Offset(0, 4),
                  blurRadius: isDark ? 16 : 20,
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  verticalSpace(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6.2.h,
                            height: 6.2.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.65),
                                width: 1.2,
                              ),
                              image: hasLocalProfileImage
                                  ? DecorationImage(
                                      image: FileImage(profileFile),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: hasLocalProfileImage
                                ? null
                                : Icon(
                                    Icons.account_circle,
                                    size: (6 * iconScale).h,
                                    color: foregroundColor,
                                  ),
                          ),
                          SizedBox(width: 2.4.w),
                          Text(
                            hiText,
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 14.sp,
                              color: foregroundColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context
                                .read<MotionBottomBarProvider>()
                                .setIndex(4),
                            tooltip: 'Settings',
                            icon: Icon(
                              Icons.settings,
                              size: (3 * iconScale).h,
                              color: foregroundColor,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          IconButton(
                            onPressed: () => context
                                .read<MotionBottomBarProvider>()
                                .setIndex(3),
                            tooltip: 'Notifications',
                            icon: Icon(
                              Icons.notifications,
                              size: (3 * iconScale).h,
                              color: foregroundColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: .6.w, top: .55.h),
                      child: Text(
                        currentTime,
                        style: AppStyles.regularTextStyle(context).copyWith(
                          fontSize: 14.5.sp,
                          color: foregroundColor.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  verticalSpace(height: 1.3.h),
                ],
              ),
            ),
          ),

          // Overlapping Vehicle Summary Card
          Positioned(
            top: summaryTop,
            left: 5.w,
            right: 5.w,
            child: VehicleSummaryCard(data1: data1),
          ),
        ],
      ),
    );
  }
}
