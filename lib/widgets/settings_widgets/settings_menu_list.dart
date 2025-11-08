import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';

class SettingsMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color cardColor;
  final Color onSurface;
  final VoidCallback onTap;

  const SettingsMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.cardColor,
    required this.onSurface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: MediaQuery.sizeOf(context).width,
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10.px),
      ),
      duration: const Duration(milliseconds: 400),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color:title=="LogOut"?AppColors.red: onSurface),
        title: Text(
          title,
          style:AppStyles.regularTextStyle(context).copyWith(
            color: title=="LogOut"?AppColors.red:onSurface
          )
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
        onTap: () {
          onTap();
        },
      ),
    );
  }
}
