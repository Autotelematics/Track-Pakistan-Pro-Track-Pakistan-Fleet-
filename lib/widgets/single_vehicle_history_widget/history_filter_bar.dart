import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';

class HistoryFilterBar extends StatelessWidget {
  final String fromDate;
  final String toDate;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final VoidCallback? onDateRangeTap; // ← NEW: Left side date click ke liye

  const HistoryFilterBar({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.selectedFilter,
    required this.onFilterSelected,
    this.onDateRangeTap, // optional
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
    final displayFilter = selectedFilter.isEmpty ? "Last 12H" : selectedFilter;

    return Positioned(
      top: 8.h,
      left: 3.w,
      right: 3.w,
      child: Container(
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
            // ==================== LEFT SIDE - Clickable Date Range ====================
            Expanded(
              child: GestureDetector(
                onTap: onDateRangeTap, // ← Custom picker open hoga
                behavior: HitTestBehavior.opaque,
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
                  ],
                ),
              ),
            ),

            // ==================== RIGHT SIDE - Filter Badge + Popup ====================
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: ConstantColor.primaryColor,
                borderRadius: BorderRadius.circular(6.sp),
              ),
              child: Text(
                displayFilter,
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  fontSize: 14.sp,
                  color: AppColors.white,
                ),
              ),
            ),
            horizontalSpace(width: 2.w),

            PopupMenuButton<String>(
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
                // "Custom" ← REMOVED as per requirement
              ]
                  .map((e) => PopupMenuItem(
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
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}