import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/providers/dashboard_provider.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class VehicleSummaryCard extends StatefulWidget {
  final GetDashboardModel data1;

  const VehicleSummaryCard({super.key, required this.data1});

  @override
  State<VehicleSummaryCard> createState() => _VehicleSummaryCardState();
}

class _VehicleSummaryCardState extends State<VehicleSummaryCard> {
  Key chartKey = UniqueKey();

  @override
  void didUpdateWidget(covariant VehicleSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      chartKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          if (isDark)
            BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.2),
                blurRadius: 16),
        ],
      ),
      child: Row(
        children: [
          _buildLegend(context),
          const Spacer(),
          _buildPieChart(context),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final status = widget.data1.statusCounts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Total Vehicles", style: AppStyles.regularTextStyle(context).copyWith(
          fontSize: 16.sp
        )),
        verticalSpace(height: 0.5.h),
        Text(
          status.total.toString(),
          style: AppStyles.boldTextStyle(context).copyWith(
            fontSize: 17.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        verticalSpace(height: .5.h),
        _legendItem(AppColors.red, "Offline", status.ack, 0, context),
        verticalSpace(height: 1.h),
        _legendItem(AppColors.green, "Online", status.online, 1, context),
        verticalSpace(height: 1.h),
        _legendItem(AppColors.yellow, "Idle", status.idle, 2, context),
        verticalSpace(height: 1.h),
        _legendItem(
            AppColors.grey, "Not Connected", status.neverConnected, 3, context),
      ],
    );
  }

  Widget _legendItem(
      Color color, String label, int count, int index, BuildContext context) {
    final provider = context.read<DashboardProvider>();

    return GestureDetector(
      onTap: () {
        provider.setSelectedStatusIndex(
          provider.selectedStatusIndex == index ? -1 : index,
        );
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              height: 2.2.h,
              width: 2.2.h,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(6)),
            ),
            horizontalSpace(width: 2.w),
            Text("$label $count",
                style: AppStyles.lightTextStyle(context)
                    .copyWith(fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    final status = widget.data1.statusCounts;

    return Container(
      key: chartKey,
      padding: EdgeInsets.only(right: 9.w),
      height: 13.h,
      width: 13.h,
      child: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          final selectedIndex = provider.selectedStatusIndex;
          int centerCount = status.total;
          if (selectedIndex != -1) {
            centerCount = switch (selectedIndex) {
              0 => status.ack,
              1 => status.online,
              2 => status.idle,
              3 => status.neverConnected,
              _ => status.total,
            };
          }

          return SfCircularChart(
            legend: const Legend(isVisible: false),
            series: <DoughnutSeries<ChartData, String>>[
              DoughnutSeries<ChartData, String>(
                dataSource: _getChartData(status, selectedIndex),
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                pointColorMapper: (ChartData data, _) => data.color,
                innerRadius: '55%',
                radius: '240%',
                animationDuration: 1000,
                enableTooltip: false,
                onPointTap: (ChartPointDetails details) {
                  final index = details.pointIndex!;
                  provider.setSelectedStatusIndex(index);
                },
                dataLabelSettings: const DataLabelSettings(isVisible: false),
              ),
            ],
            annotations: <CircularChartAnnotation>[
              CircularChartAnnotation(
                widget: Text(
                  centerCount.toString(),
                  style: AppStyles.boldTextStyle(context).copyWith(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<ChartData> _getChartData(dynamic status, int selectedIndex) {
    final data = [
      ChartData('Offline', status.ack.toDouble(), AppColors.red, 0),
      ChartData('Online', status.online.toDouble(), AppColors.green, 1),
      ChartData('Idle', status.idle.toDouble(), AppColors.yellow, 2),
      ChartData(
          'Not Connected', status.neverConnected.toDouble(), AppColors.grey, 3),
    ];

    if (selectedIndex != -1) {
      return data.map((item) {
        if (item.index != selectedIndex) {
          return ChartData(
              item.x, 0.001, item.color.withOpacity(0.15), item.index);
        }
        return item;
      }).toList();
    }
    return data;
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color, this.index);
  final String x;
  final double y;
  final Color color;
  final int index;
}
