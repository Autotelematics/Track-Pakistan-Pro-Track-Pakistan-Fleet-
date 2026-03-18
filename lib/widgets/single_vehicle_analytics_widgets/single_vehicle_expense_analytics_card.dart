import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/single_vehicle_expense_analytics_provider.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class SingleVehicleExpenseAnalyticsCard extends StatefulWidget {
  final int deviceId;
  final String vehicleName;

  const SingleVehicleExpenseAnalyticsCard({
    super.key,
    required this.deviceId,
    required this.vehicleName,
  });

  @override
  State<SingleVehicleExpenseAnalyticsCard> createState() =>
      _SingleVehicleExpenseAnalyticsCardState();
}

class _SingleVehicleExpenseAnalyticsCardState
    extends State<SingleVehicleExpenseAnalyticsCard> {
  late final SingleVehicleExpenseAnalyticsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider =
        SingleVehicleExpenseAnalyticsProvider(deviceId: widget.deviceId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.initialize();
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ChangeNotifierProvider<SingleVehicleExpenseAnalyticsProvider>.value(
      value: _provider,
      child: Consumer<SingleVehicleExpenseAnalyticsProvider>(
        builder: (context, provider, _) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.05.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF101A2A) : Colors.white,
              borderRadius: BorderRadius.circular(14.sp),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? .22 : .08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: provider.isLoading
                ? SizedBox(
                    height: 24.h,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : provider.error != null
                    ? _ErrorBlock(
                        error: provider.error!, onRetry: provider.refresh)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Expense Analytics",
                                  style: AppStyles.boldTextStyle(context)
                                      .copyWith(fontSize: 14.6.sp),
                                ),
                              ),
                              IconButton(
                                onPressed: () => provider.exportSummary(
                                  vehicleName: widget.vehicleName,
                                ),
                                icon: const Icon(Icons.ios_share_rounded),
                                tooltip: "Export",
                              ),
                            ],
                          ),
                          _PresetBar(provider: provider),
                          verticalSpace(height: .8.h),
                          _KpiRow(provider: provider),
                          verticalSpace(height: .9.h),
                          _SectionTitle(title: "Expense Trend"),
                          verticalSpace(height: .4.h),
                          _TrendChart(provider: provider),
                          verticalSpace(height: .9.h),
                          _SectionTitle(title: "Top Expense Types"),
                          verticalSpace(height: .4.h),
                          _TypeBar(provider: provider),
                          verticalSpace(height: .9.h),
                          _SectionTitle(title: "Recent Activity"),
                          verticalSpace(height: .4.h),
                          _RecentList(provider: provider),
                        ],
                      ),
          );
        },
      ),
    );
  }
}

class _PresetBar extends StatelessWidget {
  final SingleVehicleExpenseAnalyticsProvider provider;
  const _PresetBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final maxSelectableDate = DateTime(now.year, now.month, now.day);
    final items = <(SingleExpenseRangePreset, String)>[
      (SingleExpenseRangePreset.today, "Today"),
      (SingleExpenseRangePreset.sevenDays, "7D"),
      (SingleExpenseRangePreset.thirtyDays, "30D"),
      (SingleExpenseRangePreset.thisMonth, "Month"),
      (SingleExpenseRangePreset.custom, "Custom"),
    ];
    return Column(
      children: [
        Wrap(
          spacing: 1.6.w,
          runSpacing: .45.h,
          children: items
              .map(
                (item) => ChoiceChip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(
                    horizontal: -2,
                    vertical: -2,
                  ),
                  labelPadding: EdgeInsets.symmetric(horizontal: 1.6.w),
                  side: BorderSide(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: .18),
                  ),
                  label: Text(
                    item.$2,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 12.9.sp,
                    ),
                  ),
                  selected: provider.preset == item.$1,
                  onSelected: (_) async {
                    if (item.$1 == SingleExpenseRangePreset.custom) return;
                    await provider.setPreset(item.$1);
                  },
                ),
              )
              .toList(),
        ),
        verticalSpace(height: .75.h),
        Row(
          children: [
            Expanded(
              child: _DatePickButton(
                label: "From",
                value: provider.from,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: provider.from,
                    firstDate: DateTime(2020),
                    lastDate: provider.to.isBefore(maxSelectableDate)
                        ? provider.to
                        : maxSelectableDate,
                  );
                  if (picked == null) return;
                  final from = DateTime(picked.year, picked.month, picked.day);
                  final to = provider.to;
                  await provider.setCustomRange(from: from, to: to);
                },
              ),
            ),
            horizontalSpace(width: 2.w),
            Expanded(
              child: _DatePickButton(
                label: "To",
                value: provider.to,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: provider.to,
                    firstDate: provider.from,
                    lastDate: maxSelectableDate,
                  );
                  if (picked == null) return;
                  final to = DateTime(picked.year, picked.month, picked.day);
                  final from = provider.from;
                  await provider.setCustomRange(from: from, to: to);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DatePickButton extends StatelessWidget {
  final String label;
  final DateTime value;
  final Future<void> Function() onTap;
  const _DatePickButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: .75.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: .3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$label: ${DateFormat('dd/MM/yy').format(value)}",
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 12.8.sp,
              ),
            ),
            Icon(Icons.calendar_month_rounded, size: 16.sp),
          ],
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final SingleVehicleExpenseAnalyticsProvider provider;
  const _KpiRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniKpi(
            title: "Range Total",
            value: "Rs ${provider.selectedTotal.toStringAsFixed(0)}",
          ),
        ),
        horizontalSpace(width: 2.w),
        Expanded(
          child: _MiniKpi(
            title: "Avg / Txn",
            value: "Rs ${provider.avgPerTransaction.toStringAsFixed(0)}",
          ),
        ),
        horizontalSpace(width: 2.w),
        Expanded(
          child: _MiniKpi(
            title: "Change",
            value: "${provider.monthChangePercent.toStringAsFixed(1)}%",
          ),
        ),
      ],
    );
  }
}

