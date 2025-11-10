// widgets/header_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/dashboard_data.dart';
import 'package:trackerapp/view/settings.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'vehicle_summary_card.dart';

class HeaderWidget extends StatelessWidget {
  final DashboardData data;

  const HeaderWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 44.h,
      width: 100.w,
      child: Stack(
        children: [
          _header(context, isDark),
          Positioned(
            top: 20.h,
            left: 5.w,
            right: 5.w,
            child: VehicleSummaryCard(data: data),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      height: 38.h,
      decoration: BoxDecoration(
        color: isDark ? surface : null, // Solid in dark
        gradient: isDark
            ? null
            :AppColors.mainGradient,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(38),
          bottomLeft: Radius.circular(38),
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
              // Profile Avatar
              CircleAvatar(
                radius: 3.h,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    imageUrl:
                    "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.0.3",
                    fit: BoxFit.cover,
                    height: 7.h,
                    width: 7.h,
                    placeholder: (_, __) => const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.error,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Settings + Notification
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ModernSettingsScreen(),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.settings,
                      size: 3.h,
                      color: Colors.white,
                    ),
                  ),
                  horizontalSpace(width: 5.w),
                  Icon(
                    Icons.notifications,
                    size: 3.h,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),

          // Greeting
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Good Afternoon",
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              "Alex Bahadur Nepali",
              style: AppStyles.boldTextStyle(context).copyWith(
                color: Colors.white,
                fontSize: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}