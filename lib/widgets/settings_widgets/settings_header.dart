import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        verticalSpace(height: 7.h),
        Container(
          height: 10.h,
          width: 10.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 3, color: AppColors.white),
            image: const DecorationImage(
              image: NetworkImage(
                "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=60&w=500",
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        verticalSpace(height: 1.h),
        Text(
          'User ID',
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: 18.sp,
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'useremail@gmail.com',
          style: AppStyles.lightTextStyle(context).copyWith(
            color: AppColors.white.withOpacity(0.8),
            fontSize: 15.sp,
          ),
        ),
        verticalSpace(height: 1.h),
      ],
    );
  }
}
