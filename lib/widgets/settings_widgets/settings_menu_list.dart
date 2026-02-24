import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/white_labeling/colors.dart';

class SettingsMenuTile extends StatefulWidget {
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
  State<SettingsMenuTile> createState() => _SettingsMenuTileState();
}

class _SettingsMenuTileState extends State<SettingsMenuTile> {
  bool? value = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: MediaQuery.sizeOf(context).width,
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(10.px),
      ),
      duration: const Duration(milliseconds: 400),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(widget.icon,
            color: widget.title == "LogOut" ? AppColors.red : widget.onSurface),
        title: Text(widget.title,
            style: AppStyles.regularTextStyle(context).copyWith(
                color: widget.title == "LogOut"
                    ? AppColors.red
                    : widget.onSurface)),
        trailing: widget.title == "Play Alerts Announcement"
            ? Container(
                width: 12.w,
                padding: EdgeInsets.only(left: 6.w),
                child: Checkbox(
                  value: value,
                  activeColor: ConstantColor.primaryColor,
                  side: BorderSide(color: AppColors.grey, width: 2),
                  onChanged: (bool? newValue) {
                    setState(() {
                      value = newValue;
                    });
                  },
                ),
              )
            : Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
        onTap: () {
          widget.onTap();
        },
      ),
    );
  }
}
