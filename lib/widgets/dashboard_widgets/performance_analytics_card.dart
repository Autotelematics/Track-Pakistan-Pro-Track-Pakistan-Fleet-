import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/performance_kpi_model.dart';
import 'package:trackerapp/providers/performance_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

enum _RangePreset { today, sevenDays, thirtyDays }

class PerformanceAnalyticsCard extends StatefulWidget {
  const PerformanceAnalyticsCard({super.key});

  @override
  State<PerformanceAnalyticsCard> createState() =>
      _PerformanceAnalyticsCardState();
}

class _PerformanceAnalyticsCardState extends State<PerformanceAnalyticsCard> {
  _RangePreset _preset = _RangePreset.sevenDays;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadForPreset();
    });
  }

  Future<void> _loadForPreset({bool forceRefresh = false}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    late DateTime from;
    late DateTime to;

    switch (_preset) {
      case _RangePreset.today:
        from = today;
        to = today;
        break;
      case _RangePreset.sevenDays:
        from = today.subtract(const Duration(days: 6));
        to = today;
        break;
      case _RangePreset.thirtyDays:
        from = today.subtract(const Duration(days: 29));
        to = today;
        break;
    }

    await context.read<PerformanceProvider>().loadPerformance(
          from: from,
          to: to,
          forceRefresh: forceRefresh,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCompactPhone = MediaQuery.sizeOf(context).width <= 360;

    return Consumer<PerformanceProvider>(
      builder: (context, provider, _) {
        final vehicles = provider.vehicleKpis;
        final drivers = provider.driverKpis;

        return Container(
          margin: EdgeInsets.symmetric(
              horizontal: _pW(context, phone: 5, compact: 4)),
          padding: EdgeInsets.symmetric(
            horizontal: _pW(context, phone: 3.6, compact: 3.1),
            vertical: _pH(context, phone: 1.4, compact: 1.2),
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
              color:
                  const Color(0xFF0EA5E9).withValues(alpha: isDark ? .24 : .14),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: _pW(context, phone: 5.8, compact: 6.6),
                    height: _pW(context, phone: 5.8, compact: 6.6),
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
                      Icons.query_stats_rounded,
                      color: Colors.white,
                      size: _pSp(context, phone: 15.0),
                    ),
                  ),
                  horizontalSpace(width: 2.w),
                  Expanded(
                    child: Text(
                      context.l10n.performanceAnalytics,
                      style: AppStyles.semiboldTextStyle(context).copyWith(
                        fontSize: _pSp(context, phone: 12.8),
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: .92),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: provider.isLoading
                        ? null
                        : () => _sharePerformanceSummary(provider),
                    icon: const Icon(Icons.ios_share_rounded),
                    tooltip: context.l10n.share,
                    iconSize: 19,
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
                  IconButton(
                    onPressed: provider.isLoading
                        ? null
                        : () => _loadForPreset(forceRefresh: true),
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: context.l10n.refresh,
                    iconSize: 19,
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
              _PresetBar(
                selected: _preset,
                onSelect: (value) async {
                  setState(() => _preset = value);
                  await _loadForPreset();
                },
              ),
              verticalSpace(height: 1.h),
              if (provider.isLoading)
                SizedBox(
                  height: 18.h,
                  child: const Center(child: CircularProgressIndicator()),
                )
              else if (provider.error != null)
                _ErrorBlock(
                  error: provider.error!,
                  onRetry: _loadForPreset,
                )
              else if (vehicles.isEmpty)
                _EmptyBlock(
                  message: context.l10n.noAlertsForDateRange,
                )
              else ...[
                if (isCompactPhone) ...[
                  _KpiTile(
                    title: context.l10n.vehicles,
                    value: "${vehicles.length}",
                    subtitle: context.l10n.scoredFromAlerts,
                    color: const Color(0xFF2563EB),
                  ),
                  verticalSpace(height: .7.h),
                  _KpiTile(
                    title: context.l10n.drivers,
                    value: "${drivers.length}",
                    subtitle: context.l10n.mappedFromAssignment,
                    color: const Color(0xFF16A34A),
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: _KpiTile(
                          title: context.l10n.vehicles,
                          value: "${vehicles.length}",
                          subtitle: context.l10n.scoredFromAlerts,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      horizontalSpace(width: 2.w),
                      Expanded(
                        child: _KpiTile(
                          title: context.l10n.drivers,
                          value: "${drivers.length}",
                          subtitle: context.l10n.mappedFromAssignment,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                verticalSpace(height: 1.h),
                _SectionCard(
                  title: context.l10n.topVehicles,
                  icon: Icons.local_shipping_rounded,
                  child: _VehicleList(
                    items: provider.topVehiclePerformance,
                    onShowMore: () =>
                        _showAllVehiclesSheet(provider.topVehiclePerformance),
                  ),
                ),
                verticalSpace(height: .9.h),
                _SectionCard(
                  title: context.l10n.topDrivers,
                  icon: Icons.person_rounded,
                  child: _DriverList(
                    items: provider.topDriverPerformance,
                    onShowMore: () =>
                        _showAllDriversSheet(provider.topDriverPerformance),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showAllVehiclesSheet(List<VehiclePerformanceKpi> items) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AllPerformanceSheet(
        title: context.l10n.allVehiclePerformance,
        icon: Icons.local_shipping_rounded,
        totalCount: items.length,
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(height: .55.h),
          itemBuilder: (context, index) {
            final v = items[index];
            return _ScoreRow(
              title: v.deviceName,
              subtitle:
                  "Idle ${v.idleAlertCount} | Overspeed ${v.overSpeedAlertCount}",
              score: v.score,
              isLast: index == items.length - 1,
              redGreenOnly: true,
              inSheet: true,
            );
          },
        ),
      ),
    );
  }

  void _showAllDriversSheet(List<DriverPerformanceKpi> items) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AllPerformanceSheet(
        title: context.l10n.allDriverPerformance,
        icon: Icons.person_rounded,
        totalCount: items.length,
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(height: .55.h),
          itemBuilder: (context, index) {
            final d = items[index];
            final vehicle = (d.vehicleName ?? '').trim();
            return _ScoreRow(
              title: d.driverName,
              subtitle:
                  "${vehicle.isEmpty ? 'No vehicle' : vehicle} | Idle ${d.idleAlertCount} | Overspeed ${d.overSpeedAlertCount}",
              score: d.score,
              isLast: index == items.length - 1,
              redGreenOnly: true,
              inSheet: true,
            );
          },
        ),
      ),
    );
  }

  Future<void> _sharePerformanceSummary(PerformanceProvider provider) async {
    final vehicles = provider.topVehiclePerformance;
    final drivers = provider.topDriverPerformance;
    final from = provider.fromDate;
    final to = provider.toDate;
    final buffer = StringBuffer();

    String fmtDate(DateTime d) {
      String two(int v) => v.toString().padLeft(2, '0');
      return '${two(d.day)}/${two(d.month)}/${d.year}';
    }

    buffer.writeln("Performance Analytics Report");
    if (from != null && to != null) {
      buffer.writeln("Range: ${fmtDate(from)} - ${fmtDate(to)}");
    }
    buffer.writeln("Generated: ${DateTime.now()}");
    buffer.writeln("Vehicles scored: ${provider.vehicleKpis.length}");
    buffer.writeln("Drivers scored: ${provider.driverKpis.length}");
    buffer.writeln("");

    buffer.writeln("Top Vehicles");
    for (final v in vehicles.take(10)) {
      buffer.writeln(
        "- ${v.deviceName}: ${v.score.toStringAsFixed(1)}% | Idle ${v.idleAlertCount} | Overspeed ${v.overSpeedAlertCount}",
      );
    }
    buffer.writeln("");

    buffer.writeln("Top Drivers");
    for (final d in drivers.take(10)) {
      final vehicle = (d.vehicleName ?? '').trim();
      buffer.writeln(
        "- ${d.driverName}: ${d.score.toStringAsFixed(1)}% | ${vehicle.isEmpty ? 'No vehicle' : vehicle} | Idle ${d.idleAlertCount} | Overspeed ${d.overSpeedAlertCount}",
      );
    }

    await SharePlus.instance.share(
      ShareParams(text: buffer.toString()),
    );
  }
}

class _PresetBar extends StatelessWidget {
  final _RangePreset selected;
  final ValueChanged<_RangePreset> onSelect;

  const _PresetBar({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = <(_RangePreset, String)>[
      (_RangePreset.today, "Today"),
      (_RangePreset.sevenDays, "7D"),
      (_RangePreset.thirtyDays, "30D"),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map(
              (item) => Padding(
                padding: EdgeInsets.only(right: 1.2.w),
                child: _PresetChip(
                  label: item.$2,
                  isSelected: selected == item.$1,
                  isDark: isDark,
                  onTap: () => onSelect(item.$1),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _PresetChip({
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
          minHeight: _pH(context, phone: 4.2, compact: 4.0, min: 36),
          minWidth: _pW(context, phone: 15, compact: 16),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: _pW(context, phone: 2.2, compact: 2.0),
          vertical: _pH(context, phone: .7, compact: .65),
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
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: _pSp(context, phone: 11.4),
            fontWeight: FontWeight.w600,
            color: isSelected
                ? softYellowText
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _KpiTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _pW(context, phone: 3.0, compact: 2.4),
        vertical: _pH(context, phone: 1.0, compact: .85),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .28)),
        gradient: LinearGradient(
          colors: <Color>[
            color.withValues(alpha: .17),
            color.withValues(alpha: .08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .14),
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
                fontSize: _pSp(context, phone: 11.2),
                fontWeight: FontWeight.w600),
          ),
          verticalSpace(height: .5.h),
          Text(
            value,
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: _pSp(context, phone: 14.3),
              color: color,
            ),
          ),
          verticalSpace(height: .1.h),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: _pSp(context, phone: 9.9),
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: .7),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
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
        horizontal: _pW(context, phone: 3.0, compact: 2.4),
        vertical: _pH(context, phone: 1.0, compact: .9),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: _pW(context, phone: 5.8, compact: 6.5),
                height: _pW(context, phone: 5.8, compact: 6.5),
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
                  size: _pSp(context, phone: 10.6),
                  color: Colors.white,
                ),
              ),
              horizontalSpace(width: 2.w),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: _pSp(context, phone: 12.3),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace(height: .6.h),
          child,
        ],
      ),
    );
  }
}

class _VehicleList extends StatelessWidget {
  final List<VehiclePerformanceKpi> items;
  final VoidCallback onShowMore;

  const _VehicleList({
    required this.items,
    required this.onShowMore,
  });

  @override
  Widget build(BuildContext context) {
    final sliced = items.take(5).toList();
    if (sliced.isEmpty) return const _EmptyBlock(message: "No vehicle data");
    final moreCount = items.length - sliced.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(sliced.length, (index) {
          final v = sliced[index];
          return _ScoreRow(
            title: v.deviceName,
            subtitle:
                "Idle ${v.idleAlertCount} | Overspeed ${v.overSpeedAlertCount}",
            score: v.score,
            isLast: index == sliced.length - 1 && moreCount == 0,
          );
        }),
        if (moreCount > 0)
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onShowMore,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 1.2.w, vertical: .2.h),
                child: Text(
                  "+$moreCount more • Show more",
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: _pSp(context, phone: 11.0),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DriverList extends StatelessWidget {
  final List<DriverPerformanceKpi> items;
  final VoidCallback onShowMore;

  const _DriverList({
    required this.items,
    required this.onShowMore,
  });

  @override
  Widget build(BuildContext context) {
    final sliced = items.take(5).toList();
    if (sliced.isEmpty) return const _EmptyBlock(message: "No driver data");
    final moreCount = items.length - sliced.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(sliced.length, (index) {
          final d = sliced[index];
          final vehicle = (d.vehicleName ?? '').trim();
          return _ScoreRow(
            title: d.driverName,
            subtitle:
                "${vehicle.isEmpty ? 'No vehicle' : vehicle} | Idle ${d.idleAlertCount} | Overspeed ${d.overSpeedAlertCount}",
            score: d.score,
            isLast: index == sliced.length - 1 && moreCount == 0,
          );
        }),
        if (moreCount > 0)
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onShowMore,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 1.2.w, vertical: .2.h),
                child: Text(
                  "+$moreCount more • Show more",
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: _pSp(context, phone: 11.0),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final double score;
  final bool isLast;
  final bool redGreenOnly;
  final bool inSheet;

  const _ScoreRow({
    required this.title,
    required this.subtitle,
    required this.score,
    required this.isLast,
    this.redGreenOnly = false,
    this.inSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    final tone = redGreenOnly
        ? (score >= 75 ? const Color(0xFF16A34A) : const Color(0xFFDC2626))
        : score >= 85
            ? const Color(0xFF16A34A)
            : score >= 65
                ? const Color(0xFFF59E0B)
                : const Color(0xFFDC2626);
    final titleSize = _pSp(context, phone: inSheet ? 14.3 : 11.7);
    final subtitleSize = _pSp(context, phone: inSheet ? 13.3 : 10.8);
    final scoreSize = _pSp(context, phone: inSheet ? 13.9 : 11.4);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : .55.h),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _pW(context,
              phone: inSheet ? 2.6 : 2.3, compact: inSheet ? 2.2 : 2.0),
          vertical: _pH(context,
              phone: inSheet ? .78 : .65, compact: inSheet ? .68 : .58),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: <Color>[
              tone.withValues(alpha: .14),
              tone.withValues(alpha: .07),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.semiboldTextStyle(context)
                        .copyWith(fontSize: titleSize),
                  ),
                  verticalSpace(height: .15.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.regularTextStyle(context)
                        .copyWith(fontSize: subtitleSize),
                  ),
                ],
              ),
            ),
            horizontalSpace(width: 2.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: .35.h),
              decoration: BoxDecoration(
                color: tone.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: tone.withValues(alpha: .35)),
              ),
              child: Text(
                score.toStringAsFixed(1),
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  fontSize: scoreSize,
                  color: tone,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllPerformanceSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final int totalCount;
  final Widget child;

  const _AllPerformanceSheet({
    this.title = '',
    this.icon = Icons.list_alt_rounded,
    this.totalCount = 0,
    this.child = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 74.h, maxHeight: 74.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? <Color>[
                  theme.cardColor.withValues(alpha: .98),
                  theme.cardColor.withValues(alpha: .93),
                ]
              : <Color>[
                  Colors.white,
                  const Color(0xFFF7FBFF),
                ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: const Color(0xFF0EA5E9).withValues(alpha: isDark ? .24 : .14),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _pW(context, phone: 4, compact: 3.6),
          _pH(context, phone: 1.2, compact: 1.0),
          _pW(context, phone: 4, compact: 3.6),
          _pH(context, phone: 1.5, compact: 1.3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: _pW(context, phone: 11, compact: 13),
                height: _pH(context, phone: .5, compact: .46),
                margin: EdgeInsets.only(
                    bottom: _pH(context, phone: 1.2, compact: 1.0)),
                decoration: BoxDecoration(
                  color: onSurface.withValues(alpha: .24),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: _pW(context, phone: 2.4, compact: 2.1),
                vertical: _pH(context, phone: .8, compact: .7),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? <Color>[
                          Colors.white.withValues(alpha: .08),
                          Colors.white.withValues(alpha: .04),
                        ]
                      : <Color>[
                          const Color(0xFFF2F8FF),
                          Colors.white,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: onSurface.withValues(alpha: .10),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: _pW(context, phone: 6.2, compact: 7.2),
                    height: _pW(context, phone: 6.2, compact: 7.2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: <Color>[
                          Color(0xFF22D3EE),
                          Color(0xFF0284C7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: _pSp(context, phone: 11.2),
                      color: Colors.white,
                    ),
                  ),
                  horizontalSpace(width: 2.w),
                  Expanded(
                    child: Text(
                      title,
                      style: AppStyles.semiboldTextStyle(context).copyWith(
                        fontSize: _pSp(context, phone: 15.4),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _pW(context, phone: 2.0, compact: 1.8),
                      vertical: _pH(context, phone: .35, compact: .32),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF7DD3FC),
                      ),
                    ),
                    child: Text(
                      '$totalCount',
                      style: AppStyles.semiboldTextStyle(context).copyWith(
                        fontSize: _pSp(context, phone: 12.3),
                        color: const Color(0xFF075985),
                      ),
                    ),
                  ),
                  horizontalSpace(width: 1.2.w),
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(
                          _pW(context, phone: 1.4, compact: 1.6)),
                      decoration: BoxDecoration(
                        color: onSurface.withValues(alpha: .08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: _pSp(context, phone: 10.5),
                        color: onSurface.withValues(alpha: .75),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            verticalSpace(height: 1.h),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: _pW(context, phone: 1.4, compact: 1.2),
                  vertical: _pH(context, phone: .25, compact: .2),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark
                      ? Colors.white.withValues(alpha: .03)
                      : Colors.white.withValues(alpha: .90),
                  border: Border.all(
                    color: onSurface.withValues(alpha: .10),
                  ),
                ),
                child: child,
              ),
            ),
          ],
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
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        children: [
          Text(
            error,
            textAlign: TextAlign.center,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: _pSp(context, phone: 11.5),
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          verticalSpace(height: .8.h),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final String message;

  const _EmptyBlock({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: _pSp(context, phone: 11.8),
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: .7),
          ),
        ),
      ),
    );
  }
}

double _pSp(
  BuildContext context, {
  required double phone,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= 360) return (phone * 1.08).sp;
  if (width <= 393) return (phone * 1.10).sp;
  if (width <= 430) return (phone * 1.06).sp;
  return (phone * 1.03).sp;
}

double _pW(
  BuildContext context, {
  required double phone,
  double? compact,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= 360 && compact != null) return compact.w;
  return phone.w;
}

double _pH(
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
