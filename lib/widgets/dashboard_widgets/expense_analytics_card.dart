import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/dashboard_expense_analytics_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class ExpenseAnalyticsCard extends StatefulWidget {
  const ExpenseAnalyticsCard({super.key});

  @override
  State<ExpenseAnalyticsCard> createState() => _ExpenseAnalyticsCardState();
}

class _ExpenseAnalyticsCardState extends State<ExpenseAnalyticsCard> {
  late final DashboardExpenseAnalyticsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = DashboardExpenseAnalyticsProvider();
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
    final onSurface = theme.colorScheme.onSurface;
    final isCompactPhone = MediaQuery.sizeOf(context).width <= 360;
    return ChangeNotifierProvider<DashboardExpenseAnalyticsProvider>.value(
      value: _provider,
      child: Consumer<DashboardExpenseAnalyticsProvider>(
        builder: (context, provider, _) {
          return Container(
            margin: EdgeInsets.symmetric(
                horizontal: _eW(context, phone: 5, compact: 4)),
            padding: EdgeInsets.symmetric(
              horizontal: _eW(context, phone: 3.6, compact: 3.1),
              vertical: _eH(context, phone: 1.4, compact: 1.2),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? <Color>[
                        theme.cardColor.withValues(alpha: .98),
                        theme.cardColor.withValues(alpha: .92),
                      ]
                    : <Color>[
                        Colors.white,
                        const Color(0xFFF6FBFF),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF0EA5E9)
                    .withValues(alpha: isDark ? .24 : .14),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.5)
                      : const Color(0xFF0284C7).withValues(alpha: 0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: provider.isLoading
                ? SizedBox(
                    height: 34.h,
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
                                width: _eW(context, phone: 5.8, compact: 6.6),
                                height: _eW(context, phone: 5.8, compact: 6.6),
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
                                  size: _eSp(context, phone: 15.0),
                                ),
                              ),
                              horizontalSpace(width: 2.w),
                              Expanded(
                                child: Text(
                                  context.l10n.expenseAnalytics,
                                  style: AppStyles.semiboldTextStyle(context)
                                      .copyWith(
                                    fontSize: _eSp(context, phone: 12.8),
                                    fontWeight: FontWeight.w900,
                                    color: onSurface.withValues(alpha: .92),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: provider.exportSummary,
                                icon: const Icon(Icons.ios_share_rounded),
                                tooltip: context.l10n.export,
                                iconSize: 18,
                                padding: EdgeInsets.zero,
                                visualDensity: const VisualDensity(
                                  horizontal: -3,
                                  vertical: -3,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                              ),
                            ],
                          ),
                          _DatePresetBar(provider: provider),
                          verticalSpace(height: 1.h),
                          _KpiRow(
                            provider: provider,
                            isCompactPhone: isCompactPhone,
                          ),
                          verticalSpace(height: 1.h),
                          _AvgRow(
                            provider: provider,
                            isCompactPhone: isCompactPhone,
                          ),
                          verticalSpace(height: 1.3.h),
                          _SectionBlock(
                            title: context.l10n.expenseTrend,
                            icon: Icons.show_chart_rounded,
                            child: _TrendChart(provider: provider),
                          ),
                          verticalSpace(height: 1.2.h),
                          _SectionBlock(
                            title: context.l10n.topExpenseTypes,
                            icon: Icons.pie_chart_rounded,
                            child: _TypeBarChart(provider: provider),
                          ),
                          verticalSpace(height: 1.2.h),
                          _SectionBlock(
                            title: context.l10n.topVehiclesByExpense,
                            icon: Icons.local_shipping_rounded,
                            child: _TopVehicles(provider: provider),
                          ),
                          verticalSpace(height: 1.2.h),
                          _SectionBlock(
                            title: context.l10n.recentExpenseActivity,
                            icon: Icons.history_rounded,
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

class _DatePresetBar extends StatelessWidget {
  final DashboardExpenseAnalyticsProvider provider;
  const _DatePresetBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final maxSelectableDate = DateTime(today.year, today.month, today.day);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = <(ExpenseRangePreset, String)>[
      (ExpenseRangePreset.today, "Today"),
      (ExpenseRangePreset.sevenDays, "7D"),
      (ExpenseRangePreset.thirtyDays, "30D"),
      (ExpenseRangePreset.thisMonth, "Month"),
      (ExpenseRangePreset.custom, "Custom"),
    ];
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items
                .map(
                  (item) => Padding(
                    padding: EdgeInsets.only(right: 1.2.w),
                    child: _PresetFilterChip(
                      label: item.$2,
                      isSelected: provider.preset == item.$1,
                      isDark: isDark,
                      onTap: () async {
                        if (item.$1 == ExpenseRangePreset.custom) return;
                        await provider.setPreset(item.$1);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        verticalSpace(height: 1.55.h),
        Row(
          children: [
            Expanded(
              child: _DatePickButton(
                label: context.l10n.fromDate,
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
                label: context.l10n.toDate,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = label.toLowerCase().contains('from')
        ? Icons.event
        : Icons.event_available;
    final softGreenBg =
        isDark ? const Color(0xFF22352A) : const Color(0xFFEAF8EE);
    final softGreenBorder =
        isDark ? const Color(0xFF6FB58A) : const Color(0xFF9ED4B2);
    final softGreenAccent =
        isDark ? const Color(0xFF93D8AE) : const Color(0xFF4F9E6E);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _eW(context, phone: 2.2, compact: 2.0),
          vertical: _eH(context, phone: .75, compact: .7),
        ),
        decoration: BoxDecoration(
          color: softGreenBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: softGreenBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$label Date",
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: _eSp(context, phone: 12.1),
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
            verticalSpace(height: .2.h),
            Row(
              children: [
                Icon(icon, size: 14.sp, color: softGreenAccent),
                horizontalSpace(width: 1.2.w),
                Expanded(
                  child: Text(
                    DateFormat('dd/MM/yy').format(value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: _eSp(context, phone: 11.8),
                      color: isDark ? AppColors.white : AppColors.textBlack,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final Future<void> Function() onTap;

  const _PresetFilterChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final softYellowBg =
        isDark ? const Color(0xFF3E3418) : const Color(0xFFFFF6D9);
    final softYellowBorder =
        isDark ? const Color(0xFFD8BA66) : const Color(0xFFE5C97A);
    final softYellowText =
        isDark ? const Color(0xFFFFE6A1) : const Color(0xFF9A6E00);

    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        constraints: BoxConstraints(
          minHeight: _eH(context, phone: 4.2, compact: 4.0, min: 36),
          minWidth: _eW(context, phone: 15, compact: 16),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: _eW(context, phone: 2.2, compact: 2.0),
          vertical: _eH(context, phone: .7, compact: .65),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? softYellowBg
              : (isDark ? Colors.white.withValues(alpha: .06) : Colors.white),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSelected
                ? softYellowBorder
                : theme.dividerColor.withValues(alpha: .22),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppStyles.semiboldTextStyle(context).copyWith(
            fontSize: _eSp(context, phone: 11.5),
            color: isSelected
                ? softYellowText
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final DashboardExpenseAnalyticsProvider provider;
  final bool isCompactPhone;
  const _KpiRow({
    required this.provider,
    required this.isCompactPhone,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompactPhone) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MiniKpi(
                  title: context.l10n.thisMonth,
                  value: "Rs ${provider.thisMonthTotal.toStringAsFixed(0)}",
                  accent: const Color(0xFF2563EB),
                ),
              ),
              horizontalSpace(width: 2.w),
              Expanded(
                child: _MiniKpi(
                  title: context.l10n.lastMonth,
                  value: "Rs ${provider.lastMonthTotal.toStringAsFixed(0)}",
                  accent: const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          verticalSpace(height: .65.h),
          _MiniKpi(
            title: context.l10n.changeLabel,
            value: "${provider.monthChangePercent.toStringAsFixed(1)}%",
            accent: const Color(0xFFF59E0B),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: _MiniKpi(
            title: context.l10n.thisMonth,
            value: "Rs ${provider.thisMonthTotal.toStringAsFixed(0)}",
            accent: const Color(0xFF2563EB),
          ),
        ),
        horizontalSpace(width: 2.w),
        Expanded(
          child: _MiniKpi(
            title: context.l10n.lastMonth,
            value: "Rs ${provider.lastMonthTotal.toStringAsFixed(0)}",
            accent: const Color(0xFF7C3AED),
          ),
        ),
        horizontalSpace(width: 2.w),
        Expanded(
          child: _MiniKpi(
            title: context.l10n.changeLabel,
            value: "${provider.monthChangePercent.toStringAsFixed(1)}%",
            accent: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }
}

class _AvgRow extends StatelessWidget {
  final DashboardExpenseAnalyticsProvider provider;
  final bool isCompactPhone;
  const _AvgRow({
    required this.provider,
    required this.isCompactPhone,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompactPhone) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MiniKpi(
                  title: context.l10n.totalRange,
                  value: "Rs ${provider.selectedTotal.toStringAsFixed(0)}",
                  accent: const Color(0xFF0284C7),
                ),
              ),
              horizontalSpace(width: 2.w),
              Expanded(
                child: _MiniKpi(
                  title: context.l10n.avgPerTxn,
                  value: "Rs ${provider.avgPerTransaction.toStringAsFixed(0)}",
                  accent: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          verticalSpace(height: .65.h),
          _MiniKpi(
            title: context.l10n.avgPerDay,
            value: "Rs ${provider.avgDailySpend.toStringAsFixed(0)}",
            accent: const Color(0xFFDC2626),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: _MiniKpi(
            title: context.l10n.totalRange,
            value: "Rs ${provider.selectedTotal.toStringAsFixed(0)}",
            accent: const Color(0xFF0284C7),
          ),
        ),
        horizontalSpace(width: 2.w),
        Expanded(
          child: _MiniKpi(
            title: context.l10n.avgPerTxn,
            value: "Rs ${provider.avgPerTransaction.toStringAsFixed(0)}",
            accent: const Color(0xFF16A34A),
          ),
        ),
        horizontalSpace(width: 2.w),
        Expanded(
          child: _MiniKpi(
            title: context.l10n.avgPerDay,
            value: "Rs ${provider.avgDailySpend.toStringAsFixed(0)}",
            accent: const Color(0xFFDC2626),
          ),
        ),
      ],
    );
  }
}

class _MiniKpi extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;
  const _MiniKpi({
    required this.title,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _eW(context, phone: 2.0, compact: 1.8),
        vertical: _eH(context, phone: .9, compact: .8),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: <Color>[
            accent.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? .20
                    : .17),
            accent.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? .10
                    : .08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: accent.withValues(alpha: .35),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .14),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: _eSp(context, phone: 11.0),
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: .78),
            ),
          ),
          verticalSpace(height: .3.h),
          Text(
            value,
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: _eSp(context, phone: 12.0),
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionBlock({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: _eW(context, phone: 2.8, compact: 2.3),
        vertical: _eH(context, phone: 1.0, compact: .9),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: isDark
              ? <Color>[
                  Colors.white.withValues(alpha: .06),
                  Colors.white.withValues(alpha: .03),
                ]
              : <Color>[
                  const Color(0xFFF9FBFE),
                  Colors.white,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: .14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: _eW(context, phone: 5.8, compact: 6.5),
                height: _eW(context, phone: 5.8, compact: 6.5),
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
                  icon,
                  size: _eSp(context, phone: 10.6),
                  color: Colors.white,
                ),
              ),
              horizontalSpace(width: 2.w),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: _eSp(context, phone: 12.4),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace(height: .65.h),
          child,
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final DashboardExpenseAnalyticsProvider provider;
  const _TrendChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final points = provider.trend;
    if (points.isEmpty) {
      return _EmptyLine(text: context.l10n.noTrendData);
    }
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
                  style: TextStyle(fontSize: _eSp(context, phone: 10.0)),
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
                      style: TextStyle(fontSize: _eSp(context, phone: 10.0)),
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

class _TypeBarChart extends StatelessWidget {
  final DashboardExpenseAnalyticsProvider provider;
  const _TypeBarChart({required this.provider});

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
    return SizedBox(
      height: 21.h,
      child: BarChart(
        BarChartData(
          maxY: (items.first.amount * 1.15).clamp(10, double.infinity),
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
                interval:
                    (items.first.amount * 1.15).clamp(10, double.infinity) / 4,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: _eSp(context, phone: 10.0)),
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
                      style: TextStyle(fontSize: _eSp(context, phone: 10.0)),
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
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF111827),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final item = items[groupIndex];
                return BarTooltipItem(
                  "${item.type}\nRs ${item.amount.toStringAsFixed(0)}",
                  TextStyle(
                    color: Colors.white,
                    fontSize: _eSp(context, phone: 9.2),
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TopVehicles extends StatelessWidget {
  final DashboardExpenseAnalyticsProvider provider;
  const _TopVehicles({required this.provider});

  @override
  Widget build(BuildContext context) {
    final items = provider.topVehicles.take(5).toList();
    if (items.isEmpty) return _EmptyLine(text: "No vehicle data");
    return Column(
      children: items
          .map(
            (e) => Padding(
              padding: EdgeInsets.only(bottom: .7.h),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 2.2.w, vertical: .75.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: .03)
                      : Colors.white,
                  border: Border.all(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: .12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.vehicleName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: _eSp(context, phone: 11.2)),
                      ),
                    ),
                    Text(
                      "Rs ${e.amount.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: _eSp(context, phone: 11.2),
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

class _RecentList extends StatelessWidget {
  final DashboardExpenseAnalyticsProvider provider;
  const _RecentList({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final items = provider.recent;
    if (items.isEmpty) return _EmptyLine(text: context.l10n.noRecentActivity);
    return Column(
      children: items.asMap().entries.map((entry) {
        final idx = entry.key;
        final e = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: idx == items.length - 1 ? 0 : .55.h),
          padding: EdgeInsets.symmetric(horizontal: 2.3.w, vertical: .72.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isDark
                ? Colors.white.withValues(alpha: .04)
                : Colors.white.withValues(alpha: .90),
            border: Border.all(
              color: onSurface.withValues(alpha: isDark ? .12 : .10),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "${e.vehicleName} • ${e.type}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _eSp(context, phone: 11.2),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              horizontalSpace(width: 2.w),
              Text(
                "Rs ${e.amount.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: _eSp(context, phone: 11.2),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
              .copyWith(fontSize: _eSp(context, phone: 11.0)),
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
              fontSize: _eSp(context, phone: 10.8),
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          verticalSpace(height: .8.h),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(context.l10n.retry),
          )
        ],
      ),
    );
  }
}

double _eSp(
  BuildContext context, {
  required double phone,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= 360) return (phone * 1.08).sp;
  if (width <= 393) return (phone * 1.10).sp;
  if (width <= 430) return (phone * 1.06).sp;
  return (phone * 1.03).sp;
}

double _eW(
  BuildContext context, {
  required double phone,
  double? compact,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= 360 && compact != null) return compact.w;
  return phone.w;
}

double _eH(
  BuildContext context, {
  required double phone,
  double? compact,
  double min = 0,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final value = (width <= 360 && compact != null ? compact : phone).h;
  if (min <= 0) return value;
  return value < min ? min : value;
}
