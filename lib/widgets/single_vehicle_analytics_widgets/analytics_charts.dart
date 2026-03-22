import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/providers/single_vehicle_analytics_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';

import 'analytics_graph_container.dart';

CategoryAxis _xAxis(bool isMultiDay) => CategoryAxis(
  labelStyle: TextStyle(fontSize: 11.sp),
  majorGridLines: const MajorGridLines(width: 0),
  labelRotation: isMultiDay ? -30 : 0,
  labelIntersectAction: AxisLabelIntersectAction.rotate45,
);

NumericAxis _yAxis(String format) => NumericAxis(
  minimum: 0,
  labelFormat: format,
  majorGridLines: MajorGridLines(
    dashArray: const [4, 4],
    color: Colors.grey.withOpacity(0.3),
  ),
);

class AnalyticsSpeedChart extends StatelessWidget {
  final SingleVehicleAnalyticsProvider provider;
  final bool isMultiDay;
  final TooltipBehavior tooltip;

  const AnalyticsSpeedChart({
    super.key,
    required this.provider,
    required this.isMultiDay,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticsGraphContainer(
      title: isMultiDay
          ? context.l10n.maxSpeedPerDay
          : context.l10n.speedKmh,
      isEmpty: provider.speedChartData.isEmpty,
      child: SfCartesianChart(
        tooltipBehavior: tooltip,
        primaryXAxis: _xAxis(isMultiDay),
        primaryYAxis: _yAxis('{value}'),
        series: <SplineSeries<AnalyticsChartData, String>>[
          SplineSeries(
            dataSource: provider.speedChartData,
            xValueMapper: (d, _) => d.label,
            yValueMapper: (d, _) => d.value,
            width: 3,
            color: AppColors.blueCyan,
            enableTooltip: true,
            markerSettings: MarkerSettings(
              isVisible: true,
              color: AppColors.blueCyan,
              borderColor: AppColors.white,
              borderWidth: 2,
              height: 10,
              width: 10,
              shape: DataMarkerType.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsDistanceChart extends StatelessWidget {
  final SingleVehicleAnalyticsProvider provider;
  final bool isMultiDay;
  final TooltipBehavior tooltip;

  const AnalyticsDistanceChart({
    super.key,
    required this.provider,
    required this.isMultiDay,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticsGraphContainer(
      title: isMultiDay
          ? context.l10n.distancePerDay
          : context.l10n.distanceKm,
      isEmpty: provider.distanceChartData.isEmpty,
      child: SfCartesianChart(
        tooltipBehavior: tooltip,
        primaryXAxis: _xAxis(isMultiDay),
        primaryYAxis: _yAxis('{value}'),
        series: <SplineAreaSeries<AnalyticsChartData, String>>[
          SplineAreaSeries(
            dataSource: provider.distanceChartData,
            xValueMapper: (d, _) => d.label,
            yValueMapper: (d, _) => d.value,
            enableTooltip: true,
            gradient: LinearGradient(
              colors: [
                AppColors.green.withOpacity(0.5),
                AppColors.green.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderColor: AppColors.green,
            borderWidth: 3,
            markerSettings: MarkerSettings(
              isVisible: true,
              color: AppColors.green,
              borderColor: AppColors.white,
              borderWidth: 2,
              height: 10,
              width: 10,
            ),
          ),
        ],
      ),
    );
  }
}


class AnalyticsFuelChart extends StatelessWidget {
  final SingleVehicleAnalyticsProvider provider;
  final TooltipBehavior tooltip;

  const AnalyticsFuelChart({
    super.key,
    required this.provider,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticsGraphContainer(
      title: context.l10n.fuelUsedLiters,
      isEmpty: provider.fuelChartData.isEmpty,
      child: SfCartesianChart(
        tooltipBehavior: tooltip,
        primaryXAxis: _xAxis(false),
        primaryYAxis: _yAxis('{value}'),
        series: <SplineSeries<AnalyticsChartData, String>>[
          SplineSeries(
            dataSource: provider.fuelChartData,
            xValueMapper: (d, _) => d.label,
            yValueMapper: (d, _) => d.value,
            width: 3,
            color: AppColors.yellow,
            enableTooltip: true,
            markerSettings: MarkerSettings(
              isVisible: true,
              color: AppColors.yellow,
              borderColor: AppColors.white,
              borderWidth: 2,
              height: 10,
              width: 10,
            ),
          ),
        ],
      ),
    );
  }
}


class AnalyticsStopDurationChart extends StatelessWidget {
  final SingleVehicleAnalyticsProvider provider;
  final TooltipBehavior tooltip;

  const AnalyticsStopDurationChart({
    super.key,
    required this.provider,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticsGraphContainer(
      title: context.l10n.stopDurationMinutes,
      isEmpty: provider.stopDurationChartData.isEmpty,
      child: SfCartesianChart(
        tooltipBehavior: tooltip,
        primaryXAxis: CategoryAxis(
          labelStyle: TextStyle(fontSize: 11.sp),
          majorGridLines: const MajorGridLines(width: 0),
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
        ),
        primaryYAxis: _yAxis('{value}m'),
        series: <ColumnSeries<AnalyticsBarChartData, String>>[
          ColumnSeries(
            dataSource: provider.stopDurationChartData,
            xValueMapper: (d, _) => d.label,
            yValueMapper: (d, _) => d.value,
            width: 0.5,
            spacing: 0.2,
            enableTooltip: true,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5.px),
              topRight: Radius.circular(5.px),
            ),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class AnalyticsEngineHoursChart extends StatelessWidget {
  final SingleVehicleAnalyticsProvider provider;
  final bool isMultiDay;
  final TooltipBehavior tooltip;

  const AnalyticsEngineHoursChart({
    super.key,
    required this.provider,
    required this.isMultiDay,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticsGraphContainer(
      title: isMultiDay
          ? context.l10n.engineHoursPerDay
          : context.l10n.engineHoursCumulative,
      isEmpty: provider.engineHoursChartData.isEmpty,
      child: SfCartesianChart(
        tooltipBehavior: tooltip,
        primaryXAxis: _xAxis(isMultiDay),
        primaryYAxis: _yAxis('{value}h'),
        series: <SplineAreaSeries<AnalyticsChartData, String>>[
          SplineAreaSeries(
            dataSource: provider.engineHoursChartData,
            xValueMapper: (d, _) => d.label,
            yValueMapper: (d, _) => d.value,
            enableTooltip: true,
            gradient: LinearGradient(
              colors: [
                AppColors.purple.withOpacity(0.5),
                AppColors.purple.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderColor: AppColors.purple,
            borderWidth: 3,
            markerSettings: MarkerSettings(
              isVisible: true,
              color: AppColors.purple,
              borderColor: AppColors.white,
              borderWidth: 2,
              height: 10,
              width: 10,
            ),
          ),
        ],
      ),
    );
  }
}
