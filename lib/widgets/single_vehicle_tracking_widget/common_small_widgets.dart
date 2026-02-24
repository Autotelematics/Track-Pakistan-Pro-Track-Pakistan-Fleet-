import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/app/theme/popups.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
class MovingChip extends StatelessWidget {
  final String text;
  final Color? color;
  const MovingChip({super.key, this.text = "Moving", this.color,});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = (isDark ? theme.cardColor : AppColors.white);
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
            decoration: BoxDecoration(
                color: text == "Moving" ? AppColors.green : AppColors.red,
                shape: BoxShape.circle),
            child: Icon(Icons.arrow_upward_rounded,
                size: 1.6.h, color: AppColors.white),
          ),
          horizontalSpace(width: 2.w),
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

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const InfoTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tileColor = isDark ? Colors.grey.shade900 : Colors.white;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final shadowColor = isDark ? Colors.black45 : Colors.grey.shade200;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 2.6.h,
            color: isDark ? Colors.white : Colors.blue.shade700,
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          verticalSpace(height: 0.4.h),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class VehicleBasicInfo extends StatelessWidget {
  final String deviceName;
  final String? licensePlate;
  final String deviceAddress;
  final String deviceLatestUpdate;
  final int deviceSpeed;

  const VehicleBasicInfo({
    super.key,
    required this.deviceName,
    this.licensePlate,
    required this.deviceSpeed,
    required this.deviceLatestUpdate,
    required this.deviceAddress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.white : AppColors.textBlack;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.directions_car_filled_outlined,
                      size: 3.h, color: AppColors.textBlack),
                  horizontalSpace(width: 2.w),
                  Text(
                      deviceName.length > 13
                          ? "${deviceName.substring(0, 13)}..."
                          : deviceName,
                      style: AppStyles.regularTextStyle(context)
                          .copyWith(fontSize: 17.sp, color: textColor))
                ],
              ),
              verticalSpace(height: 1.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.access_alarms_rounded,
                      size: 3.h, color: AppColors.textBlack),
                  horizontalSpace(width: 2.w),
                  Text(
                    deviceLatestUpdate,
                    style: AppStyles.address(context)
                        .copyWith(fontSize: 15.sp, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              verticalSpace(height: 1.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 3.h, color: AppColors.textBlack),
                  horizontalSpace(width: 2.w),
                  Expanded(
                    child: Text(
                      deviceAddress.length > 80
                          ? "${deviceAddress.substring(0, 80)}..."
                          : deviceAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.address(context).copyWith(
                          fontSize: 15.sp, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 14.h,
            child: _speedoMeter(deviceSpeed.toDouble()),
          ),
        ),
      ],
    );
  }

  Widget _speedoMeter(double value) {
    return SfRadialGauge(
      axes: [
        RadialAxis(
          minimum: 0,
          maximum: 180,
          showTicks: false,
          showLabels: true,
          labelFormat: "{value}",
          interval: 40,
          axisLabelStyle: GaugeTextStyle(
            fontSize: 13.sp,
            color: AppColors.textBlack,
          ),
          axisLineStyle: AxisLineStyle(
            color: Colors.grey.shade300,
            thickness: 0.15,
            thicknessUnit: GaugeSizeUnit.factor,
            cornerStyle: CornerStyle.bothCurve,
          ),
          ranges: [
            GaugeRange(
              startValue: 0,
              endValue: 60,
              color: Colors.green,
              startWidth: 0.15,
              endWidth: 0.15,
              sizeUnit: GaugeSizeUnit.factor,
            ),
            GaugeRange(
              startValue: 60,
              endValue: 120,
              color: Colors.orange,
              startWidth: 0.15,
              endWidth: 0.15,
              sizeUnit: GaugeSizeUnit.factor,
            ),
            GaugeRange(
              startValue: 120,
              endValue: 180,
              color: Colors.red,
              startWidth: 0.15,
              endWidth: 0.15,
              sizeUnit: GaugeSizeUnit.factor,
            ),
          ],
          pointers: [
            NeedlePointer(
              value: value,
              needleStartWidth: 0,
              needleEndWidth: 4,
              tailStyle: TailStyle(
                width: 4,
                length: 0.1,
              ),
            )
          ],
          annotations: [
            GaugeAnnotation(
              positionFactor: 0.9,
              angle: 90,
              widget: Text(
                "${value.toInt()} km/h",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BottomActions extends StatelessWidget {
  final String deviceId;
  const BottomActions({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? theme.cardColor : AppColors.green;
    final textColor = AppColors.white ;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: (){
              showDriverDetailPopup(context, deviceId: deviceId);
            },
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
                  Icon(Icons.call, color: textColor),
                  SizedBox(width: 1.w),
                  Text("Call To Driver",
                      style: AppStyles.regularTextStyle(context)
                          .copyWith(color: textColor)),
                ],
              ),
            ),
          ),
        ),
        horizontalSpace(width: 3.w),
        Expanded(
          child: GestureDetector(
            onTap: (){
              showDeviceCommandsPopup(context,deviceId);
            },
            child: Container(
              height: 5.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ConstantColor.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.electric_bolt, color: AppColors.white),
                  horizontalSpace(width: 1.w),
                  Text("IMMOBILIZER",
                      style: AppStyles.regularTextStyle(context)
                          .copyWith(color: AppColors.white)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
