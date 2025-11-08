import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/view/contact_us_screen.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          ContactScreen.companyName,
          style: AppStyles.appTitleTextStyle,
        ),
        verticalSpace(height: 0.8.h),
        Text(
          "We’re here to help",
          style: AppStyles.regularTextStyle(context),
        ),
        verticalSpace(height: 3.h),
      ],
    );
  }
}