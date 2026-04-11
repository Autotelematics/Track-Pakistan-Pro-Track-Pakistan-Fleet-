import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class MaintenanceAnalyticsCard extends StatelessWidget {
  final GetDashboardModel data;

  const MaintenanceAnalyticsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCompactPhone = MediaQuery.sizeOf(context).width <= 360;

    final entries = data.maintenance.map(_MaintenanceEntry.fromItem).toList();
    final total = entries.length;
    final overdue = entries.where((e) => e.isOverdue).toList();
    final due = entries.where((e) => e.isDueSoon && !e.isOverdue).toList();
    final ok = entries.where((e) => !e.isOverdue && !e.isDueSoon).toList();

    final healthPct = total == 0 ? 0.0 : (ok.length / total) * 100;

    final due7 = entries
        .where(
            (e) => e.daysLeft != null && e.daysLeft! >= 0 && e.daysLeft! <= 7)
        .length;
    final due14 = entries
        .where(
            (e) => e.daysLeft != null && e.daysLeft! >= 0 && e.daysLeft! <= 14)
        .length;
    final due30 = entries
        .where(
            (e) => e.daysLeft != null && e.daysLeft! >= 0 && e.daysLeft! <= 30)
        .length;

    final overdueByType = <String, int>{
      'Odometer': overdue.where((e) => e.type == 'odometer').length,
      'Engine Hours': overdue.where((e) => e.type == 'engine_hours').length,
      'Date/Days': overdue.where((e) => e.type == 'days').length,
    };

    final vehicleOverdueCounts = <String, int>{};
    for (final e in overdue) {
      vehicleOverdueCounts[e.deviceName] =
          (vehicleOverdueCounts[e.deviceName] ?? 0) + 1;
    }
    final topVehicles = vehicleOverdueCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topVehiclesRows = topVehicles
        .take(5)
        .map((e) => (
              e.key.isEmpty ? 'Unknown Vehicle' : e.key,
              '${e.value} overdue',
              true
            ))
        .toList();

    final upcomingByLeft = entries
        .where((e) => !e.isOverdue && e.left != null && e.left! >= 0)
        .toList()
      ..sort((a, b) => (a.left ?? 1e12).compareTo(b.left ?? 1e12));
    final nextDueRows = upcomingByLeft
        .take(5)
        .map(
          (e) => (
            '${e.serviceName} (${e.typeLabel})',
            '${(e.left ?? 0).toStringAsFixed(0)} ${e.unitLabel}',
            false,
          ),
        )
        .toList();

    final upcomingByDate = entries.where((e) => e.dueDate != null).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    final upcomingDateRows = upcomingByDate.take(5).map((e) {
      final d = e.dueDate!;
      final dateLabel =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      return (e.serviceName, dateLabel, false);
    }).toList();

    final critical =
        entries.where((e) => e.isOverdue || e.percent >= 95).toList()
          ..sort((a, b) {
            final aScore = (a.isOverdue ? 1000.0 : 0.0) +
                a.percent +
                (a.daysLeft != null ? math.max(0, 30 - a.daysLeft!) : 0);
            final bScore = (b.isOverdue ? 1000.0 : 0.0) +
                b.percent +
                (b.daysLeft != null ? math.max(0, 30 - b.daysLeft!) : 0);
            return bScore.compareTo(aScore);
          });
    final criticalRows = critical
        .take(5)
        .map(
          (e) => (
            '${e.deviceName} • ${e.serviceName}',
            e.isOverdue ? 'OVERDUE' : 'Risk ${e.percent.toStringAsFixed(0)}%',
            e.isOverdue,
          ),
        )
        .toList();

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: _mH(context, phone: 1.2, compact: 1.0),
        horizontal: _mW(context, phone: 3.5, compact: 3.0),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _mW(context, phone: 5.0, compact: 4.0),
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
          color: const Color(0xFF0EA5E9).withValues(alpha: isDark ? .24 : .14),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.55)
                : const Color(0xFF0284C7).withValues(alpha: 0.10),
            blurRadius: isDark ? 16 : 14,
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
                width: _mW(context, phone: 5.8, compact: 6.6),
                height: _mW(context, phone: 5.8, compact: 6.6),
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
                  Icons.build_circle_rounded,
                  color: Colors.white,
                  size: _mSp(context, phone: 15.0),
                ),
              ),
              horizontalSpace(width: 2.w),
              Expanded(
                child: Text(
                  context.l10n.maintenanceAnalytics,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: _mSp(context, phone: 12.8),
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .92),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _shareMaintenanceAnalytics(
                  total: total,
                  healthPct: healthPct,
                  dueCount: due.length,
                  overdueCount: overdue.length,
                  due7: due7,
                  due14: due14,
                  due30: due30,
                  overdueByType: overdueByType,
                  topVehiclesRows: topVehiclesRows,
                  nextDueRows: nextDueRows,
                  upcomingDateRows: upcomingDateRows,
                  criticalRows: criticalRows,
                ),
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
            ],
          ),
          verticalSpace(height: .2.h),
          if (isCompactPhone) ...[
            _kpiTile(
              context,
              title: context.l10n.healthScore,
              value: '${healthPct.toStringAsFixed(1)}%',
              subtitle: '${ok.length}/$total in healthy state',
              color: const Color(0xFF16A34A),
            ),
            verticalSpace(height: .7.h),
            _kpiTile(
              context,
              title: context.l10n.dueSoon,
              value: due.toString(),
              subtitle: context.l10n.overdueCountLabel(overdue.length),
              color: const Color(0xFFF59E0B),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _kpiTile(
                    context,
                    title: context.l10n.healthScore,
                    value: '${healthPct.toStringAsFixed(1)}%',
                    subtitle: '${ok.length}/$total in healthy state',
                    color: const Color(0xFF16A34A),
                  ),
                ),
                horizontalSpace(width: 2.w),
                Expanded(
                  child: _kpiTile(
                    context,
                    title: context.l10n.dueSoon,
                    value: due.toString(),
                    subtitle: context.l10n.overdueCountLabel(overdue.length),
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          verticalSpace(height: 1.h),
          _innerCard(
            context,
            title: context.l10n.dueSoonWindows,
            icon: Icons.date_range_rounded,
            child: isCompactPhone
                ? Wrap(
                    spacing: 2.w,
                    runSpacing: .6.h,
                    children: [
                      SizedBox(
                        width: 27.w,
                        child: _chip(
                          context,
                          '7 days',
                          '$due7',
                          const Color(0xFFF59E0B),
                          onTap: () => _showDueSoonWindowSheet(
                            context,
                            title: 'Due in Next 7 Days',
                            rows: _dueSoonRows(entries, 7),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 27.w,
                        child: _chip(
                          context,
                          '14 days',
                          '$due14',
                          const Color(0xFFD97706),
                          onTap: () => _showDueSoonWindowSheet(
                            context,
                            title: 'Due in Next 14 Days',
                            rows: _dueSoonRows(entries, 14),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 27.w,
                        child: _chip(
                          context,
                          '30 days',
                          '$due30',
                          const Color(0xFFB45309),
                          onTap: () => _showDueSoonWindowSheet(
                            context,
                            title: 'Due in Next 30 Days',
                            rows: _dueSoonRows(entries, 30),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _chip(
                          context,
                          '7 days',
                          '$due7',
                          const Color(0xFFF59E0B),
                          onTap: () => _showDueSoonWindowSheet(
                            context,
                            title: 'Due in Next 7 Days',
                            rows: _dueSoonRows(entries, 7),
                          ),
                        ),
                      ),
                      horizontalSpace(width: 2.w),
                      Expanded(
                        child: _chip(
                          context,
                          '14 days',
                          '$due14',
                          const Color(0xFFD97706),
                          onTap: () => _showDueSoonWindowSheet(
                            context,
                            title: 'Due in Next 14 Days',
                            rows: _dueSoonRows(entries, 14),
                          ),
                        ),
                      ),
                      horizontalSpace(width: 2.w),
                      Expanded(
                        child: _chip(
                          context,
                          '30 days',
                          '$due30',
                          const Color(0xFFB45309),
                          onTap: () => _showDueSoonWindowSheet(
                            context,
                            title: 'Due in Next 30 Days',
                            rows: _dueSoonRows(entries, 30),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          verticalSpace(height: .8.h),
          _innerCard(
            context,
            title: 'Overdue by Type',
            icon: Icons.warning_amber_rounded,
            child: Row(
              children:
                  overdueByType.entries.toList().asMap().entries.map((entry) {
                final idx = entry.key;
                final e = entry.value;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: idx == overdueByType.length - 1 ? 0 : 2.w),
                    child: _typeStatTile(
                      context,
                      label: e.key,
                      value: e.value,
                      total: overdue.length,
                      onTap: () => _showDueSoonWindowSheet(
                        context,
                        title: 'Overdue ${e.key}',
                        rows: _overdueRowsByType(entries, e.key),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          verticalSpace(height: .8.h),
          _innerCard(
            context,
            title: context.l10n.topVehiclesByOverdue,
            icon: Icons.local_shipping_rounded,
            child: _listBlock(
              context,
              topVehiclesRows,
              emptyTitle: context.l10n.noOverdueVehicles,
            ),
          ),
          verticalSpace(height: .8.h),
          _innerCard(
            context,
            title: context.l10n.nextDueByLeftValue,
            icon: Icons.av_timer_rounded,
            child: _listBlock(
              context,
              nextDueRows,
              emptyTitle: context.l10n.noUpcomingByLeft,
            ),
          ),
          verticalSpace(height: .8.h),
          _innerCard(
            context,
            title: context.l10n.upcomingCalendar,
            icon: Icons.event_available_rounded,
            child: _listBlock(
              context,
              upcomingDateRows,
              emptyTitle: context.l10n.noUpcomingDates,
            ),
          ),
          verticalSpace(height: .8.h),
          _innerCard(
            context,
            title: context.l10n.criticalMaintenanceAlerts,
            icon: Icons.notification_important_rounded,
            child: _listBlock(
              context,
              criticalRows,
              emptyTitle: context.l10n.noCriticalMaintenanceAlerts,
            ),
          ),
        ],
      ),
    );
  }

  Widget _innerCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: _mW(context, phone: 2.8, compact: 2.4),
        vertical: _mH(context, phone: .9, compact: .8),
      ),
      decoration: BoxDecoration(
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFCBD5E1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: _mW(context, phone: 5.6, compact: 6.4),
                height: _mW(context, phone: 5.6, compact: 6.4),
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
                  size: _mSp(context, phone: 10.4),
                  color: Colors.white,
                ),
              ),
              horizontalSpace(width: 2.w),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: _mSp(context, phone: 12.8),
                    fontWeight: FontWeight.w900,
                    color: onSurface.withValues(alpha: .92),
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

  Widget _kpiTile(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _mW(context, phone: 2.4, compact: 2.1),
        vertical: _mH(context, phone: .85, compact: .75),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            color.withValues(alpha: .18),
            color.withValues(alpha: .10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .35)),
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
              fontSize: _mSp(context, phone: 12.0),
              fontWeight: FontWeight.w700,
            ),
          ),
          verticalSpace(height: .15.h),
          Text(
            value,
            style: AppStyles.boldTextStyle(context)
                .copyWith(fontSize: _mSp(context, phone: 14.2)),
          ),
          verticalSpace(height: .1.h),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: _mSp(context, phone: 11.3),
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: .65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    String value,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _mW(context, phone: 2.1, compact: 1.9),
          vertical: _mH(context, phone: .55, compact: .5),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              color.withValues(alpha: .18),
              color.withValues(alpha: .10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: .28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: _mSp(context, phone: 12.0),
                fontWeight: FontWeight.w600,
              ),
            ),
            verticalSpace(height: .1.h),
            Text(
              value,
              style: AppStyles.semiboldTextStyle(context).copyWith(
                fontSize: _mSp(context, phone: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeStatTile(
    BuildContext context, {
    required String label,
    required int value,
    required int total,
    VoidCallback? onTap,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final ratio = total == 0 ? 0.0 : value / total;
    final percent = (ratio * 100).toStringAsFixed(0);

    final color = switch (label) {
      'Odometer' => const Color(0xFFEF4444),
      'Engine Hours' => const Color(0xFFF97316),
      _ => const Color(0xFFEAB308),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _mW(context, phone: 2.1, compact: 1.9),
          vertical: _mH(context, phone: .55, compact: .5),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              color.withValues(alpha: .16),
              color.withValues(alpha: .08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: .28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.semiboldTextStyle(context)
                  .copyWith(fontSize: _mSp(context, phone: 11.8)),
            ),
            verticalSpace(height: .3.h),
            Text(
              '$value ($percent%)',
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: _mSp(context, phone: 11.8),
                fontWeight: FontWeight.w700,
                color: onSurface.withValues(alpha: .88),
              ),
            ),
            verticalSpace(height: .3.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: .7.h,
                value: ratio,
                backgroundColor: onSurface.withValues(alpha: .14),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listBlock(
    BuildContext context,
    List<(String, String, bool)> rows, {
    required String emptyTitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    if (rows.isEmpty) {
      return Text(
        emptyTitle,
        style: AppStyles.regularTextStyle(context)
            .copyWith(fontSize: _mSp(context, phone: 12.0)),
      );
    }
    return Column(
      children: rows.asMap().entries.map((entry) {
        final idx = entry.key;
        final e = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: idx == rows.length - 1 ? 0 : .45.h),
          padding: EdgeInsets.symmetric(horizontal: 2.3.w, vertical: .58.h),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: .04)
                : Colors.white.withValues(alpha: .88),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: onSurface.withValues(alpha: isDark ? .12 : .10),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  e.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: _mSp(context, phone: 11.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              horizontalSpace(width: 2.w),
              Text(
                e.$2,
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  fontSize: _mSp(context, phone: 11.4),
                  color: e.$3 ? const Color(0xFFDC2626) : onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _shareMaintenanceAnalytics({
    required int total,
    required double healthPct,
    required int dueCount,
    required int overdueCount,
    required int due7,
    required int due14,
    required int due30,
    required Map<String, int> overdueByType,
    required List<(String, String, bool)> topVehiclesRows,
    required List<(String, String, bool)> nextDueRows,
    required List<(String, String, bool)> upcomingDateRows,
    required List<(String, String, bool)> criticalRows,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('Maintenance Analytics Report');
    buffer.writeln('Scope: All Vehicles');
    buffer.writeln('Total Services: $total');
    buffer.writeln('Health Score: ${healthPct.toStringAsFixed(1)}%');
    buffer.writeln('Due Soon: $dueCount');
    buffer.writeln('Overdue: $overdueCount');
    buffer.writeln('');
    buffer.writeln('Due Soon Windows');
    buffer.writeln('- 7 days: $due7');
    buffer.writeln('- 14 days: $due14');
    buffer.writeln('- 30 days: $due30');
    buffer.writeln('');
    buffer.writeln('Overdue by Type');
    buffer.writeln('- Odometer: ${overdueByType['Odometer'] ?? 0}');
    buffer.writeln('- Engine Hours: ${overdueByType['Engine Hours'] ?? 0}');
    buffer.writeln('- Date/Days: ${overdueByType['Date/Days'] ?? 0}');
    buffer.writeln('');
    buffer.writeln('Top Vehicles by Overdue');
    if (topVehiclesRows.isEmpty) {
      buffer.writeln('- None');
    } else {
      for (final row in topVehiclesRows) {
        buffer.writeln('- ${row.$1}: ${row.$2}');
      }
    }
    buffer.writeln('');
    buffer.writeln('Next Due by Left Value');
    if (nextDueRows.isEmpty) {
      buffer.writeln('- None');
    } else {
      for (final row in nextDueRows) {
        buffer.writeln('- ${row.$1}: ${row.$2}');
      }
    }
    buffer.writeln('');
    buffer.writeln('Upcoming Calendar');
    if (upcomingDateRows.isEmpty) {
      buffer.writeln('- None');
    } else {
      for (final row in upcomingDateRows) {
        buffer.writeln('- ${row.$1}: ${row.$2}');
      }
    }
    buffer.writeln('');
    buffer.writeln('Critical Maintenance Alerts');
    if (criticalRows.isEmpty) {
      buffer.writeln('- None');
    } else {
      for (final row in criticalRows) {
        buffer.writeln('- ${row.$1}: ${row.$2}');
      }
    }

    await SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  List<(String, String, bool)> _dueSoonRows(
    List<_MaintenanceEntry> entries,
    int windowDays,
  ) {
    final rows = entries
        .where((e) =>
            e.daysLeft != null && e.daysLeft! >= 0 && e.daysLeft! <= windowDays)
        .toList()
      ..sort((a, b) => (a.daysLeft ?? 9999).compareTo(b.daysLeft ?? 9999));
    return rows
        .map((e) => (
              '${e.deviceName} • ${e.serviceName}',
              '${e.daysLeft} days',
              false,
            ))
        .toList();
  }

  List<(String, String, bool)> _overdueRowsByType(
    List<_MaintenanceEntry> entries,
    String typeLabel,
  ) {
    final normalized = switch (typeLabel) {
      'Odometer' => 'odometer',
      'Engine Hours' => 'engine_hours',
      _ => 'days',
    };
    final rows = entries
        .where((e) => e.isOverdue && e.type == normalized)
        .toList()
      ..sort((a, b) => a.serviceName.compareTo(b.serviceName));
    return rows
        .map(
          (e) => (
            '${e.deviceName} • ${e.serviceName}',
            e.daysLeft != null && e.daysLeft! < 0
                ? '${-e.daysLeft!} days overdue'
                : 'OVERDUE',
            true,
          ),
        )
        .toList();
  }

  void _showDueSoonWindowSheet(
    BuildContext context, {
    required String title,
    required List<(String, String, bool)> rows,
  }) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 70.h, maxHeight: 70.h),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.4.h, 4.w, 1.2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 10.w,
                    height: .45.h,
                    decoration: BoxDecoration(
                      color: onSurface.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                verticalSpace(height: 1.2.h),
                Text(
                  title,
                  style: AppStyles.semiboldTextStyle(ctx)
                      .copyWith(fontSize: 14.2.sp),
                ),
                verticalSpace(height: 1.h),
                Expanded(
                  child: rows.isEmpty
                      ? Center(
                          child: Text(
                            'No maintenance due in this window',
                            style: AppStyles.regularTextStyle(ctx)
                                .copyWith(fontSize: 13.sp),
                          ),
                        )
                      : ListView.separated(
                          itemCount: rows.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1.1.h,
                            color: Theme.of(ctx)
                                .dividerColor
                                .withValues(alpha: .35),
                          ),
                          itemBuilder: (_, i) {
                            final row = rows[i];
                            return Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    row.$1,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppStyles.regularTextStyle(ctx)
                                        .copyWith(fontSize: 13.3.sp),
                                  ),
                                ),
                                horizontalSpace(width: 2.w),
                                Text(
                                  row.$2,
                                  style: AppStyles.semiboldTextStyle(ctx)
                                      .copyWith(fontSize: 12.8.sp),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

double _mSp(
  BuildContext context, {
  required double phone,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= 360) return (phone * 1.08).sp;
  if (width <= 393) return (phone * 1.10).sp;
  if (width <= 430) return (phone * 1.06).sp;
  return (phone * 1.03).sp;
}

double _mW(
  BuildContext context, {
  required double phone,
  double? compact,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= 360 && compact != null) return compact.w;
  return phone.w;
}

double _mH(
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

class _MaintenanceEntry {
  final String deviceName;
  final String serviceName;
  final String type;
  final String typeLabel;
  final String unitLabel;
  final double percent;
  final double? left;
  final int? daysLeft;
  final DateTime? dueDate;
  final DateTime? remindDate;
  final bool isOverdue;
  final bool isDueSoon;

  _MaintenanceEntry({
    required this.deviceName,
    required this.serviceName,
    required this.type,
    required this.typeLabel,
    required this.unitLabel,
    required this.percent,
    required this.left,
    required this.daysLeft,
    required this.dueDate,
    required this.remindDate,
    required this.isOverdue,
    required this.isDueSoon,
  });

  static _MaintenanceEntry fromItem(MaintenanceItem item) {
    DateTime? parse(String value) {
      final text = value.trim();
      if (text.isEmpty || text.toLowerCase() == 'null') return null;
      return DateTime.tryParse(text.replaceFirst(' ', 'T'));
    }

    final normalizedType = item.type.isNotEmpty
        ? item.type.toLowerCase()
        : item.expirationBy.toLowerCase();
    final due = parse(item.expiresDate);
    final remind = parse(item.remindDate);
    final overdue = item.status.toLowerCase() == 'expired' ||
        item.percent >= 100 ||
        item.left <= 0;

    final dueSoonByDays =
        item.daysLeft != null && item.daysLeft! >= 0 && item.daysLeft! <= 30;
    final dueSoonByPct =
        item.daysLeft == null && !overdue && item.percent >= 90;

    return _MaintenanceEntry(
      deviceName: item.device,
      serviceName: item.name.isEmpty ? 'Service #${item.serviceId}' : item.name,
      type: normalizedType,
      typeLabel: item.typeLabel.isEmpty ? normalizedType : item.typeLabel,
      unitLabel: item.unit.isEmpty
          ? (normalizedType == 'engine_hours'
              ? 'hrs'
              : normalizedType == 'odometer'
                  ? 'km'
                  : 'days')
          : item.unit,
      percent: item.percent,
      left: item.left,
      daysLeft: item.daysLeft,
      dueDate: due,
      remindDate: remind,
      isOverdue: overdue,
      isDueSoon: dueSoonByDays || dueSoonByPct,
    );
  }
}
