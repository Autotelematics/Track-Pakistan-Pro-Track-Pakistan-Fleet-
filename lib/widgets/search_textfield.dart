import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/widgets/custom_text_field.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class SearchAndFilterBar extends StatelessWidget {
  final List<String> alertTypes;
  final Map<String, int> alertCounts;
  final List<String> vehicles;
  final String? selectedVehicle;
  final String? selectedAlertType;
  final Function(String?)? onVehicleChanged;
  final Function(String?)? onAlertTypeChanged;
  final VoidCallback onSearchPressed;

  const SearchAndFilterBar({
    super.key,
    required this.alertTypes,
    required this.alertCounts,
    required this.vehicles,
    this.selectedVehicle,
    this.selectedAlertType,
    this.onVehicleChanged,
    this.onAlertTypeChanged,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? Colors.grey.shade900.withOpacity(0.9)
        : Colors.white.withOpacity(0.95);
    final iconColor = isDark ? Colors.tealAccent : Colors.teal;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w), // thoda kam padding
      child: Column(
        children: [
          // Search Field
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16.px),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.grey.shade500,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomTextField(
              labelText: "Search Notification",
              borderRadius: 15.px,
              fillColor: Colors.transparent,
              suffixIcon: Icons.search_outlined,
              onSuffixTap: onSearchPressed,
              onSubmitted: (_) => onSearchPressed(),
            ),
          ),

          verticalSpace(height: 1.5.h),

          // Filters – Super Safe Layout
          Row(
            children: [
              // Vehicle Dropdown
              Expanded(
                child: _DropdownBox(
                  hint: "Vehicle",
                  items: vehicles,
                  selectedValue: selectedVehicle,
                  icon: Icons.directions_car_rounded,
                  onChanged: onVehicleChanged,
                  iconColor: iconColor,
                  backgroundColor: backgroundColor,
                ),
              ),

              SizedBox(width: 1.8.w), // minimum safe gap

              // Alert Type Dropdown
              Expanded(
                child: _DropdownBoxWithCount(
                  hint: "Type",
                  items: alertTypes,
                  counts: alertCounts,
                  selectedValue: selectedAlertType,
                  icon: Icons.notifications_active_outlined,
                  onChanged: onAlertTypeChanged,
                  iconColor: iconColor,
                  backgroundColor: backgroundColor,
                ),
              ),

              SizedBox(width: 1.8.w),

              // Search Button – Fixed compact size
              SizedBox(
                width: 10.w,
                height: 10.w,
                child: GestureDetector(
                  onTap: onSearchPressed,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? iconColor.withOpacity(0.15) : AppColors.white,
                      borderRadius: BorderRadius.circular(10.px),
                      border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
                    ),
                    child: Icon(Icons.search_outlined, color: iconColor, size: 19.sp),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _DropdownBox extends StatelessWidget {
  final String hint;
  final List<String> items;
  final String? selectedValue;
  final Function(String?)? onChanged;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _DropdownBox({
    required this.hint,
    required this.items,
    this.selectedValue,
    this.onChanged,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.px),
        boxShadow: [
          BoxShadow(color: isDark ? Colors.black26 : Colors.grey.shade500, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          value: selectedValue,
          hint: Row(
            children: [
              Icon(icon, color: iconColor, size: 19.sp),
              horizontalSpace(width: 1.w),
              Text(hint, style: AppStyles.lightTextStyle(context).copyWith(color: isDark ? Colors.white70 : Colors.black87)),
            ],
          ),
          items: items
              .map((item) => DropdownMenuItem<String>(
            value: item,
            child: Text(item, overflow: TextOverflow.ellipsis, style: AppStyles.lightTextStyle(context).copyWith(color: isDark ? Colors.white : Colors.black87)),
          ))
              .toList(),
          onChanged: onChanged,
          buttonStyleData: ButtonStyleData(height: 4.5.h),
          dropdownStyleData: DropdownStyleData(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12.px)),
            maxHeight: 30.h,
          ),
          iconStyleData: IconStyleData(
            icon: Padding(padding: EdgeInsets.only(right: .5.w), child: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? Colors.white54 : Colors.black54, size: 18.sp)),
          ),
        ),
      ),
    );
  }
}

// Alert Type Dropdown with Count Badge
class _DropdownBoxWithCount extends StatelessWidget {
  final String hint;
  final List<String> items;
  final Map<String, int> counts;
  final String? selectedValue;
  final Function(String?)? onChanged;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _DropdownBoxWithCount({
    required this.hint,
    required this.items,
    required this.counts,
    this.selectedValue,
    this.onChanged,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.px),
        boxShadow: [
          BoxShadow(color: isDark ? Colors.black26 : Colors.grey.shade500, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          value: selectedValue,
          hint: Row(
            children: [
              Icon(icon, color: iconColor, size: 19.sp),
              horizontalSpace(width: 1.w),
              Text(hint, style: AppStyles.lightTextStyle(context).copyWith(color: isDark ? Colors.white70 : Colors.black87)),
            ],
          ),
          items: items
              .map((item) => DropdownMenuItem<String>(
            value: item,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: item,
                    style: AppStyles.lightTextStyle(context).copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: "  (${counts[item] ?? 0})",
                    style: TextStyle(
                      color: item == 'All' ? Colors.blue : Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ))
              .toList(),
          onChanged: onChanged,
          buttonStyleData: ButtonStyleData(height: 4.5.h),
          dropdownStyleData: DropdownStyleData(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12.px)),
            maxHeight: 30.h,
          ),
          iconStyleData: IconStyleData(
            icon: Padding(padding: EdgeInsets.only(right: .5.w), child: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? Colors.white54 : Colors.black54, size: 18.sp)),
          ),
        ),
      ),
    );
  }
}