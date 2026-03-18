import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/device_service_model.dart';
import 'package:trackerapp/providers/device_service_provider.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class SingleVehicleMaintenanceAnalyticsCard extends StatefulWidget {
  final int deviceId;
  final String vehicleName;

  const SingleVehicleMaintenanceAnalyticsCard({
    super.key,
    required this.deviceId,
    required this.vehicleName,
  });

  @override
  State<SingleVehicleMaintenanceAnalyticsCard> createState() =>
      _SingleVehicleMaintenanceAnalyticsCardState();
}

class _SingleVehicleMaintenanceAnalyticsCardState
    extends State<SingleVehicleMaintenanceAnalyticsCard> {
  late final DeviceServiceProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = DeviceServiceProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.initialize(deviceId: widget.deviceId);
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

    return ChangeNotifierProvider<DeviceServiceProvider>.value(
      value: _provider,
      child: Consumer<DeviceServiceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.05.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF101A2A) : Colors.white,
                borderRadius: BorderRadius.circular(14.sp),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: SizedBox(
                height: 24.h,
                child: const Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (provider.errorMessage != null) {
            return _errorBlock(
              context,
              error: provider.errorMessage!,
              onRetry: () => provider.initialize(deviceId: widget.deviceId),
            );
          }

          final entries = provider.services
              .map((service) => _MaintenanceEntry.fromService(service))
              .toList();

          final total = entries.length;
          final overdue = entries.where((e) => e.isOverdue).toList();
          final due =
              entries.where((e) => e.isDueSoon && !e.isOverdue).toList();
          final ok =
              entries.where((e) => !e.isOverdue && !e.isDueSoon).toList();

          final healthPct = total == 0 ? 0.0 : (ok.length / total) * 100;

          final due7 = entries
              .where((e) =>
                  e.daysLeft != null && e.daysLeft! >= 0 && e.daysLeft! <= 7)
              .length;
          final due14 = entries
              .where((e) =>
                  e.daysLeft != null && e.daysLeft! >= 0 && e.daysLeft! <= 14)
              .length;
          final due30 = entries
              .where((e) =>
                  e.daysLeft != null && e.daysLeft! >= 0 && e.daysLeft! <= 30)
              .length;

          final overdueByType = <String, int>{
            'Odometer': overdue.where((e) => e.type == 'odometer').length,
            'Engine Hours':
                overdue.where((e) => e.type == 'engine_hours').length,
            'Date/Days': overdue.where((e) => e.type == 'days').length,
          };

          final upcomingByLeft = entries
              .where((e) => !e.isOverdue && e.left != null && e.left! >= 0)
              .toList()
            ..sort((a, b) => (a.left ?? 1e12).compareTo(b.left ?? 1e12));

          final upcomingByDate = entries
              .where((e) => e.dueDate != null)
              .toList()
            ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

          final overdueServices = overdue.toList()
            ..sort((a, b) {
              final aSeverity = (a.percent) +
                  (a.daysLeft != null
                      ? math.max(0, -a.daysLeft!.toDouble()) * 2
                      : 0);
              final bSeverity = (b.percent) +
                  (b.daysLeft != null
                      ? math.max(0, -b.daysLeft!.toDouble()) * 2
                      : 0);
              return bSeverity.compareTo(aSeverity);
            });
          final overdueServiceRows = overdueServices
              .take(5)
              .map((e) => (e.serviceName, e.typeLabel, true))
              .toList();

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
                  e.serviceName,
                  e.isOverdue
                      ? 'OVERDUE'
                      : 'Risk ${e.percent.toStringAsFixed(0)}%',
                  e.isOverdue,
                ),
              )
              .toList();

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Maintenance Analytics",
                        style: AppStyles.boldTextStyle(context)
                            .copyWith(fontSize: 14.6.sp),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _shareMaintenanceAnalytics(
                        vehicleName: widget.vehicleName,
                        total: total,
                        healthPct: healthPct,
                        dueCount: due.length,
                        overdueCount: overdue.length,
                        due7: due7,
                        due14: due14,
                        due30: due30,
                        overdueByType: overdueByType,
                        overdueServiceRows: overdueServiceRows,
                        nextDueRows: nextDueRows,
                        upcomingDateRows: upcomingDateRows,
                        criticalRows: criticalRows,
                      ),
                      icon: const Icon(Icons.ios_share_rounded),
                      tooltip: 'Share',
                    ),
                  ],
                ),
                verticalSpace(height: .8.h),
                Row(
                  children: [
                    Expanded(
                      child: _kpiTile(
                        context,
                        title: 'Health Score',
                        value: '${healthPct.toStringAsFixed(1)}%',
                        subtitle: '${ok.length}/$total healthy',
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                    horizontalSpace(width: 2.w),
                    Expanded(
                      child: _kpiTile(
                        context,
                        title: 'Due Soon',
                        value: due.toString(),
                        subtitle: 'Overdue: ${overdue.length}',
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                verticalSpace(height: .8.h),
                _innerCard(
                  context,
                  title: 'Due Soon Windows',
                  child: Row(
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
                  child: Row(
                    children: overdueByType.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
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
                  title: 'Top Overdue Services',
                  child: _listBlock(
                    context,
                    overdueServiceRows,
                    emptyTitle: 'No overdue services',
                  ),
                ),
                verticalSpace(height: .8.h),
                _innerCard(
                  context,
                  title: 'Next Due by Left Value',
                  child: _listBlock(
                    context,
                    nextDueRows,
                    emptyTitle: 'No upcoming by left',
                  ),
                ),
                verticalSpace(height: .8.h),
                _innerCard(
                  context,
                  title: 'Upcoming Calendar',
                  child: _listBlock(
                    context,
                    upcomingDateRows,
                    emptyTitle: 'No upcoming dates',
                  ),
                ),
                verticalSpace(height: .8.h),
                _innerCard(
                  context,
                  title: 'Critical Maintenance Alerts',
                  child: _listBlock(
                    context,
                    criticalRows,
                    emptyTitle: 'No critical maintenance alerts',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _errorBlock(
    BuildContext context, {
    required String error,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.05.h),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF101A2A)
            : Colors.white,
        borderRadius: BorderRadius.circular(14.sp),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black12,
        ),
      ),
      child: Column(
        children: [
          Text(
            error,
            style:
                AppStyles.regularTextStyle(context).copyWith(fontSize: 12.8.sp),
            textAlign: TextAlign.center,
          ),
          verticalSpace(height: .6.h),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _innerCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
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
                .copyWith(fontSize: 12.4.sp),
          ),
          verticalSpace(height: .45.h),
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
      padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: .85.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 11.4.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          verticalSpace(height: .15.h),
          Text(
            value,
            style: AppStyles.boldTextStyle(context).copyWith(fontSize: 15.sp),
          ),
          verticalSpace(height: .1.h),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 10.5.sp,
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
        padding: EdgeInsets.symmetric(horizontal: 2.1.w, vertical: .55.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
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
                fontSize: 10.8.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            verticalSpace(height: .1.h),
            Text(
              value,
              style: AppStyles.semiboldTextStyle(context).copyWith(
                fontSize: 12.6.sp,
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
        padding: EdgeInsets.symmetric(horizontal: 2.1.w, vertical: .55.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .10),
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
                  .copyWith(fontSize: 10.8.sp),
            ),
            verticalSpace(height: .15.h),
            Text(
              '$value ($percent%)',
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 10.6.sp,
                fontWeight: FontWeight.w700,
                color: onSurface.withValues(alpha: .88),
              ),
            ),
            verticalSpace(height: .22.h),
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
    if (rows.isEmpty) {
      return Text(
        emptyTitle,
        style: AppStyles.regularTextStyle(context).copyWith(fontSize: 11.4.sp),
      );
    }
    return Column(
      children: rows
          .map(
            (e) => Padding(
              padding: EdgeInsets.only(bottom: .35.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.regularTextStyle(context)
                          .copyWith(fontSize: 11.4.sp),
                    ),
                  ),
                  horizontalSpace(width: 2.w),
                  Text(
                    e.$2,
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 11.2.sp,
                      color: e.$3
                          ? const Color(0xFFDC2626)
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _shareMaintenanceAnalytics({
    required String vehicleName,
    required int total,
    required double healthPct,
    required int dueCount,
    required int overdueCount,
    required int due7,
    required int due14,
    required int due30,
    required Map<String, int> overdueByType,
    required List<(String, String, bool)> overdueServiceRows,
    required List<(String, String, bool)> nextDueRows,
    required List<(String, String, bool)> upcomingDateRows,
    required List<(String, String, bool)> criticalRows,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('Maintenance Analytics Report');
    buffer.writeln('Scope: Single Vehicle');
    buffer.writeln('Vehicle: $vehicleName');
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
    buffer.writeln('Top Overdue Services');
    if (overdueServiceRows.isEmpty) {
      buffer.writeln('- None');
    } else {
      for (final row in overdueServiceRows) {
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
        .map((e) => (e.serviceName, '${e.daysLeft} days', false))
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
            e.serviceName,
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
                                .copyWith(fontSize: 12.sp),
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
                                        .copyWith(fontSize: 12.3.sp),
                                  ),
                                ),
                                horizontalSpace(width: 2.w),
                                Text(
                                  row.$2,
                                  style: AppStyles.semiboldTextStyle(ctx)
                                      .copyWith(fontSize: 11.8.sp),
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

class _MaintenanceEntry {
  final String serviceName;
  final String type;
  final String typeLabel;
  final String unitLabel;
  final double percent;
  final double? left;
  final int? daysLeft;
  final DateTime? dueDate;
  final bool isOverdue;
  final bool isDueSoon;

  _MaintenanceEntry({
    required this.serviceName,
    required this.type,
    required this.typeLabel,
    required this.unitLabel,
    required this.percent,
    required this.left,
    required this.daysLeft,
    required this.dueDate,
    required this.isOverdue,
    required this.isDueSoon,
  });

  static _MaintenanceEntry fromService(DeviceService service) {
    double? parseNum(String value) {
      final text = value.trim();
      if (text.isEmpty) return null;
      return double.tryParse(text);
    }

    DateTime? parseDate(String value) {
      final text = value.trim();
      if (text.isEmpty) return null;
      final fromIso = DateTime.tryParse(text.replaceFirst(' ', 'T'));
      if (fromIso != null) return fromIso;
      final parts = text.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }
      return null;
    }

    final normalizedType = service.expirationBy.trim().toLowerCase();
    final interval = parseNum(service.interval) ?? 0;
    final triggerLeft = parseNum(service.triggerEventLeft) ?? 0;

    double? left;
    int? daysLeft;
    DateTime? dueDate = service.expiresDate ?? parseDate(service.lastService);
    double percent = 0;

    if (normalizedType == 'odometer') {
      final current = (service.currentOdometer ?? 0).toDouble();
      final last = parseNum(service.lastService) ?? 0;
      final consumed = math.max(0, current - last);
      left = interval - consumed;
      if (interval > 0) {
        percent = (consumed / interval) * 100;
      }
    } else if (normalizedType == 'engine_hours') {
      final current = parseNum(service.currentEngineHours) ?? 0;
      final last = parseNum(service.lastService) ?? 0;
      final consumed = math.max(0, current - last);
      left = interval - consumed;
      if (interval > 0) {
        percent = (consumed / interval) * 100;
      }
    } else {
      final lastDate = parseDate(service.lastService);
      if (service.expiresDate != null) {
        dueDate = service.expiresDate;
      } else if (lastDate != null && interval > 0) {
        dueDate = lastDate.add(Duration(days: interval.round()));
      }
      if (dueDate != null) {
        final nowDate = DateTime.now();
        final today = DateTime(nowDate.year, nowDate.month, nowDate.day);
        final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
        daysLeft = due.difference(today).inDays;
      }
      if (lastDate != null && dueDate != null) {
        final total = dueDate.difference(lastDate).inDays.toDouble();
        final elapsed = DateTime.now().difference(lastDate).inDays.toDouble();
        if (total > 0) {
          percent = (elapsed / total) * 100;
        }
      }
    }

    if (percent.isNaN || percent.isInfinite) {
      percent = 0;
    }
    percent = percent.clamp(0, 100).toDouble();

    final isOverdue = service.expired ||
        (daysLeft != null && daysLeft < 0) ||
        (left != null && left <= 0);
    final isDueSoon = !isOverdue &&
        ((daysLeft != null && daysLeft >= 0 && daysLeft <= 30) ||
            (left != null && triggerLeft > 0 && left <= triggerLeft) ||
            percent >= 90);

    final typeLabel = switch (normalizedType) {
      'engine_hours' => 'Engine Hours',
      'odometer' => 'Odometer',
      _ => 'Date/Days',
    };
    final unitLabel = switch (normalizedType) {
      'engine_hours' => 'hrs',
      'odometer' => 'km',
      _ => 'days',
    };

    return _MaintenanceEntry(
      serviceName:
          service.name.isEmpty ? 'Service #${service.id}' : service.name,
      type: normalizedType,
      typeLabel: typeLabel,
      unitLabel: unitLabel,
      percent: percent,
      left: left,
      daysLeft: daysLeft,
      dueDate: dueDate,
      isOverdue: isOverdue,
      isDueSoon: isDueSoon,
    );
  }
}
