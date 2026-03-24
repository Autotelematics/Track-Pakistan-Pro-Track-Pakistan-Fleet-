import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class SingleVehicleDateFilterBar extends StatelessWidget {
  final List<String> filterLabels;
  final int selectedFilterIndex;
  final bool showDateRangePicker;
  final String rangeText;
  final ValueChanged<int> onFilterTap;
  final VoidCallback onDateRangeTap;

  const SingleVehicleDateFilterBar({
    super.key,
    required this.filterLabels,
    required this.selectedFilterIndex,
    required this.showDateRangePicker,
    required this.rangeText,
    required this.onFilterTap,
    required this.onDateRangeTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const reportAccent = Color(0xFFE0A800);

    return Column(
      children: [
        Row(
          children: List.generate(filterLabels.length, (i) {
            final selected = selectedFilterIndex == i;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: i == filterLabels.length - 1 ? 0 : 1.2.w),
                child: InkWell(
                  borderRadius: BorderRadius.circular(9),
                  onTap: () => onFilterTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: .9.h),
                    decoration: BoxDecoration(
                      color: selected
                          ? reportAccent.withValues(alpha: .22)
                          : (isDark
                              ? Colors.white.withValues(alpha: .06)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: selected
                            ? reportAccent.withValues(alpha: .62)
                            : (isDark ? Colors.white12 : Colors.black12),
                      ),
                    ),
                    child: Text(
                      filterLabels[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppStyles.semiboldTextStyle(context).copyWith(
                        fontSize: 10.9.sp,
                        color: selected
                            ? reportAccent
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        verticalSpace(height: 1.h),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onDateRangeTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.15.h),
            decoration: BoxDecoration(
              color:
                  isDark ? Colors.white.withValues(alpha: .06) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: isDark ? Colors.white12 : Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? .16 : .06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded,
                    size: 17.sp, color: ConstantColor.primaryColor),
                horizontalSpace(width: 1.8.w),
                Expanded(
                  child: Text(
                    rangeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 12.2.sp,
                      color: isDark ? AppColors.white : AppColors.textBlack,
                    ),
                  ),
                ),
                Icon(
                  showDateRangePicker
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SingleVehicleDateRangePickerCard extends StatelessWidget {
  final String fromDateTitle;
  final String toDateTitle;
  final String fromTimeTitle;
  final String toTimeTitle;
  final String selectDateLabel;
  final String selectTimeLabel;
  final String applyLabel;
  final String fromDateValue;
  final String toDateValue;
  final String fromTimeValue;
  final String toTimeValue;
  final VoidCallback onFromDateTap;
  final VoidCallback onToDateTap;
  final VoidCallback onFromTimeTap;
  final VoidCallback onToTimeTap;
  final VoidCallback onApply;

  const SingleVehicleDateRangePickerCard({
    super.key,
    required this.fromDateTitle,
    required this.toDateTitle,
    required this.fromTimeTitle,
    required this.toTimeTitle,
    required this.selectDateLabel,
    required this.selectTimeLabel,
    required this.applyLabel,
    required this.fromDateValue,
    required this.toDateValue,
    required this.fromTimeValue,
    required this.toTimeValue,
    required this.onFromDateTap,
    required this.onToDateTap,
    required this.onFromTimeTap,
    required this.onToTimeTap,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
                  title: fromDateTitle,
                  value: fromDateValue,
                  emptyValue: selectDateLabel,
                  icon: Icons.event,
                  onTap: onFromDateTap,
                ),
              ),
              horizontalSpace(width: 2.w),
              Expanded(
                child: _RangePickerTile(
                  title: toDateTitle,
                  value: toDateValue,
                  emptyValue: selectDateLabel,
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
                  title: fromTimeTitle,
                  value: fromTimeValue,
                  emptyValue: selectTimeLabel,
                  icon: Icons.access_time,
                  onTap: onFromTimeTap,
                ),
              ),
              horizontalSpace(width: 2.w),
              Expanded(
                child: _RangePickerTile(
                  title: toTimeTitle,
                  value: toTimeValue,
                  emptyValue: selectTimeLabel,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstantColor.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onApply,
              child: Text(applyLabel),
            ),
          ),
        ],
      ),
    );
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
              color: ConstantColor.primaryColor.withValues(alpha: .25)),
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
