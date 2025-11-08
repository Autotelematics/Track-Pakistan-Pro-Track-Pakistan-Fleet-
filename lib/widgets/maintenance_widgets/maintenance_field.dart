import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class MaintenanceField extends StatelessWidget {
  final String title;
  final String hint;
  final VoidCallback? onTap;

  const MaintenanceField({
    super.key,
    required this.title,
    required this.hint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16.sp,
                color: onSurface,
                fontWeight: FontWeight.w500)),
        verticalSpace(height: 1.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 6.h,
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.cardColor,
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              hint,
              style: TextStyle(
                fontSize: 16.sp,
                color: onSurface.withOpacity(.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
