import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_history_model.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
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
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;
    final isDark = theme.brightness == Brightness.dark;
    final maxY = _getMaxY();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 3.5.w),
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.55)
                : Colors.black.withOpacity(0.12),
            blurRadius: isDark ? 14 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.distanceTravelled,
            style:
                AppStyles.semiboldTextStyle(context).copyWith(fontSize: 15.sp),
          ),
          verticalSpace(height: 1.1.h),
          _buildStatRow(context),
          verticalSpace(height: 1.5.h),
          Container(
            height: 24.h,
            padding: EdgeInsets.only(
              left: 2.w,
              right: 2.w,
              top: 1.2.h,
              bottom: .6.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: onSurface.withOpacity(0.08)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.02),
                        Colors.white.withOpacity(0.01),
                      ]
                    : [
                        Colors.white.withOpacity(0.95),
                        Colors.grey.shade50,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.25)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: _buildTouchData(context, isDark),
                titlesData: _buildTitlesData(onSurface),
                gridData: _buildGridData(onSurface),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(onSurface),
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
            context.l10n.totalDistance,
            "${widget.historyData.summary.totalDistanceKm} km",
          ),
          _statColumn(
            context,
            context.l10n.averageDistance,
            "${widget.historyData.summary.averageDistanceKm} km",
          ),
        ],
      );

  Widget _statColumn(BuildContext context, String label, String value) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                AppStyles.regularTextStyle(context).copyWith(fontSize: 14.sp),
          ),
          Text(
            value,
            style: AppStyles.lightTextStyle(context).copyWith(
              fontSize: 14.sp,
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
            if (index < 0 || index >= _barLabels.length) {
              return const SizedBox();
            }
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
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  BarTouchData _buildTouchData(BuildContext context, bool isDark) {
    return BarTouchData(
      enabled: true,
      handleBuiltInTouches: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipBorderRadius: BorderRadius.circular(12),
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        tooltipMargin: 10,
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipColor: (_) =>
            isDark ? const Color(0xFF1F2937) : const Color(0xFF111827),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final index = group.x.toInt();
          final label = index >= 0 && index < _barLabels.length
              ? _barLabels[index]
              : context.l10n.vehicleFallback;
          return BarTooltipItem(
            '${_shortenLabel(label)}\n',
            AppStyles.semiboldTextStyle(context).copyWith(
              color: Colors.white,
              fontSize: 12.sp,
            ),
            children: [
              TextSpan(
                text: '${rod.toY.toStringAsFixed(1)} km',
                style: AppStyles.regularTextStyle(context).copyWith(
                  color: Colors.white.withOpacity(0.92),
                  fontSize: 11.5.sp,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  FlGridData _buildGridData(Color onSurface) {
    final yInterval = _getYInterval();
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: false,
      horizontalInterval: yInterval,
      getDrawingHorizontalLine: (value) => FlLine(
        color: onSurface.withOpacity(0.16),
        strokeWidth: 1.1,
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(Color onSurface) => List.generate(
        _barValues.length,
        (i) => BarChartGroupData(
          x: i,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: _isVisible[i] ? _barValues[i] : 0.0,
              width: 14,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: i.isEven
                    ? [const Color(0xFF3B82F6), const Color(0xFF22D3EE)]
                    : [const Color(0xFF6366F1), const Color(0xFFA78BFA)],
              ),
              borderRadius: BorderRadius.circular(7),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: _getMaxY(),
                color: onSurface.withOpacity(0.06),
              ),
            ),
          ],
        ),
      );
}
