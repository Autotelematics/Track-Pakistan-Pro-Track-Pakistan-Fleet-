import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

const String notificationPresetToday = 'Today';
const String notificationPresetYesterday = 'Yesterday';
const String notificationPresetLast7Days = '7 Days';
const String notificationPresetLast30Days = '30 Days';

class SearchAndFilterBar extends StatefulWidget {
  final List<String> alertTypes;
  final Map<String, int> alertCounts;
  final List<String> vehicles;
  final String? selectedVehicle;
  final String? selectedAlertType;
  final Function(String?)? onVehicleChanged;
  final Function(String?)? onAlertTypeChanged;
  final VoidCallback onSearchPressed;
  final ValueChanged<String>? onPresetSelected;
  final String? selectedPreset;
  final VoidCallback? onFromDateTap;
  final VoidCallback? onToDateTap;
  final String? fromDateLabel;
  final String? toDateLabel;
  final TextEditingController? searchController;
  final VoidCallback? onFilterReset;
  final bool compactMode;

  const SearchAndFilterBar({
    super.key,
    required this.alertTypes,
    required this.vehicles,
    required this.alertCounts,
    required this.selectedVehicle,
    required this.selectedAlertType,
    required this.searchController,
    required this.onVehicleChanged,
    required this.onAlertTypeChanged,
    required this.onSearchPressed,
    this.onPresetSelected,
    this.selectedPreset,
    this.onFromDateTap,
    this.onToDateTap,
    this.fromDateLabel,
    this.toDateLabel,
    this.onFilterReset, // ← add this
    this.compactMode = false,
  });

  @override
  State<SearchAndFilterBar> createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends State<SearchAndFilterBar> {
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.compactMode;
  }

