import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/dashboard_data.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class FleetAlertsCard extends StatelessWidget {
  final DashboardData data;

  const FleetAlertsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Fleet Alerts",
            style: AppStyles.boldTextStyle(context)
                .copyWith(fontSize: 17.sp, fontWeight: FontWeight.w800),
          ),
          verticalSpace(height: 1.5.h),
          Column(
            children: data.dummyAlertData
                .map(
                  (alertData) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alertData.label,
                      style: AppStyles.regularTextStyle(context)
                          .copyWith(fontSize: 15.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: LinearProgressIndicator(
                            value: alertData.value / alertData.total,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                            minHeight: 6,
                          ),
                        ),
                        horizontalSpace(width: 4.w),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${alertData.value}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: onSurface.withOpacity(0.8),
                            ),
                          ),
                        ),
                        horizontalSpace(width: 2.w),
                        Icon(
                          Icons.chevron_right,
                          size: 20.sp,
                          color: onSurface.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }
}