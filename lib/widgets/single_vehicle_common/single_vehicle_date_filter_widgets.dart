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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const filterAccent = Color(0xFF2563EB);
    const filterAccentSoft = Color(0xFFEFF4FF);
    final darkSurface = const Color(0xFF182235);
    final darkSurfaceAlt = const Color(0xFF111A2B);
    final cardColor = isDark ? darkSurface : AppColors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: .14) : Colors.black12;
    final textColor = isDark ? AppColors.white : AppColors.textBlack;
    final selectedLabel =
        selectedFilterIndex >= 0 && selectedFilterIndex < filterLabels.length
            ? filterLabels[selectedFilterIndex]
            : '';

    return Column(
      children: [
        Container(
          height: 5.8.h,
          padding: EdgeInsets.symmetric(horizontal: 2.5.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? <Color>[
                      cardColor,
                      darkSurfaceAlt,
                    ]
                  : <Color>[
                      Colors.white,
                      const Color(0xFFF8FBFF),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14.sp),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? .28 : .07),
                blurRadius: isDark ? 18 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10.sp),
                  onTap: onDateRangeTap,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: .5.h, horizontal: .8.w),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 17.sp, color: filterAccent),
                        horizontalSpace(width: 2.w),
                        Expanded(
                          child: Text(
                            rangeText,
                            style: AppStyles.semiboldTextStyle(context)
                                .copyWith(fontSize: 12.4.sp, color: textColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (selectedLabel.isNotEmpty) ...[
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? filterAccent.withValues(alpha: .24)
                        : filterAccentSoft,
                    borderRadius: BorderRadius.circular(8.sp),
                    border: Border.all(
                      color: filterAccent.withValues(alpha: .46),
                    ),
                  ),
                  child: Text(
                    selectedLabel,
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 11.2.sp,
                      color: filterAccent,
                    ),
                  ),
                ),
                horizontalSpace(width: 2.w),
              ],
              PopupMenuButton<int>(
                padding: EdgeInsets.zero,
                offset: Offset(0, 5.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.sp)),
                icon: Icon(Icons.filter_list, color: filterAccent, size: 24.sp),
                onSelected: onFilterTap,
                itemBuilder: (_) => List.generate(filterLabels.length, (i) {
                  final selected = selectedFilterIndex == i;
                  return PopupMenuItem<int>(
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                    ),
                    value: i,
                    child: Row(
                      children: [
                        if (selected)
                          Icon(Icons.check, color: filterAccent, size: 18.sp),
                        if (selected) horizontalSpace(width: 2.w),
                        Text(
                          filterLabels[i],
                          style: TextStyle(
                            fontSize: 12.6.sp,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                            color: selected ? filterAccent : textColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    const filterAccent = Color(0xFF2563EB);
    const filterAccentSoft = Color(0xFFEFF4FF);
    final darkSurface = const Color(0xFF182235);
    final darkSurfaceAlt = const Color(0xFF111A2B);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  darkSurface,
                  darkSurfaceAlt,
                ]
              : [AppColors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(14.sp),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: .14) : Colors.black12,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .28 : .07),
            blurRadius: isDark ? 18 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.8.w,
                height: 4.3.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? filterAccent.withValues(alpha: .22)
                      : filterAccentSoft,
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                child: Icon(
                  Icons.date_range_rounded,
                  color: filterAccent,
                  size: 17.sp,
                ),
              ),
              horizontalSpace(width: 2.2.w),
              Expanded(
                child: Text(
                  'Date & Time Range',
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 14.4.sp,
                    color: onSurface,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace(height: 1.1.h),
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
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 1.15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onApply,
              child: Text(
                applyLabel,
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  fontSize: 13.2.sp,
                  color: Colors.white,
                ),
              ),
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
    const filterAccent = Color(0xFF2563EB);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: .75.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1725) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: .12)
                : filterAccent.withValues(alpha: .32),
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
                Icon(icon, size: 14.sp, color: filterAccent),
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
