import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/providers/motion_bottom_bar_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
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
    final l10n = context.l10n;
    final hiText = userEmail.isNotEmpty ? l10n.hiUser(userEmail) : l10n.hi;
    final settingsIconColor =
        isDark ? const Color(0xFF93C5FD) : const Color(0xFF60A5FA);
    final alertIconColor =
        isDark ? const Color(0xFFFCA5A5) : const Color(0xFFF87171);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100.w,
          padding: EdgeInsets.symmetric(horizontal: 6.w),
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
            child: Padding(
              padding: EdgeInsets.only(top: .8.h, bottom: 1.5.h),
              child: Column(
                children: [
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
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 52.w),
                            child: Text(
                              hiText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppStyles.regularTextStyle(context).copyWith(
                                fontSize: 14.sp,
                                color: foregroundColor,
                                fontWeight: FontWeight.w700,
                              ),
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
                            tooltip: l10n.settingsTooltip,
                            icon: Icon(
                              Icons.settings,
                              size: (3 * iconScale).h,
                              color: settingsIconColor,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          IconButton(
                            onPressed: () => context
                                .read<MotionBottomBarProvider>()
                                .setIndex(3),
                            tooltip: l10n.notificationsTooltip,
                            icon: Icon(
                              Icons.notifications,
                              size: (3 * iconScale).h,
                              color: alertIconColor,
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
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 0),
          child: VehicleSummaryCard(data1: data1),
        ),
        verticalSpace(height: .9.h),
      ],
    );
  }
}