  @override
  void didUpdateWidget(covariant SearchAndFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.compactMode && !oldWidget.compactMode) {
      _isCollapsed = true;
    }
  }

  void _toggleCollapsed() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? Colors.grey.shade900.withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.95);
    final iconColor = AppColors.red;
    final panelColor = isDark
        ? Colors.black.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.18);
    final panelBorder = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.45);
    final panelPadding = widget.compactMode
        ? EdgeInsets.fromLTRB(3.2.w, .8.h, 3.2.w, .8.h)
        : EdgeInsets.fromLTRB(3.2.w, 1.4.h, 3.2.w, 1.4.h);
    final sectionGap = widget.compactMode ? .7.h : 1.1.h;

    return Container(
      padding: panelPadding,
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(16.px),
        border: Border.all(color: panelBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _toggleCollapsed,
            borderRadius: BorderRadius.circular(10.px),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: .1.h),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: Colors.white.withValues(alpha: .92),
                    size: 18.sp,
                  ),
                  horizontalSpace(width: 1.6.w),
                  Text(
                    l10n.notificationFilters,
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: .96),
                    ),
                  ),
                  horizontalSpace(width: 1.2.w),
                  Icon(
                    _isCollapsed
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    color: Colors.white.withValues(alpha: .86),
                    size: 18.sp,
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.px),
                      onTap: widget.onFilterReset,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: .3.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.close_rounded,
                              color: Colors.white.withValues(alpha: .88),
                              size: 16.5.sp,
                            ),
                            horizontalSpace(width: .7.w),
                            Text(
                              l10n.reset,
                              style:
                              AppStyles.semiboldTextStyle(context).copyWith(
                                fontSize: 13.5.sp,
                                color: Colors.white.withValues(alpha: .9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _isCollapsed
                ? const SizedBox.shrink()
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(height: 1.1.h),
                if (widget.compactMode) verticalSpace(height: .2.h),
                Text(
                  l10n.searchByVehicleAndType,
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: .82),
                  ),
                ),
                verticalSpace(height: .55.h),
                Row(
                  children: [
                    Expanded(
                      child: _DropdownBox(
                        hint: l10n.vehicleLabel,
                        items: widget.vehicles,
                        selectedValue: widget.selectedVehicle,
                        icon: Icons.directions_car_rounded,
                        onChanged: widget.onVehicleChanged,
                        iconColor: iconColor,
                        backgroundColor: backgroundColor,
                      ),
                    ),
                    SizedBox(width: 1.8.w),
                    Expanded(
                      child: _DropdownBoxWithCount(
                        hint: l10n.typeLabel,
                        items: widget.alertTypes,
                        counts: widget.alertCounts,
                        selectedValue: widget.selectedAlertType,
                        icon: Icons.notifications_active_outlined,
                        onChanged: widget.onAlertTypeChanged,
                        iconColor: iconColor,
                        backgroundColor: backgroundColor,
                      ),
                    ),
                  ],
                ),
                verticalSpace(height: widget.compactMode ? .75.h : 1.0.h),
                Text(
                  l10n.searchByDateRange,
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: .82),
                  ),
                ),
                verticalSpace(height: widget.compactMode ? .4.h : .55.h),
                Row(
                  children: [
                    Expanded(
                      child: _DateTile(
                        label: widget.fromDateLabel ?? 'From Date',
                        icon: Icons.event,
                        iconColor: iconColor,
                        backgroundColor: backgroundColor,
                        onTap: widget.onFromDateTap,
                        isDark: isDark,
                      ),
                    ),
                    SizedBox(width: 1.8.w),
                    Expanded(
                      child: _DateTile(
                        label: widget.toDateLabel ?? 'To Date',
                        icon: Icons.event_available,
                        iconColor: iconColor,
                        backgroundColor: backgroundColor,
                        onTap: widget.onToDateTap,
                        isDark: isDark,
                      ),
                    ),
                    SizedBox(width: 1.8.w),
                    _QuickFilterButton(
                      selectedPreset: widget.selectedPreset,
                      onPresetSelected: widget.onPresetSelected,
                      isDark: isDark,
                    ),
                  ],
                ),
                verticalSpace(height: sectionGap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickFilterButton extends StatelessWidget {
  final String? selectedPreset;
  final ValueChanged<String>? onPresetSelected;
  final bool isDark;

  const _QuickFilterButton({
    required this.selectedPreset,
    required this.onPresetSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => onPresetSelected?.call(value),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: notificationPresetToday,
          child: Text(context.l10n.today),
        ),
        PopupMenuItem<String>(
          value: notificationPresetYesterday,
          child: Text(context.l10n.yesterday),
        ),
        PopupMenuItem<String>(
          value: notificationPresetLast7Days,
          child: Text(context.l10n.last7Days),
        ),
        PopupMenuItem<String>(
          value: notificationPresetLast30Days,
          child: Text(context.l10n.last30Days),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.px)),
      child: Container(
        width: 12.w,
        height: 4.8.h,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey.shade900.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12.px),
          border: Border.all(
            color: selectedPreset == null
                ? (isDark
                ? Colors.white.withValues(alpha: .14)
                : Colors.black.withValues(alpha: .08))
                : AppColors.red.withValues(alpha: .75),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.shade500,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.filter_alt_rounded,
            size: 18.sp,
            color: selectedPreset == null
                ? AppColors.red.withValues(alpha: .8)
                : AppColors.red,
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool isDark;

  const _DateTile({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.px),
      child: Container(
        height: 4.8.h,
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.px),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.shade500,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 17.sp),
            horizontalSpace(width: 1.2.w),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.lightTextStyle(context).copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 13.2.sp,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: isDark ? Colors.white54 : Colors.black54,
              size: 20.sp,
            ),
          ],
        ),
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

    // Create ValueNotifier for the selected value
    final selectedValueNotifier = ValueNotifier<String?>(selectedValue);

    // Update notifier when external value changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedValueNotifier.value != selectedValue) {
        selectedValueNotifier.value = selectedValue;
      }
    });

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.px),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.shade500,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          valueListenable: selectedValueNotifier, // Changed from value
          hint: Row(
            children: [
              Icon(icon, color: iconColor, size: 19.sp),
              horizontalSpace(width: 1.w),
              Text(
                hint,
                style: AppStyles.lightTextStyle(context).copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          items: items
              .map((item) => DropdownItem<String>( // Changed from DropdownMenuItem
            value: item,
            height: 4.5.h, // Moved height here
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.lightTextStyle(context).copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14.sp,
              ),
            ),
          ))
              .toList(),
          selectedItemBuilder: (context) => items
              .map(
                (item) => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.lightTextStyle(context).copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14.sp,
                ),
              ),
            ),
          )
              .toList(),
          onChanged: (newValue) {
            if (newValue == null) return;
            selectedValueNotifier.value = newValue; // Update notifier
            if (onChanged != null) onChanged?.call(newValue); // Call parent callback
          },
          buttonStyleData: ButtonStyleData(
            height: 4.5.h,
            // width can be added here if needed
          ),
          dropdownStyleData: DropdownStyleData(
            padding: EdgeInsets.zero,
            offset: const Offset(0, -4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12.px),
            ),
            maxHeight: 30.h,
          ),
          iconStyleData: IconStyleData(
            icon: Padding(
              padding: EdgeInsets.only(right: .5.w),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.white54 : Colors.black54,
                size: 18.sp,
              ),
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            // height removed from here
            padding: EdgeInsets.symmetric(horizontal: 1.w), // Optional: add padding if needed
          ),
        ),
      ),
    );
  }
}

