import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/get_device_history_provider.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? ConstantColor.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10.sp),
          border: Border.all(
            color: isSelected ? ConstantColor.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18.sp,
                color: isSelected ? Colors.white : Colors.grey.shade600),
            horizontalSpace(width: 1.5.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey.shade700,
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.4.h),
        decoration: BoxDecoration(
          color: isSelected
              ? ConstantColor.primaryColor.withOpacity(0.07)
              : Colors.white,
          borderRadius: BorderRadius.circular(14.sp),
          border: Border.all(
            color: isSelected ? ConstantColor.primaryColor : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color:  Colors.white,
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
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
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
                          trip.endTime,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.8.h),
                  Wrap(
                    spacing: 2.w,
                    children: [
                      MiniChip(icon: Icons.straighten, label: '${trip.distance} km'),
                      MiniChip(icon: Icons.timer_outlined, label: trip.duration),
                    ],
                  ),
                ],
              ),
            ),
            // Play button
            GestureDetector(
              onTap: onPlay,
              child: Container(alignment: Alignment.center,
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
                      color: Colors.green.withOpacity(0.3),
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

class MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const MiniChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6.sp),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: Colors.grey.shade600),
          SizedBox(width: 1.w),
          Text(label,
              style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500)),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10.sp),
          border: Border.all(color: ConstantColor.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: ConstantColor.primaryColor),
            horizontalSpace(width: 2.w),
            Expanded(
              child: Text(
                text,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 14.sp,
                  color: text.contains("Select")
                      ? Colors.grey.shade500
                      : Colors.black87,
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

  const InfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: ConstantColor.primaryColor),
        SizedBox(width: 1.w),
        Text(label,
            style: AppStyles.semiboldTextStyle(context)
                .copyWith(fontSize: 15.sp)),
      ],
    );
  }
}
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatCard(this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
      width: 40.w,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10.sp),
        border: Border.all(color: ConstantColor.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(label,
              style: AppStyles.regularTextStyle(context)
                  .copyWith(fontSize: 16.sp, color: Colors.grey.shade600),
              textAlign: TextAlign.center),
          Text(value,
              style: AppStyles.boldTextStyle(context)
                  .copyWith(fontSize: 15.sp, color: color),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}