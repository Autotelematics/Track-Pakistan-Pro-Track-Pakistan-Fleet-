import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class AnalyticsFilterBar extends StatelessWidget {
  final String fromDate;
  final String toDate;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final TimeOfDay? customStartTime;
  final TimeOfDay? customEndTime;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndTimeTap;
  final bool showDateRangePicker;
  final VoidCallback onDateRangeTap;
  final VoidCallback onCloseDateRange;

  const AnalyticsFilterBar({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.customStartDate,
    required this.customEndDate,
    required this.customStartTime,
    required this.customEndTime,
    required this.onStartDateTap,
    required this.onEndDateTap,
    required this.onStartTimeTap,
    required this.onEndTimeTap,
    required this.showDateRangePicker,
    required this.onDateRangeTap,
    required this.onCloseDateRange,
  });

  String _formatDate(String apiDate) {
    if (apiDate.isEmpty) return '';
    try {
      final parts = apiDate.split('-');
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    } catch (_) {
      return apiDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.white.withValues(alpha: .06) : AppColors.white;
    final borderColor = isDark ? Colors.white12 : Colors.black12;
    final textColor = isDark ? AppColors.white : AppColors.textBlack;

    return Column(
      children: [
        Container(
          height: 5.4.h,
          padding: EdgeInsets.symmetric(horizontal: 2.5.w),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14.sp),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? .18 : .07),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                    padding: EdgeInsets.symmetric(vertical: .5.h, horizontal: .8.w),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 17.sp, color: ConstantColor.primaryColor),
                        horizontalSpace(width: 2.w),
                        Expanded(
                          child: Text(
                            "${_formatDate(fromDate)} → ${_formatDate(toDate)}",
                            style: AppStyles.semiboldTextStyle(context)
                                .copyWith(fontSize: 13.2.sp, color: textColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Active filter badge
              Container(
                padding:
                EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: ConstantColor.primaryColor.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(8.sp),
                  border: Border.all(
                    color: ConstantColor.primaryColor.withValues(alpha: .45),
                  ),
                ),
                child: Text(
                  selectedFilter,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 11.9.sp,
                    color: ConstantColor.primaryColor,
                  ),
                ),
              ),
              horizontalSpace(width: 2.w),
              // Filter popup
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                offset: Offset(0, 5.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.sp)),
                icon: Icon(Icons.filter_list,
                    color: ConstantColor.primaryColor, size: 24.sp),
                onSelected: onFilterSelected,
                itemBuilder: (_) => [
                  "Today",
                  "Yesterday",
                  "Last 3 Days",
                  "Last 7 Days",
                  "Custom",
                ]
                    .map(
                      (e) => PopupMenuItem<String>(
                    value: e,
                    child: Row(
                      children: [
                        if (e == selectedFilter)
                          Icon(Icons.check,
                              color: ConstantColor.primaryColor,
                              size: 18.sp),
                        if (e == selectedFilter)
                          horizontalSpace(width: 2.w),
                          Text(
                          e,
                          style: TextStyle(
                            fontSize: 12.6.sp,
                            fontWeight: e == selectedFilter
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: e == selectedFilter
                                ? ConstantColor.primaryColor
                                : textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .toList(),
              ),
            ],
          ),
        ),

        if (showDateRangePicker) ...[
          verticalSpace(height: 1.h),
          _AnalyticsCustomDatePicker(
            onClose: onCloseDateRange,
            customStartDate: customStartDate,
            customEndDate: customEndDate,
            customStartTime: customStartTime,
            customEndTime: customEndTime,
            onStartDateTap: onStartDateTap,
            onEndDateTap: onEndDateTap,
            onStartTimeTap: onStartTimeTap,
            onEndTimeTap: onEndTimeTap,
          ),
        ],
      ],
    );
  }
}

class _AnalyticsCustomDatePicker extends StatelessWidget {
  final VoidCallback onClose;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final TimeOfDay? customStartTime;
  final TimeOfDay? customEndTime;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndTimeTap;

  const _AnalyticsCustomDatePicker({
    required this.onClose,
    required this.customStartDate,
    required this.customEndDate,
    required this.customStartTime,
    required this.customEndTime,
    required this.onStartDateTap,
    required this.onEndDateTap,
    required this.onStartTimeTap,
    required this.onEndTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.white.withValues(alpha: .08), Colors.white.withValues(alpha: .04)]
              : [AppColors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(14.sp),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .18 : .07),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: ConstantColor.primaryColor.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                child: Icon(
                  Icons.date_range_rounded,
                  color: ConstantColor.primaryColor,
                  size: 17.sp,
                ),
              ),
              horizontalSpace(width: 2.2.w),
              Expanded(
                child: Text(
                  "Date & Time Range",
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 14.4.sp,
                    color: onSurface,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onClose,
                child: Container(
                  padding: EdgeInsets.all(.55.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: .08)
                        : Colors.black.withValues(alpha: .05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, size: 16.sp, color: onSurface),
                ),
              )
            ],
          ),
          verticalSpace(height: 1.1.h),
          Row(
            children: [
              Expanded(
                child: _DateTimeSelector(
                  label: "Start Date & Time",
                  date: customStartDate,
                  time: customStartTime,
                  onDateTap: onStartDateTap,
                  onTimeTap: onStartTimeTap,
                ),
              ),
              horizontalSpace(width: 3.w),
              Expanded(
                child: _DateTimeSelector(
                  label: "End Date & Time",
                  date: customEndDate,
                  time: customEndTime,
                  onDateTap: onEndDateTap,
                  onTimeTap: onEndTimeTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateTimeSelector extends StatelessWidget {
  final String label;
  final DateTime? date;
  final TimeOfDay? time;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  const _DateTimeSelector({
    required this.label,
    required this.date,
    required this.time,
    required this.onDateTap,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: 12.3.sp,
            color: isDark ? Colors.white70 : Colors.grey.shade700,
            fontWeight: FontWeight.w700,
          ),
        ),
        verticalSpace(height: .65.h),
        GestureDetector(
          onTap: onDateTap,
          child: _PickerTile(
            icon: Icons.calendar_today,
            text: date != null
                ? "${date!.day}/${date!.month}/${date!.year}"
                : "Select Date",
            hasValue: date != null,
          ),
        ),
        verticalSpace(height: .7.h),
        GestureDetector(
          onTap: onTimeTap,
          child: _PickerTile(
            icon: Icons.access_time,
            text: time != null ? time!.format(context) : "Select Time",
            hasValue: time != null,
          ),
        ),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool hasValue;

  const _PickerTile({
    required this.icon,
    required this.text,
    required this.hasValue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.0.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: .06) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10.sp),
        border:
            Border.all(color: ConstantColor.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: ConstantColor.primaryColor),
          horizontalSpace(width: 2.w),
          Expanded(
            child: Text(
              text,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 12.2.sp,
                color: hasValue
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.white60 : Colors.grey.shade500),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
