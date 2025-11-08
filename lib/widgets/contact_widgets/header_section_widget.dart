import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';

class HeaderSection extends StatelessWidget {
  final bool isDark;
  const HeaderSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 5.w, right: 5.w, bottom: 2.h),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Spacer(),
            Text(
              "Contact Us",
              style: AppStyles.boldTextStyle(context).copyWith(
                color: AppColors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            horizontalSpace(width: 10.w),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}