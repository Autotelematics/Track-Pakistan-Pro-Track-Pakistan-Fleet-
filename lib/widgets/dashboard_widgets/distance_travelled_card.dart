import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/dashboard_data.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class DistanceTravelledCard extends StatelessWidget {
  final DashboardData data;

  const DistanceTravelledCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;
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
            "Distance Travelled",
            style: AppStyles.boldTextStyle(context)
                .copyWith(fontSize: 17.sp, fontWeight: FontWeight.w800),
          ),
          verticalSpace(height: 1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statColumn(context, "Total Distance", data.totalDistance),
              _statColumn(context, "Average Distance", data.averageDistance),
            ],
          ),
          verticalSpace(height: 0.4.h),
          verticalSpace(height: 2.h),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        space: 8.0,
                        child: Text(
                          data.barDays[value.toInt()],
                          style: TextStyle(
                            fontSize: 12,
                            color: onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: TextStyle(
                          fontSize: 10,
                          color: onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: true,
                  horizontalInterval: 20,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: onSurface.withOpacity(0.3), strokeWidth: 1),
                  getDrawingVerticalLine: (value) =>
                      FlLine(color: onSurface.withOpacity(0.3), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  data.barValues.length,
                      (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data.barValues[i],
                        width: 18,
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(BuildContext context, String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: AppStyles.regularTextStyle(context)
            .copyWith(fontWeight: FontWeight.w700),
      ),
      Text(
        value,
        style: AppStyles.lightTextStyle(context)
            .copyWith(fontSize: 15.sp, fontWeight: FontWeight.w700),
      ),
    ],
  );
}