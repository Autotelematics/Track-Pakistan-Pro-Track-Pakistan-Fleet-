import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class HistoryCustomDateTimePicker extends StatelessWidget {
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final TimeOfDay? customStartTime;
  final TimeOfDay? customEndTime;
  final VoidCallback onClose;
  final VoidCallback onApply;
  final VoidCallback onFromDateTap;
  final VoidCallback onToDateTap;
  final VoidCallback onFromTimeTap;
  final VoidCallback onToTimeTap;

  const HistoryCustomDateTimePicker({
    super.key,
    required this.customStartDate,
    required this.customEndDate,
    required this.customStartTime,
    required this.customEndTime,
    required this.onClose,
    required this.onApply,
    required this.onFromDateTap,
    required this.onToDateTap,
    required this.onFromTimeTap,
    required this.onToTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      top: 16.0.h,
      left: 3.w,
      right: 3.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2433) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _RangePickerTile(
                    title: 'From Date',
                    value: _formatDate(customStartDate),
                    icon: Icons.event,
                    onTap: onFromDateTap,
                  ),
                ),
                horizontalSpace(width: 2.w),
                Expanded(
                  child: _RangePickerTile(
                    title: 'To Date',
                    value: _formatDate(customEndDate),
                    icon: Icons.event_available,
                    onTap: onToDateTap,
                  ),
                ),
              ],
            ),
            verticalSpace(height: .8.h),
            Row(
              children: [
                Expanded(
                  child: _RangePickerTile(
                    title: 'From Time',
                    value: _formatTime(context, customStartTime),
                    icon: Icons.access_time,
                    onTap: onFromTimeTap,
                  ),
                ),
                horizontalSpace(width: 3.w),
                Expanded(
                  child: _RangePickerTile(
                    title: 'To Time',
                    value: _formatTime(context, customEndTime),
                    icon: Icons.timelapse_rounded,
                    onTap: onToTimeTap,
                  ),
                ),
              ],
            ),
            verticalSpace(height: .4.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ConstantColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Apply Range',
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    color: Colors.white,
                    fontSize: 12.3.sp,
                  ),
                ),
              ),
            ),
            verticalSpace(height: .0.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onClose,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: .0.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12.8.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Select Date';
    return "${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}";
  }

  String _formatTime(BuildContext context, TimeOfDay? value) {
    if (value == null) return 'Select Time';
    return value.format(context);
  }
}

class _RangePickerTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _RangePickerTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: .75.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ConstantColor.primaryColor.withValues(alpha: .25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 12.8.sp,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
            verticalSpace(height: .2.h),
            Row(
              children: [
                Icon(icon, size: 14.sp, color: ConstantColor.primaryColor),
                horizontalSpace(width: 1.2.w),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.semiboldTextStyle(context)
                        .copyWith(fontSize: 12.5.sp),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
