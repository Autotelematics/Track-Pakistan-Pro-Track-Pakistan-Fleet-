import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';

class HistoryFilterBar extends StatelessWidget {
  final String fromDate;
  final String toDate;
  final String selectedFilter;
  final bool showDateRangePicker;
  final ValueChanged<String> onFilterSelected;
  final VoidCallback? onCustomFilterTap;
  final VoidCallback? onDateRangeTap; // ← NEW: Left side date click ke liye

  const HistoryFilterBar({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.selectedFilter,
    required this.showDateRangePicker,
    required this.onFilterSelected,
    this.onCustomFilterTap,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const filterAccent = Color(0xFF2563EB);
    const filterAccentSoft = Color(0xFFEFF4FF);
    final filters = const [
      "Today",
      "Yesterday",
      "Last 3 Days",
      "Last 7 Days",
      "Custom",
    ];

    return Positioned(
      top: 5.6.h,
      left: 3.w,
      right: 3.w,
      child: Transform.translate(
        offset: Offset(0, -0.4.h),
        transformHitTests: false,
        child: Column(
          children: [
            Row(
              children: List.generate(filters.length, (i) {
                final filter = filters[i];
                final selected = selectedFilter == filter;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: i == filters.length - 1 ? 0 : 1.2.w),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(9),
                      onTap: () {
                        if (filter == "Custom") {
                          onCustomFilterTap?.call();
                          return;
                        }
                        onFilterSelected(filter);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: .9.h),
                        decoration: BoxDecoration(
                          color: selected
                              ? (isDark
                                  ? filterAccent.withValues(alpha: .26)
                                  : filterAccentSoft)
                              : (isDark
                                  ? Colors.white.withValues(alpha: .06)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: selected
                                ? filterAccent.withValues(alpha: .55)
                                : (isDark ? Colors.white12 : Colors.black12),
                          ),
                        ),
                        child: Text(
                          _labelForFilter(context, filter),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppStyles.semiboldTextStyle(context).copyWith(
                            fontSize: 10.9.sp,
                            color: selected
                                ? filterAccent
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 1.h),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onDateRangeTap,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.15.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: .06)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
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
                        size: 17.sp, color: filterAccent),
                    horizontalSpace(width: 1.8.w),
                    Expanded(
                      child: Text(
                        "${_formatDate(fromDate)}  ->  ${_formatDate(toDate)}",
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
        ),
      ),
    );
  }

  String _labelForFilter(BuildContext context, String filter) {
    final l10n = context.l10n;
    switch (filter) {
      case "Today":
        return l10n.today;
      case "Yesterday":
        return l10n.yesterday;
      case "Last 3 Days":
        return l10n.last3Days;
      case "Last 7 Days":
        return l10n.last7Days;
      case "Custom":
        return l10n.custom;
      default:
        return filter;
    }
  }
}
