import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class AlertGrid extends StatelessWidget {
  final GetDashboardModel data;

  const AlertGrid({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final alerts = [
      {
        'icon': Icons.speed,
        'name': 'Over Speed',
        'unit': 'Times',
        'value': data.alertsSummary.overSpeed.toString(),
        'bgColor': const Color(0xFFFFC107),
      },
      {
        'icon': Icons.timer_outlined,
        'name': 'Idle Duration',
        'unit': 'Times',
        'value': data.alertsSummary.idleDuration.toString(),
        'bgColor': const Color(0xFFFF9800),
      },
      {
        'icon': Icons.power_settings_new,
        'name': 'Ignition duration',
        'unit': 'Times',
        'value': data.alertsSummary.ignitionDuration.toString(),
        'bgColor': const Color(0xFFEF5350),
      },
      {
        'icon': Icons.directions_car,
        'name': 'Move Start',
        'unit': 'Times',
        'value': data.alertsSummary.moveStart.toString(),
        'bgColor': const Color(0xFF4CAF50),
      },
      {
        'icon': Icons.signal_wifi_off,
        'name': 'Offline duration',
        'unit': 'Times',
        'value': data.alertsSummary.offlineDuration.toString(),
        'bgColor': const Color(0xFF009688),
      },
      {
        'icon': Icons.local_parking,
        'name': 'Over Parking',
        'unit': 'Times',
        'value': data.alertsSummary.overParking.toString(),
        'bgColor': const Color(0xFF6A1B9A),
      },
      // {
      //   'icon': Icons.fence, // Custom (Geofence style)
      //   'name': 'Custom',
      //   'unit': 'Times',
      //   'value': data.alertsSummary.custom.toString(),
      //   'bgColor': const Color(0xFF2196F3),
      // },
    ];

    return Column(
      children: [
        _alertFilterRow(context),
        verticalSpace(height: .6.h),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.85,
            ),
            itemBuilder: (context, index) {
              final item = alerts[index];

              return Container(
                padding: EdgeInsets.symmetric(
                  vertical: 1.6.h,
                  horizontal: 3.w,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14.px),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: item['bgColor'] as Color,
                            borderRadius: BorderRadius.circular(6.px),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            size: 2.8.h,
                            color: Colors.white,
                          ),
                        ),
                        horizontalSpace(width: 1.h),
                        Expanded(
                          child: Text(
                            item['name'] as String,
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 15.sp
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: EdgeInsets.only(left: .5.h),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${item['value']}  ',
                              style: AppStyles.regularTextStyle(context)
                                  .copyWith(fontSize: 15.sp),
                            ),
                            TextSpan(
                              text: item['unit'] as String,
                              style: AppStyles.regularTextStyle(context)
                                  .copyWith(fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _alertFilterRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 9.w),
      child: Row(
        children: [
          Text(
            "Alerts Count",
            style: AppStyles.semiboldTextStyle(context),
          ),
          const Spacer(),
          Text(
            "(${data.alertsSummary.total.toString()})",
            style: AppStyles.semiboldTextStyle(context)
                .copyWith(fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