class _MiniKpi extends StatelessWidget {
  final String title;
  final String value;
  const _MiniKpi({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: .9.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: .05)
            : const Color(0xFFF7FAFC),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: .18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 10.8.sp,
            ),
          ),
          verticalSpace(height: .3.h),
          Text(
            value,
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: 11.8.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppStyles.semiboldTextStyle(context).copyWith(fontSize: 13.2.sp),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final SingleVehicleExpenseAnalyticsProvider provider;
  const _TrendChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final points = provider.trend;
    if (points.isEmpty) return _EmptyLine(text: "No trend data");
    final maxY =
        points.map((e) => e.amount).fold<double>(0, (p, c) => c > p ? c : p) *
            1.2;

    return SizedBox(
      height: 18.h,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY == 0 ? 10 : maxY,
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: (maxY == 0 ? 10 : maxY) / 4,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10.sp),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: points.length > 6 ? 2 : 1,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= points.length) return const SizedBox();
                  return Padding(
                    padding: EdgeInsets.only(top: .4.h),
                    child: Text(
                      DateFormat('dd').format(points[i].date),
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                points.length,
                (i) => FlSpot(i.toDouble(), points[i].amount),
              ),
              isCurved: true,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              color: Colors.blueAccent,
            )
          ],
        ),
      ),
    );
  }
}

class _TypeBar extends StatelessWidget {
  final SingleVehicleExpenseAnalyticsProvider provider;
  const _TypeBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final items = provider.topTypes.take(5).toList();
    if (items.isEmpty) return _EmptyLine(text: "No type data");
    final colors = <Color>[
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    final maxY =
        (items.first.amount * 1.15).clamp(10, double.infinity).toDouble();
    return SizedBox(
      height: 21.h,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: maxY / 4,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10.sp),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= items.length) return const SizedBox();
                  final text = items[i].type;
                  return Padding(
                    padding: EdgeInsets.only(top: .4.h),
                    child: Text(
                      text.length > 8 ? "${text.substring(0, 8)}..." : text,
                      style: TextStyle(fontSize: 9.8.sp),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(
            items.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: items[i].amount,
                  width: 4.2.w,
                  color: colors[i % colors.length],
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentList extends StatelessWidget {
  final SingleVehicleExpenseAnalyticsProvider provider;
  const _RecentList({required this.provider});

  @override
  Widget build(BuildContext context) {
    final items = provider.recent;
    if (items.isEmpty) return _EmptyLine(text: "No recent activity");
    return Column(
      children: items
          .map(
            (e) => Padding(
              padding: EdgeInsets.only(bottom: .75.h),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 2.2.w, vertical: .8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: .04)
                      : const Color(0xFFF7FAFC),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${e.type} • ${e.name.isEmpty ? '-' : e.name}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.sp),
                      ),
                    ),
                    horizontalSpace(width: 2.w),
                    Text(
                      "Rs ${e.amount.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  final String text;
  const _EmptyLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      child: Center(
        child: Text(
          text,
          style:
              AppStyles.regularTextStyle(context).copyWith(fontSize: 11.8.sp),
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String error;
  final Future<void> Function() onRetry;
  const _ErrorBlock({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.8.h),
      child: Column(
        children: [
          Text(
            error,
            textAlign: TextAlign.center,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 11.5.sp,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          verticalSpace(height: .8.h),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }
}
