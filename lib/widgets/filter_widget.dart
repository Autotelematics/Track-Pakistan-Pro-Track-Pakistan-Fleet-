import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/group_filter_item.dart';

import 'custom_button.dart';

class CommonFilterOverlay extends StatelessWidget {
  final bool isFilterOpen;
  final VoidCallback onClose;
  final VoidCallback onApply;
  final List<String> filterItems;
  final Color cardColor;
  final Color primary;
  final Color onSurface;

  const CommonFilterOverlay({
    super.key,
    required this.isFilterOpen,
    required this.onClose,
    required this.onApply,
    required this.filterItems,
    required this.cardColor,
    required this.primary,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFilterOpen) return const SizedBox.shrink();

    final items = filterItems.isNotEmpty
        ? filterItems
        : ["Default A", "Default B", "Default C"];

    return Stack(
      children: [
        // ✅ Dimmed backdrop
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ),

        // ✅ Filter panel
        Positioned(
          top: 18.h,
          right: 5.w,
          left: 10.w,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isFilterOpen ? 1.0 : 0.0,
            child: Material(
              color: cardColor,
              borderRadius: BorderRadius.circular(16.px),
              elevation: 12,
              shadowColor: Colors.black26,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                constraints: BoxConstraints(maxHeight: 45.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Filter",
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: onSurface),
                          onPressed: onClose,
                        ),
                      ],
                    ),

                    Divider(color: onSurface.withOpacity(0.2)),
                    SizedBox(height: 1.h),

                    // ✅ Dynamic filter items
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => SizedBox(height: 1.h),
                        itemBuilder: (context, index) {
                          final title = items[index];
                          return GroupFilterItem(
                            title: title,
                            primary: primary,
                            onSurface: onSurface,
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // ✅ Apply button
                    SizedBox(
                      width: double.infinity,
                      child:CustomButton(
                        text: "Apply Filter", onPressed: onApply,
                        height: 5.h,
                        backgroundColor: primary,

                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
