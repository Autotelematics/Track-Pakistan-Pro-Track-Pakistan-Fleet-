import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class AnalyticsGraphContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isEmpty;

  const AnalyticsGraphContainer({
    super.key,
    required this.title,
    required this.child,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = isDark ? Colors.white.withValues(alpha: .06) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final titleColor = isDark ? AppColors.white : AppColors.textBlack;
    final subtitleColor =
        isDark ? Colors.white70 : AppColors.textBlack.withValues(alpha: .55);

    return Container(
      height: 28.h,
      padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 1.65.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? <Color>[
                  surface,
                  Colors.white.withValues(alpha: .03),
                ]
              : <Color>[
                  Colors.white,
                  const Color(0xFFF8FBFF),
                ],
        ),
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .18 : 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5.8.w,
                height: 5.8.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[
                      Color(0xFF22D3EE),
                      Color(0xFF0284C7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.query_stats_rounded,
                  color: Colors.white,
                  size: 10.8.sp,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 12.8.sp,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
              ),
              if (isEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 1.8.w, vertical: .28.h),
                  decoration: BoxDecoration(
                    color: onSurface.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: onSurface.withValues(alpha: .14)),
                  ),
                  child: Text(
                    l10n.noData,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 10.8.sp,
                      color: subtitleColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          verticalSpace(height: 1.h),
          Expanded(
            child: isEmpty ? _EmptyChart() : child,
          ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
            size: 30.sp,
          ),
          SizedBox(height: 1.h),
          Text(
            l10n.noDataAvailable,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey.shade400,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
