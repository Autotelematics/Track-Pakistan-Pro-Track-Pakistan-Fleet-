import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/single_vehicle_expense_analytics_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
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
  static const Color _expensePrimaryColor = Color(0xFF2563EB);
  static const Color _expenseSecondaryColor = Color(0xFF0EA5A4);
  static const Color _expenseAccentColor = Color(0xFFF59E0B);

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
    final l10n = context.l10n;
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? <Color>[
                        const Color(0xFF101A2A).withValues(alpha: .98),
                        const Color(0xFF101A2A).withValues(alpha: .90),
                      ]
                    : <Color>[
                        Colors.white,
                        const Color(0xFFF6FBFF),
                      ],
              ),
              borderRadius: BorderRadius.circular(14.sp),
              border: Border.all(
                color: const Color(0xFF0EA5E9)
                    .withValues(alpha: isDark ? .24 : .14),
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
                              Container(
                                width: 5.8.w,
                                height: 5.8.w,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: <Color>[
                                      Color(0xFF22D3EE),
                                      Color(0xFF0284C7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  color: Colors.white,
                                  size: _sveSp(context, phone: 15.0),
                                ),
                              ),
                              horizontalSpace(width: 2.w),
                              Expanded(
                                child: Text(
                                  l10n.expenseAnalytics,
                                  style:
                                      AppStyles.boldTextStyle(context).copyWith(
                                    fontSize: _sveSp(context, phone: 12.8),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => provider.exportSummary(
                                  vehicleName: widget.vehicleName,
                                ),
                                icon: const Icon(Icons.ios_share_rounded),
                                tooltip: l10n.export,
                              ),
                            ],
                          ),
                          _PresetBar(provider: provider),
                          verticalSpace(height: .8.h),
                          _KpiRow(provider: provider),
                          verticalSpace(height: .9.h),
                          _InnerCard(
                            title: l10n.expenseTrend,
                            child: _TrendChart(provider: provider),
                          ),
                          verticalSpace(height: .8.h),
                          _InnerCard(
                            title: l10n.topExpenseTypes,
                            child: _TypeBar(provider: provider),
                          ),
                          verticalSpace(height: .8.h),
                          _InnerCard(
                            title: l10n.recentExpenseActivity,
                            child: _RecentList(provider: provider),
                          ),
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
    final l10n = context.l10n;
    final now = DateTime.now();
    final maxSelectableDate = DateTime(now.year, now.month, now.day);
    final items = <(SingleExpenseRangePreset, String)>[
      (SingleExpenseRangePreset.today, l10n.today),
      (SingleExpenseRangePreset.sevenDays, "7D"),
      (SingleExpenseRangePreset.thirtyDays, "30D"),
      (SingleExpenseRangePreset.thisMonth, l10n.thisMonth),
      (SingleExpenseRangePreset.custom, l10n.custom),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 1.6.w,
          runSpacing: .45.h,
          children: items
              .map(
                (item) => ChoiceChip(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: .05)
                          : const Color(0xFFF7FAFC),
                  selectedColor: _SingleVehicleExpenseAnalyticsCardState
                      ._expensePrimaryColor
                      .withValues(alpha: .14),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(
                    horizontal: -2,
                    vertical: -2,
                  ),
                  labelPadding: EdgeInsets.symmetric(horizontal: 1.6.w),
                  side: BorderSide(
                    color: provider.preset == item.$1
                        ? _SingleVehicleExpenseAnalyticsCardState
                            ._expensePrimaryColor
                            .withValues(alpha: .42)
                        : Theme.of(context).dividerColor.withValues(alpha: .18),
                  ),
                  label: Text(
                    item.$2,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: _sveSp(context, phone: 12.9),
                      fontWeight: provider.preset == item.$1
                          ? FontWeight.w700
                          : FontWeight.w500,
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
                label: l10n.fromDate,
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
                label: l10n.toDate,
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
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: .75.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: .05)
              : const Color(0xFFF7FAFC),
          border: Border.all(
            color: _SingleVehicleExpenseAnalyticsCardState._expensePrimaryColor
                .withValues(alpha: .28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label == l10n.fromDate
                  ? l10n.fromValue(DateFormat('dd/MM/yy').format(value))
                  : l10n.toValue(DateFormat('dd/MM/yy').format(value)),
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: _sveSp(context, phone: 12.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.calendar_month_rounded,
              size: 16.sp,
              color:
                  _SingleVehicleExpenseAnalyticsCardState._expensePrimaryColor,
            ),
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
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _MiniKpi(
            title: l10n.totalRange,
            value: "Rs ${provider.selectedTotal.toStringAsFixed(0)}",
            color: _SingleVehicleExpenseAnalyticsCardState._expensePrimaryColor,
          ),
        ),
        horizontalSpace(width: 2.w),
        Expanded(
          child: _MiniKpi(
            title: l10n.avgPerTxn,
            value: "Rs ${provider.avgPerTransaction.toStringAsFixed(0)}",
            color:
                _SingleVehicleExpenseAnalyticsCardState._expenseSecondaryColor,
          ),
        ),
        horizontalSpace(width: 2.w),
        Expanded(
          child: _MiniKpi(
            title: l10n.changeLabel,
            value: "${provider.monthChangePercent.toStringAsFixed(1)}%",
            color: provider.monthChangePercent < 0
                ? const Color(0xFFDC2626)
                : _SingleVehicleExpenseAnalyticsCardState._expenseAccentColor,
          ),
        ),
      ],
    );
  }
}

class _MiniKpi extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _MiniKpi({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.3.w, vertical: .85.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: .12),
        border: Border.all(
          color: color.withValues(alpha: .3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: _sveSp(context, phone: 12.0),
              fontWeight: FontWeight.w600,
            ),
          ),
          verticalSpace(height: .15.h),
          Text(
            value,
            style: AppStyles.boldTextStyle(context).copyWith(
              fontSize: _sveSp(context, phone: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _InnerCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _InnerCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: .9.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .05)
            : const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.semiboldTextStyle(context)
                .copyWith(fontSize: _sveSp(context, phone: 12.4)),
          ),
          verticalSpace(height: .45.h),
          child,
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final SingleVehicleExpenseAnalyticsProvider provider;
  const _TrendChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final points = provider.trend;
    if (points.isEmpty) return _EmptyLine(text: context.l10n.noTrendData);
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
                  style: TextStyle(
                    fontSize: _sveSp(context, phone: 12.0),
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .6),
                  ),
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
                      style: TextStyle(
                        fontSize: _sveSp(context, phone: 12.0),
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: .7),
                      ),
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
              barWidth: 2.8,
              dotData: const FlDotData(show: false),
              color:
                  _SingleVehicleExpenseAnalyticsCardState._expensePrimaryColor,
              belowBarData: BarAreaData(
                show: true,
                color: _SingleVehicleExpenseAnalyticsCardState
                    ._expensePrimaryColor
                    .withValues(alpha: .16),
              ),
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
    if (items.isEmpty) return _EmptyLine(text: context.l10n.noTypeData);
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
                  style: TextStyle(
                    fontSize: _sveSp(context, phone: 12.0),
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .6),
                  ),
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
                      style: TextStyle(
                        fontSize: _sveSp(context, phone: 11.8),
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: .75),
                      ),
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
    if (items.isEmpty) return _EmptyLine(text: context.l10n.noRecentActivity);
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
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white10
                        : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${e.type} • ${e.name.isEmpty ? '-' : e.name}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.regularTextStyle(context).copyWith(
                          fontSize: _sveSp(context, phone: 12.0),
                        ),
                      ),
                    ),
                    horizontalSpace(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: .2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _SingleVehicleExpenseAnalyticsCardState
                            ._expensePrimaryColor
                            .withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _SingleVehicleExpenseAnalyticsCardState
                              ._expensePrimaryColor
                              .withValues(alpha: .32),
                        ),
                      ),
                      child: Text(
                        "Rs ${e.amount.toStringAsFixed(0)}",
                        style: AppStyles.semiboldTextStyle(context).copyWith(
                          fontSize: _sveSp(context, phone: 11.8),
                        ),
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
          style: AppStyles.regularTextStyle(context)
              .copyWith(fontSize: _sveSp(context, phone: 11.8)),
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
              fontSize: _sveSp(context, phone: 11.5),
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          verticalSpace(height: .8.h),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.l10n.retry),
          )
        ],
      ),
    );
  }
}

double _sveSp(
  BuildContext context, {
  required double phone,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= 360) return (phone * 1.08).sp;
  if (width <= 393) return (phone * 1.10).sp;
  if (width <= 430) return (phone * 1.06).sp;
  return (phone * 1.03).sp;
}
