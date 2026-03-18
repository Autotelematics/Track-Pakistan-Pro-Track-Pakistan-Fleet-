import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/white_labeling/contacts.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final String name = CompanyInfo.companyName.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          name,
          textAlign: TextAlign.center,
          style: AppStyles.appTitleTextStyle.copyWith(
            color: onSurface,
            fontSize: 21.sp,
          ),
        ),
        verticalSpace(height: 0.8.h),
        Text(
          "We’re here to help",
          style: AppStyles.regularTextStyle(context).copyWith(
            color: onSurface.withValues(alpha: 0.72),
            fontSize: 14.sp,
          ),
        ),
        verticalSpace(height: 2.2.h),
      ],
    );
  }
}
