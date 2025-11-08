import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/view/contact_us_screen.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
class AddressFooter extends StatelessWidget {
  const AddressFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Divider(color: isDark ? Colors.white24 : Colors.grey[300], height: 2.h),
        Text(
          "Office Address",
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.grey[700]),
        ),
        verticalSpace(height: 1.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            ContactScreen.companyAddress,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, height: 1.4, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
        verticalSpace(height: 4.h),
      ],
    );
  }
}