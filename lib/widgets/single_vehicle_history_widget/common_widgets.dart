import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/get_device_history_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class SheetTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const SheetTab({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 2.9.w, vertical: .36.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border(
            bottom: BorderSide(
              color:
                  isSelected ? ConstantColor.primaryColor : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14.8.sp,
                color: isSelected
                    ? ConstantColor.primaryColor
                    : onSurface.withValues(alpha: .58)),
            horizontalSpace(width: .8.w),
            Text(
              label,
              style: AppStyles.semiboldTextStyle(context).copyWith(
                fontSize: 14.5.sp,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? ConstantColor.secondaryColor
                    : onSurface.withValues(alpha: .72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final TripSegment trip;
  final int tripNumber;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  const TripCard({
    super.key,
    required this.trip,
    required this.tripNumber,
    required this.isSelected,
    required this.onTap,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: 1.0.h),
        padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? ConstantColor.primaryColor.withValues(alpha: 0.08)
              : (isDark ? Colors.white.withValues(alpha: .04) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? ConstantColor.primaryColor.withValues(alpha: .45)
                : (isDark ? Colors.white12 : Colors.black12),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? .16 : .05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Trip number bubble
            Container(
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? ConstantColor.primaryColor
                    : ConstantColor.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$tripNumber',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            // Trip info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.circle, size: 15.sp, color: Colors.green),
                      SizedBox(width: 1.5.w),
                      Expanded(
                        child: Text(
                          trip.startTime,
                          style: AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: 13.8.sp,
                              fontWeight: FontWeight.w600,
                              color: onSurface),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  verticalSpace(height: 0.3.h),
                  Padding(
                    padding: EdgeInsets.only(left: 1.8.w),
                    child: Container(
                      height: 1.8.h,
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16.sp, color: Colors.red),
                      SizedBox(width: 1.5.w),
                      Expanded(
                        child: Text(
                          (trip.isInProgress ?? false)
                              ? l10n.taskInProgress
                              : trip.endTime,
                          style: AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: 13.8.sp,
                              fontWeight: FontWeight.w600,
                              color: (trip.isInProgress ?? false)
                                  ? ConstantColor.primaryColor
                                  : onSurface),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.8.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 0.6.h,
                    children: [
                      MiniChip(
                        icon: Icons.straighten,
                        label: '${trip.distance} km',
                      ),
                      MiniChip(
                        icon: Icons.timer_outlined,
                        label: trip.duration,
                      ),
                      MiniChip(
                        icon: Icons.speed_rounded,
                        label: '${trip.topSpeed} km/h',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Play button
            GestureDetector(
              onTap: onPlay,
              child: Container(
                alignment: Alignment.center,
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 21.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParkedCard extends StatelessWidget {
  final ParkedSegment parked;
  final VoidCallback? onTap;

  const ParkedCard({
    super.key,
    required this.parked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.0.h),
        padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.1.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: .04) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? .16 : .05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 7.w,
              height: 7.w,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stop_circle_outlined,
                          size: 15.sp, color: Colors.red),
                      SizedBox(width: 1.5.w),
                      Expanded(
                        child: Text(
                          parked.stoppedAt,
                          style: AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: 13.8.sp,
                              fontWeight: FontWeight.w600,
                              color: onSurface),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  verticalSpace(height: 0.3.h),
                  Padding(
                    padding: EdgeInsets.only(left: 1.8.w),
                    child: Container(
                      height: 1.8.h,
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Row(
                    children: [
                      Icon(Icons.play_circle_outline,
                          size: 16.sp, color: Colors.green),
                      SizedBox(width: 1.5.w),
                      Expanded(
                        child: Text(
                          parked.nextMoveAt,
                          style: AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: 13.8.sp,
                              fontWeight: FontWeight.w600,
                              color: onSurface),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.8.h),
                  Wrap(
                    spacing: 2.w,
                    children: [
                      // const MiniChip(icon: Icons.straighten, label: '0.00 km'),
                      MiniChip(
                          icon: Icons.timer_outlined, label: parked.duration),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final AlertSegment alert;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.0.h),
        padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.1.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: .04) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? .16 : .05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 13.sp,
                      color: onSurface,
                    ),
                  ),
                  verticalSpace(height: 0.5.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: .6.h,
                    children: [
                      MiniChip(icon: Icons.access_time, label: alert.time),
                      MiniChip(icon: Icons.speed, label: '${alert.speed} km/h'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const MiniChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .06)
            : const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(6.sp),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5.sp, color: onSurface.withValues(alpha: .7)),
          SizedBox(width: 1.w),
          Text(label,
              style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 13.8.sp,
                  color: onSurface.withValues(alpha: .78),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class DateTimeTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const DateTimeTile(
      {super.key, required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final l10n = context.l10n;
    final isPlaceholder =
        text.contains(l10n.selectDate) || text.contains(l10n.selectTime);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 4.6.h),
        padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: .05)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15.5.sp, color: ConstantColor.primaryColor),
            horizontalSpace(width: 1.5.w),
            Expanded(
              child: Text(
                text,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 13.6.sp,
                  color: isPlaceholder
                      ? onSurface.withValues(alpha: .56)
                      : onSurface.withValues(alpha: .92),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool wide;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      width: wide ? 28.w : null,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: .55.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .06)
            : const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5.sp, color: ConstantColor.primaryColor),
          SizedBox(width: 1.w),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.semiboldTextStyle(context).copyWith(
                fontSize: 14.0.sp,
                color: onSurface.withValues(alpha: .86),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double? width;

  const StatCard(this.label, this.value, this.color, {super.key, this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final valueColor =
        isDark ? Color.lerp(color, Colors.white, 0.35) ?? color : color;

    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: .75.h),
      margin: EdgeInsets.symmetric(vertical: .2.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .05)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 14.0.sp,
                color: onSurface.withValues(alpha: .64),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.start),
          verticalSpace(height: .25.h),
          Text(value,
              style: AppStyles.semiboldTextStyle(context)
                  .copyWith(fontSize: 14.0.sp, color: valueColor),
              textAlign: TextAlign.start),
        ],
      ),
    );
  }
}
