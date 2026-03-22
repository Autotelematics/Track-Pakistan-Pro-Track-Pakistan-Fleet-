import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/vehicle_list_provider.dart';

class StatusBox extends StatelessWidget {
  final String statusKey;
  final String title;
  final int count;
  final Color color;
  final Color onSurface;
  final Color cardColor;

  const StatusBox({
    super.key,
    required this.statusKey,
    required this.title,
    required this.count,
    required this.color,
    required this.onSurface,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetDevicesListProvider>(context, listen: false);
    final isSelected = provider.filterStatus == statusKey;

    final countStr = count.toString();
    final digits = countStr.length;
    final baseCircleSize = 3.0.h;
    final circleSize =
        baseCircleSize + (digits > 3 ? (digits - 3) * 0.35.h : 0);
    final boxWidth = 14.6.w;
    final boxHeight = 3.2.h;

    return GestureDetector(
      onTap: () => provider.setFilter(statusKey),
      child: Padding(
        padding: EdgeInsets.only(right: 1.w),
        child: SizedBox(
          width: boxWidth,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: circleSize / 2,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: boxWidth,
                  height: boxHeight,
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.only(top: 1.6.h),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 12.2.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : onSurface.withOpacity(0.7),
                    ),
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
                    border: Border.all(
                      color: isSelected ? color : color.withOpacity(0.5),
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: Offset(0, 2))]
                        : null,
                  ),
                  child: Text(
                    countStr,
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 11.4.sp,
                      color: isSelected ? color : onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
