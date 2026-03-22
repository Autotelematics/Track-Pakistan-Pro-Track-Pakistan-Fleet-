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
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  const SettingsMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.cardColor,
    required this.onSurface,
    required this.onTap,
    this.switchValue,
    this.onSwitchChanged,
  });

  @override
  State<SettingsMenuTile> createState() => _SettingsMenuTileState();
}

class _SettingsMenuTileState extends State<SettingsMenuTile> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileTextColor = widget.onSurface;
    final iconTint = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.06);

    return AnimatedContainer(
      width: MediaQuery.sizeOf(context).width,
      margin: EdgeInsets.only(bottom: 1.15.h),
      padding: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: .15.h),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(16.px),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 400),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 9.5.w,
          height: 9.5.w,
          decoration: BoxDecoration(
            color: iconTint,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(widget.icon, color: tileTextColor, size: 19.sp),
        ),
        title: Text(widget.title,
            style: AppStyles.regularTextStyle(context).copyWith(
                color: tileTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 14.6.sp)),
        trailing: widget.switchValue != null && widget.onSwitchChanged != null
            ? Transform.scale(
                scale: .9,
                child: Switch(
                  value: widget.switchValue ?? false,
                  activeThumbColor: ConstantColor.primaryColor,
                  activeTrackColor:
                      ConstantColor.primaryColor.withValues(alpha: .45),
                  onChanged: widget.onSwitchChanged,
                ),
              )
            : Container(
                width: 7.4.w,
                height: 7.4.w,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.black,
                ),
              ),
        onTap: () {
          widget.onTap();
        },
      ),
    );
  }
}
