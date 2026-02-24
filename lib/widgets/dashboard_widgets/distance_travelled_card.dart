import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_history_model.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class DistanceTravelledCard extends StatefulWidget {
  final GetDashboardHistoryModel historyData;

  const DistanceTravelledCard({super.key, required this.historyData});

  @override
  State<DistanceTravelledCard> createState() => _DistanceTravelledCardState();
}

class _DistanceTravelledCardState extends State<DistanceTravelledCard> {
  late List<bool> _isVisible;
  late List<double> _barValues;
  late List<String> _barLabels;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _animateBars();
  }

  void _initializeData() {
    final topDistances = widget.historyData.summary.topDistance;
    _barValues = topDistances.map((td) => td.distanceKm).toList();
    _barLabels = topDistances.map((td) => td.deviceName).toList();
    _isVisible = List.generate(_barValues.length, (_) => false);
  }

  void _animateBars() {
    for (int i = 0; i < _barValues.length; i++) {
      Timer(Duration(milliseconds: i * 300), () {
        if (mounted) {
          setState(() => _isVisible[i] = true);
        }
      });
    }
  }

  String _shortenLabel(String label) {
    if (label.length <= 8) return label;
    return '${label.substring(0, 8)}...';
  }

  double _getMaxY() {
    if (_barValues.isEmpty) return 100.0;
    final max = _barValues.reduce((a, b) => a > b ? a : b);
    return max * 1.2;
  }

  double _getYInterval() {
    final maxY = _getMaxY();
    return maxY / 4;
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;
    final maxY = _getMaxY();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 3.w),
      margin: EdgeInsets.symmetric(horizontal: 6.w),
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
            style: AppStyles.semiboldTextStyle(context),
          ),
          verticalSpace(height: 1.5.h),
          _buildStatRow(context),
          verticalSpace(height: 2.h),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(enabled: true),
                titlesData: _buildTitlesData(onSurface),
                gridData: _buildGridData(onSurface),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _statColumn(
        context,
        "Total Distance",
        "${widget.historyData.summary.totalDistanceKm} km",
      ),
      _statColumn(
        context,
        "Average Distance",
        "${widget.historyData.summary.averageDistanceKm} km",
      ),
    ],
  );

  Widget _statColumn(BuildContext context, String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppStyles.regularTextStyle(context).copyWith(fontSize: 15.sp),
      ),
      Text(
        value,
        style: AppStyles.lightTextStyle(context).copyWith(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );

  FlTitlesData _buildTitlesData(Color onSurface) {
    final yInterval = _getYInterval();
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= _barLabels.length) return const SizedBox();
            return SideTitleWidget(
              meta: meta,
              child: Text(
                _shortenLabel(_barLabels[index]),
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 12.sp,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: yInterval,
          reservedSize: 36,
          getTitlesWidget: (value, meta) => Text(
            '${value.toInt()}',
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlGridData _buildGridData(Color onSurface) {
    final yInterval = _getYInterval();
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: true,
      horizontalInterval: yInterval,
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) => FlLine(
        color: onSurface.withOpacity(0.3),
        strokeWidth: 1,
      ),
      getDrawingVerticalLine: (value) => FlLine(
        color: onSurface.withOpacity(0.3),
        strokeWidth: 1,
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() => List.generate(
    _barValues.length,
        (i) => BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: _isVisible[i] ? _barValues[i] : 0.0,
          width: 18,
          color: Colors.blue,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    ),
  );
}