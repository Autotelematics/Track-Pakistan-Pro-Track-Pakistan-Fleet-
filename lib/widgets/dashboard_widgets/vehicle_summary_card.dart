// widgets/vehicle_summary_card.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/dashboard_data.dart';
import 'package:trackerapp/providers/dashboard_provider.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class VehicleSummaryCard extends StatelessWidget {
  final DashboardData data;

  const VehicleSummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.6)     // Deep shadow in dark
                : Colors.black.withOpacity(0.12),   // Soft in light
            blurRadius: isDark ? 16 : 10,
            spreadRadius: isDark ? 1 : 0,
            offset: const Offset(0, 4),
          ),
          if (isDark)
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ), // Subtle glow in dark
        ],
      ),
      child: Row(
        children: [
          _vehicleLegend(context),
          const Spacer(),
          _vehicleChart(context),
          horizontalSpace(width: 5.w),
        ],
      ),
    );
  }

  // === REST OF YOUR CODE (UNCHANGED) ===
  Widget _vehicleLegend(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Total Vehicles", style: AppStyles.regularTextStyle(context)),
      Text(
        data.totalVehicles,
        style: AppStyles.lightTextStyle(context).copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
      verticalSpace(height: 1.h),
      ...data.chartData.map(
            (item) => Padding(
          padding: EdgeInsets.only(bottom: 1.h),
          child: _legendRow(item.color, item.label, context),
        ),
      ),
    ],
  );

  Widget _vehicleChart(BuildContext context) => Consumer<DashboardProvider>(
    builder: (context, provider, child) => SizedBox(
      height: 10.h,
      width: 10.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 7.w),
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, pieTouchResponse) {
                    final index = pieTouchResponse?.touchedSection?.touchedSectionIndex ?? -1;
                    Provider.of<DashboardProvider>(context, listen: false).setTouchedIndex(index);
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: _buildPieSections(provider.touchedIndex),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 7.w),
            child: Text(
              data.totalVehicles,
              style: AppStyles.boldTextStyle(context),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _legendRow(Color color, String label, BuildContext context) => Row(
    children: [
      Container(
        height: 2.5.h,
        width: 1.6.w,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      horizontalSpace(width: 1.5.w),
      Text(label, style: AppStyles.lightTextStyle(context)),
    ],
  );

  List<PieChartSectionData> _buildPieSections(int touchedIndex) => List.generate(
    data.chartData.length,
        (i) => PieChartSectionData(
      color: data.chartData[i].color,
      value: data.chartData[i].value,
      title: data.chartData[i].percent,
      showTitle: false,
      radius: i == touchedIndex ? 60.0 : 30.0,
    ),
  );
}