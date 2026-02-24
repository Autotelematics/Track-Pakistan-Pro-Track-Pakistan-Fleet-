import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'common_widgets.dart';

class HistoryCustomDateTimePicker extends StatelessWidget {
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final TimeOfDay? customStartTime;
  final TimeOfDay? customEndTime;
  final VoidCallback onClose;
  final VoidCallback onApply;
  final void Function(DateTime date, bool isStart) onDatePicked;
  final void Function(TimeOfDay time, bool isStart) onTimePicked;

  const HistoryCustomDateTimePicker({
    super.key,
    required this.customStartDate,
    required this.customEndDate,
    required this.customStartTime,
    required this.customEndTime,
    required this.onClose,
    required this.onApply,
    required this.onDatePicked,
    required this.onTimePicked,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 14.h,
      left: 3.w,
      right: 3.w,
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Select Date & Time Range",
                    style: AppStyles.semiboldTextStyle(context)
                        .copyWith(fontSize: 17.sp)),
                IconButton(
                  icon: Icon(Icons.cancel_outlined,
                      color: AppColors.red, size: 20.sp),
                  onPressed: onClose,
                ),
              ],
            ),
            verticalSpace(height: 2.h),
            Row(
              children: [
                Expanded(
                    child: _DateTimeField(
                      label: "Start",
                      isStart: true,
                      date: customStartDate,
                      time: customStartTime,
                      onDatePicked: onDatePicked,
                      onTimePicked: onTimePicked,
                    )),
                horizontalSpace(width: 3.w),
                Expanded(
                    child: _DateTimeField(
                      label: "End",
                      isStart: false,
                      date: customEndDate,
                      time: customEndTime,
                      onDatePicked: onDatePicked,
                      onTimePicked: onTimePicked,
                    )),
              ],
            ),
            verticalSpace(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ConstantColor.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.sp),
                  ),
                ),
                child: Text('Apply Filter',
                    style: AppStyles.semiboldTextStyle(context)
                        .copyWith(color: Colors.white, fontSize: 16.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private field widget ──────────────────────────────────────────────────────
class _DateTimeField extends StatelessWidget {
  final String label;
  final bool isStart;
  final DateTime? date;
  final TimeOfDay? time;
  final void Function(DateTime, bool) onDatePicked;
  final void Function(TimeOfDay, bool) onTimePicked;

  const _DateTimeField({
    required this.label,
    required this.isStart,
    required this.date,
    required this.time,
    required this.onDatePicked,
    required this.onTimePicked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppStyles.regularTextStyle(context)
                .copyWith(fontSize: 15.sp, fontWeight: FontWeight.w500)),
        verticalSpace(height: 0.8.h),
        DateTimeTile(
          icon: Icons.calendar_today,
          text: date != null
              ? "${date!.day}/${date!.month}/${date!.year}"
              : "Select Date",
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) onDatePicked(picked, isStart);
          },
        ),
        verticalSpace(height: 1.2.h),
        DateTimeTile(
          icon: Icons.access_time,
          text: time != null ? time!.format(context) : "Select Time",
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time ?? TimeOfDay.now(),
            );
            if (picked != null) onTimePicked(picked, isStart);
          },
        ),
      ],
    );
  }
}