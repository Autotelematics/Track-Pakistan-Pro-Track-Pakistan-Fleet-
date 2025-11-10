import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/vehicle_data.dart';

class StatusBox extends StatelessWidget {
  final StatusData status;
  final Color onSurface;
  final Color cardColor;
  final double boxWidth = 15.5.w;
  final double boxHeight = 3.5.h;
  final double baseCircleSize = 3.4.h;

   StatusBox({
    super.key,
    required this.status,
    required this.onSurface,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final countStr = status.count.toString();
    final digits = countStr.length;
    final circleSize = baseCircleSize + (digits > 3 ? (digits - 3) * 0.4.h : 0);

    return Padding(
      padding: EdgeInsets.only(right: 1.w),
      child: SizedBox(
        width: boxWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: circleSize / 2,
              child: Container(
                width: boxWidth,
                height: boxHeight,
                decoration: BoxDecoration(
                  color: status.color,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.only(top: 1.6.h),
                child: Text(
                  status.title,
                  textAlign: TextAlign.center,
                  style: AppStyles.statusTitle(context),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: (boxWidth - circleSize) / 2,
              child: Container(
                width: circleSize,
                height: circleSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardColor,
                  border: Border.all(color: status.color, width: 2),
                ),
                child: Text(
                  countStr,
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: 13.sp,
                    color: onSurface
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}