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
    return Column(
      children: [
        Container(
          height: 5.h,
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.sp),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 18.sp, color: ConstantColor.primaryColor),
              horizontalSpace(width: 2.w),
              Expanded(
                child: Text(
                  "${_formatDate(fromDate)} → ${_formatDate(toDate)}",
                  style: AppStyles.semiboldTextStyle(context)
                      .copyWith(fontSize: 14.sp),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Active filter badge
              Container(
                padding:
                EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: ConstantColor.primaryColor,
                  borderRadius: BorderRadius.circular(6.sp),
                ),
                child: Text(
                  selectedFilter,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 14.sp,
                    color: AppColors.white,
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
                            fontWeight: e == selectedFilter
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: e == selectedFilter
                                ? ConstantColor.primaryColor
                                : Colors.black87,
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

        if (selectedFilter == "Custom") ...[
          verticalSpace(height: 2.h),
          _AnalyticsCustomDatePicker(
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
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final TimeOfDay? customStartTime;
  final TimeOfDay? customEndTime;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndTimeTap;

  const _AnalyticsCustomDatePicker({
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
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Date & Time Range",
            style: AppStyles.semiboldTextStyle(context)
                .copyWith(fontSize: 17.sp),
          ),
          verticalSpace(height: 2.h),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: 15.sp,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w700,
          ),
        ),
        verticalSpace(height: 1.h),
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
        verticalSpace(height: 1.2.h),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10.sp),
        border: Border.all(color: ConstantColor.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: ConstantColor.primaryColor),
          horizontalSpace(width: 2.w),
          Expanded(
            child: Text(
              text,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 14.sp,
                color: hasValue ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}