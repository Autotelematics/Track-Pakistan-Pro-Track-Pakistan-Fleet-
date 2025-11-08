import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';

/// Back button circle used in topbar
class BackButtonCircle extends StatelessWidget {
  final VoidCallback? onTap;
  const BackButtonCircle({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? theme.cardColor : AppColors.white;
    final shadow = isDark ? Colors.black26 : AppColors.grey.withOpacity(.5);
    final iconColor = isDark ? AppColors.white : AppColors.textBlack;

    return InkWell(
      onTap: onTap ?? () => Navigator.maybePop(context),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 5.h,
        width: 5.h,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: shadow,
              offset: const Offset(0, 5),
              spreadRadius: 3,
              blurRadius: 5,
            )
          ],
        ),
        child: Icon(Icons.arrow_back, size: 2.2.h, color: iconColor),
      ),
    );
  }
}

/// Chip that shows moving/idle status
class MovingChip extends StatelessWidget {
  final String text;
  final Color? color;
  const MovingChip({super.key, this.text = "Moving", this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = color ?? (isDark ? theme.cardColor : AppColors.white);
    final shadow = isDark ? Colors.black26 : AppColors.grey.withOpacity(.35);
    final textColor = isDark ? AppColors.white : AppColors.textBlack;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: .6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.px),
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(.6.h),
            decoration:  BoxDecoration(
                color: AppColors.blueCyan, shape: BoxShape.circle),
            child: Icon(Icons.arrow_upward_rounded,
                size: 1.6.h, color: AppColors.white),
          ),
          SizedBox(width: 2.w),
          Text(
            text,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 15.sp,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Right-side vertical buttons (share, map, location, zoom)
class RightSideButtons extends StatelessWidget {
  const RightSideButtons({super.key});

  Widget _circle(BuildContext context, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? theme.cardColor : AppColors.white;
    final shadow = isDark ? Colors.black26 : AppColors.grey.withOpacity(.5);
    final iconColor = isDark ? AppColors.white : AppColors.textBlack;

    return Container(
      height: 5.h,
      width: 5.h,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: shadow,
            offset: const Offset(0, 5),
            spreadRadius: 3,
            blurRadius: 5,
          )
        ],
      ),
      child: Icon(icon, size: 2.2.h, color: iconColor),
    );
  }

  Widget _sideZoom(BuildContext context, bool top, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? theme.cardColor : AppColors.white;
    final shadow = isDark ? Colors.black26 : AppColors.grey.withOpacity(.5);
    final iconColor = isDark ? AppColors.white : AppColors.textBlack;

    return Container(
      height: 4.h,
      width: 3.6.h,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(
          top: top ? const Radius.circular(20) : Radius.zero,
          bottom: !top ? const Radius.circular(20) : Radius.zero,
        ),
        boxShadow: [
          BoxShadow(
            color: shadow,
            offset: const Offset(0, 5),
            spreadRadius: 3,
            blurRadius: 5,
          )
        ],
      ),
      child: Icon(icon, size: 2.6.h, color: iconColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _circle(context, Icons.share),
        SizedBox(height: 1.5.h),
        _circle(context, Icons.map_outlined),
        SizedBox(height: 1.5.h),
        _circle(context, Icons.my_location_outlined),
        SizedBox(height: 1.5.h),
        _sideZoom(context, true, Icons.add),
        SizedBox(height: .3.h),
        _sideZoom(context, false, Icons.remove),
      ],
    );
  }
}

/// Info tile used inside bottom card
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const InfoTile(
      {super.key,
        required this.icon,
        required this.value,
        required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? theme.cardColor : AppColors.white;
    final border = isDark ? AppColors.grey : AppColors.grey;
    final iconColor = isDark ? AppColors.white : AppColors.textBlack;
    final valueColor = isDark ? AppColors.white : AppColors.textBlack;
    final labelColor = AppColors.grey;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: .8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.px),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 2.3.h, color: iconColor),
          SizedBox(height: .6.h),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  color: valueColor)),
          SizedBox(height: .4.h),
          Text(label,
              style: TextStyle(color: labelColor, fontSize: 14.sp)),
        ],
      ),
    );
  }
}

/// Basic vehicle info row inside bottom card
class VehicleBasicInfo extends StatelessWidget {
  const VehicleBasicInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.white : AppColors.textBlack;
    final subColor = AppColors.grey;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 1.5.h,
                    backgroundColor: AppColors.blueCyan,
                    child: Icon(Icons.directions_car,
                        size: 1.7.h, color: AppColors.white),
                  ),
                  SizedBox(width: 2.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("BMW X6",
                          style: AppStyles.regularTextStyle(context)
                              .copyWith(fontSize: 17.sp, color: textColor)),
                      Text("AG 5758 SS",
                          style: AppStyles.regularTextStyle(context)
                              .copyWith(color: subColor)),
                    ],
                  )
                ],
              ),
              SizedBox(height: 1.h),
              Padding(
                padding: EdgeInsets.only(left: 2.w),
                child: Row(
                  children: [
                    for (int i = 0; i < 5; i++)
                      Container(
                        margin: EdgeInsets.only(right: 1.w),
                        height: 2.7.h,
                        width: 3.w,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    SizedBox(width: 2.w),
                    Icon(Icons.local_gas_station,
                        size: 3.h, color: textColor),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 10.h,
            child: Center(
              child: Transform.scale(
                scale: 6,
                child: Icon(Icons.directions_car, color: AppColors.blueCyan),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom action buttons
class BottomActions extends StatelessWidget {
  const BottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? theme.cardColor : AppColors.white;
    final textColor = isDark ? AppColors.white : AppColors.textBlack;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 5.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12.px),
                border: Border.all(color: AppColors.grey)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications, color: textColor),
                SizedBox(width: 1.w),
                Text("Ring On",
                    style: AppStyles.regularTextStyle(context)
                        .copyWith(color: textColor)),
              ],
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Container(
            height: 5.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.blueCyan,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.electric_bolt, color: AppColors.white),
                SizedBox(width: 1.w),
                Text("Stop Engine",
                    style: AppStyles.regularTextStyle(context)
                        .copyWith(color: AppColors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}