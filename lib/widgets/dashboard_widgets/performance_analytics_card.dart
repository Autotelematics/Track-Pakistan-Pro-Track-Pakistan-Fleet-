import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/performance_kpi_model.dart';
import 'package:trackerapp/providers/performance_provider.dart';
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

    return Consumer<PerformanceProvider>(
      builder: (context, provider, _) {
        final vehicles = provider.vehicleKpis;
        final drivers = provider.driverKpis;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 1.4.h),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Performance Analytics",
                      style: AppStyles.semiboldTextStyle(context)
                          .copyWith(fontSize: 15.0.sp),
                    ),
                  ),
                  IconButton(
                    onPressed: provider.isLoading
                        ? null
                        : () => _sharePerformanceSummary(provider),
                    icon: const Icon(Icons.ios_share_rounded),
                    tooltip: "Share",
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
                    tooltip: "Refresh",
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
                  message:
                      "No idle/overspeed alerts found for selected date range.",
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _KpiTile(
                        title: "Vehicles",
                        value: "${vehicles.length}",
                        subtitle: "Scored from alerts",
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    horizontalSpace(width: 2.w),
                    Expanded(
                      child: _KpiTile(
                        title: "Drivers",
                        value: "${drivers.length}",
                        subtitle: "Mapped from current assignment",
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
                verticalSpace(height: 1.h),
                _SectionCard(
                  title: "Top Vehicles",
                  child: _VehicleList(
                    items: provider.topVehiclePerformance,
                    onShowMore: () =>
                        _showAllVehiclesSheet(provider.topVehiclePerformance),
                  ),
                ),
                verticalSpace(height: .9.h),
                _SectionCard(
                  title: "Top Drivers",
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
        title: "All Vehicle Performance",
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
        title: "All Driver Performance",
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
        constraints: BoxConstraints(minHeight: 4.4.h, minWidth: 15.w),
        padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: .7.h),
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
            fontSize: 12.3.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.1.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .28)),
        color: color.withValues(alpha: .08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.regularTextStyle(context)
                .copyWith(fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
          verticalSpace(height: .5.h),
          Text(
            value,
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: 16.sp,
              color: color,
            ),
          ),
          verticalSpace(height: .1.h),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 10.4.sp,
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
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                AppStyles.semiboldTextStyle(context).copyWith(fontSize: 13.sp),
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
                    fontSize: 11.8.sp,
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
                    fontSize: 11.8.sp,
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

  const _ScoreRow({
    required this.title,
    required this.subtitle,
    required this.score,
    required this.isLast,
    this.redGreenOnly = false,
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
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : .55.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.3.w, vertical: .65.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: tone.withValues(alpha: .08),
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
                        .copyWith(fontSize: 12.5.sp),
                  ),
                  verticalSpace(height: .15.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.regularTextStyle(context)
                        .copyWith(fontSize: 11.5.sp),
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
                  fontSize: 12.2.sp,
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
  final Widget child;

  const _AllPerformanceSheet({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 74.h, maxHeight: 74.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 1.5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 11.w,
                height: .5.h,
                margin: EdgeInsets.only(bottom: 1.2.h),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: .35),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            Text(
              title,
              style: AppStyles.semiboldTextStyle(context)
                  .copyWith(fontSize: 14.sp),
            ),
            verticalSpace(height: 1.h),
            Expanded(child: child),
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
              fontSize: 12.5.sp,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          verticalSpace(height: .8.h),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text("Retry"),
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
            fontSize: 12.8.sp,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: .7),
          ),
        ),
      ),
    );
  }
}
