import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/dashboard_data.dart';
import 'package:trackerapp/view/settings.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_verticle_space.dart';
import 'vehicle_summary_card.dart';

class HeaderWidget extends StatelessWidget {
  final DashboardData data;

  const HeaderWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      width: 100.w,
      child: Stack(
        children: [
          _header(context),
          Positioned(
            top: 24.h,
            left: 5.w,
            right: 5.w,
            child: VehicleSummaryCard(data: data),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 6.w),
    height: 38.h,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.purple, AppColors.blueCyanWithOpacity],
      ),
      borderRadius: const BorderRadius.only(
        bottomRight: Radius.circular(38),
        bottomLeft: Radius.circular(38),
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          offset: Offset(0, 4),
          blurRadius: 20,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl:
                  "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.0.3",
                  fit: BoxFit.cover,
                  height: 7.h,
                  width: 7.h,
                  placeholder: (context, url) =>
                  const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
                ),
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingScreen(),
                      ),
                    );
                  },
                  child: Icon(Icons.settings, size: 3.h, color: Colors.white),
                ),
                horizontalSpace(width: 5.w),
                Icon(Icons.notifications, size: 3.h, color: Colors.white),
              ],
            ),
          ],
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            "Good Afternoon",
            style: AppStyles.regularTextStyle(context)
                .copyWith(fontSize: 16.sp, color: Colors.white),
          ),
          subtitle: Text(
            "Alex Bahadur Nepali",
            style: AppStyles.boldTextStyle(context)
                .copyWith(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}