// Alert Type Dropdown with Clean Count
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
    final allLabel = context.l10n.vehicleStatusAll;

    // Create ValueNotifier for the selected value
    final selectedValueNotifier = ValueNotifier<String?>(selectedValue);

    // Update notifier when external value changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedValueNotifier.value != selectedValue) {
        selectedValueNotifier.value = selectedValue;
      }
    });

    return DecoratedBox(
      decoration: BoxDecoration(
        // color: backgroundColor,
        borderRadius: BorderRadius.circular(12.px),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.shade500,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          valueListenable: selectedValueNotifier, // Changed from value
          hint: Row(
            children: [
              Icon(icon, color: iconColor, size: 19.sp),
              horizontalSpace(width: 1.w),
              Text(
                hint,
                style: AppStyles.lightTextStyle(context).copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          items: items
              .map((item) => DropdownItem<String>( // Changed from DropdownMenuItem
            value: item,
            height: 4.5.h, // Moved height here
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: item,
                    style: AppStyles.lightTextStyle(context).copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14.sp,
                    ),
                  ),
                  TextSpan(
                    text: " (${counts[item] ?? 0})",
                    style: AppStyles.lightTextStyle(context).copyWith(
                      color: item == allLabel ? Colors.blue : Colors.green,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ))
              .toList(),
          selectedItemBuilder: (context) => items
              .map(
                (item) => Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: item,
                      style: AppStyles.lightTextStyle(context).copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14.sp,
                      ),
                    ),
                    TextSpan(
                      text: " (${counts[item] ?? 0})",
                      style: AppStyles.lightTextStyle(context).copyWith(
                        color: item == allLabel ? Colors.blue : Colors.green,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .toList(),
          onChanged: (newValue) {
            if (newValue == null) return;
            selectedValueNotifier.value = newValue; // Update notifier
            if (onChanged != null) onChanged?.call(newValue); // Call parent callback
          },
          buttonStyleData: ButtonStyleData(
            height: 4.5.h,
          ),
          dropdownStyleData: DropdownStyleData(
            padding: EdgeInsets.zero,
            offset: const Offset(0, -4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12.px),
            ),
            maxHeight: 30.h,
          ),
          iconStyleData: IconStyleData(
            icon: Padding(
              padding: EdgeInsets.only(right: .5.w),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.white54 : Colors.black54,
                size: 18.sp,
              ),
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            // height removed from here (now on DropdownItem)
            padding: EdgeInsets.symmetric(horizontal: 1.w), // Optional: adjust as needed
          ),
        ),
      ),
    );
  }
}