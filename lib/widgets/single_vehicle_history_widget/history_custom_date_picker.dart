import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class HistoryCustomDateTimePicker extends StatelessWidget {
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final TimeOfDay? customStartTime;
  final TimeOfDay? customEndTime;
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
    required this.onApply,
    required this.onFromDateTap,
    required this.onToDateTap,
    required this.onFromTimeTap,
    required this.onToTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      top: 16.0.h,
      left: 3.w,
      right: 3.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: .06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _RangePickerTile(
                    title: l10n.fromDate,
                    value: _formatDate(customStartDate),
                    emptyValue: l10n.selectDate,
                    icon: Icons.event,
                    onTap: onFromDateTap,
                  ),
                ),
                horizontalSpace(width: 2.w),
                Expanded(
                  child: _RangePickerTile(
                    title: l10n.toDate,
                    value: _formatDate(customEndDate),
                    emptyValue: l10n.selectDate,
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
                    title: l10n.fromTime,
                    value: _formatTime(context, customStartTime),
                    emptyValue: l10n.selectTime,
                    icon: Icons.access_time,
                    onTap: onFromTimeTap,
                  ),
                ),
                horizontalSpace(width: 2.w),
                Expanded(
                  child: _RangePickerTile(
                    title: l10n.toTime,
                    value: _formatTime(context, customEndTime),
                    emptyValue: l10n.selectTime,
                    icon: Icons.timelapse_rounded,
                    onTap: onToTimeTap,
                  ),
                ),
              ],
            ),
            verticalSpace(height: .8.h),
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
                child: Text(l10n.applyRange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '';
    return "${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}";
  }

  String _formatTime(BuildContext context, TimeOfDay? value) {
    if (value == null) return '';
    return value.format(context);
  }
}

class _RangePickerTile extends StatelessWidget {
  final String title;
  final String value;
  final String emptyValue;
  final IconData icon;
  final VoidCallback onTap;

  const _RangePickerTile({
    required this.title,
    required this.value,
    required this.emptyValue,
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
          color: isDark
              ? Colors.white.withValues(alpha: .05)
              : Colors.grey.shade50,
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
                fontSize: 10.8.sp,
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
                    value.isEmpty ? emptyValue : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.semiboldTextStyle(context)
                        .copyWith(fontSize: 11.5.sp),
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
