import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/widgets/custom_button.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

Future<void> showValidationErrorDialog(
  BuildContext context, {
  required String message,
  String title = 'Validation Error',
}) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;

  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.2.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? .34 : .10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(1.0.h),
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withValues(alpha: .17),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.yellow,
                    size: 18.sp,
                  ),
                ),
                horizontalSpace(width: 2.4.w),
                Expanded(
                  child: Text(
                    title,
                    style: AppStyles.semiboldTextStyle(ctx).copyWith(
                      fontSize: 14.2.sp,
                      color: onSurface,
                    ),
                  ),
                ),
              ],
            ),
            verticalSpace(height: 1.1.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: AppStyles.regularTextStyle(ctx).copyWith(
                  fontSize: 12.8.sp,
                  color: onSurface.withValues(alpha: .82),
                ),
              ),
            ),
            verticalSpace(height: 1.25.h),
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                text: 'OK',
                height: 3.9.h,
                width: 22.w,
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
