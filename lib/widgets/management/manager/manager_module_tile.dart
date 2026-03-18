import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';

class ManagerModuleTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String? centerButtonText;
  final VoidCallback? onCenterButtonTap;
  final Color? centerButtonBackgroundColor;
  final Color? centerButtonTextColor;
  final double? centerButtonFontSizeSp;
  final double? centerButtonVerticalPaddingH;

  const ManagerModuleTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
    this.centerButtonText,
    this.onCenterButtonTap,
    this.centerButtonBackgroundColor,
    this.centerButtonTextColor,
    this.centerButtonFontSizeSp,
    this.centerButtonVerticalPaddingH,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(3.2.w, 1.6.w, 3.2.w, 2.2.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: .10),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: .4.h,
                right: .5.w,
                child: Container(
                  padding: EdgeInsets.all(2.2.w),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ??
                        theme.colorScheme.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? theme.colorScheme.primary,
                    size: 20.sp,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 33.w,
                    child: Text(
                      title,
                      style: AppStyles.semiboldTextStyle(context).copyWith(
                        fontSize: 14.5.sp,
                      ),
                    ),
                  ),
                  if (centerButtonText != null &&
                      onCenterButtonTap != null) ...[
                    const Spacer(),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: onCenterButtonTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.4.w,
                              vertical: centerButtonVerticalPaddingH ?? .55.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: (centerButtonTextColor ??
                                      theme.colorScheme.primary)
                                  .withValues(alpha: .35),
                            ),
                            color: centerButtonBackgroundColor ??
                                theme.colorScheme.primary
                                    .withValues(alpha: .08),
                          ),
                          child: Text(
                            centerButtonText!,
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: centerButtonFontSizeSp ?? 11.3.sp,
                              fontWeight: FontWeight.w700,
                              color: centerButtonTextColor ??
                                  theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
