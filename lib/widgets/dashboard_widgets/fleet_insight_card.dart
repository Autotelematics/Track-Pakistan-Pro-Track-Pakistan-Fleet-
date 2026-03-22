import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_history_model.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/providers/dashboard_expense_analytics_provider.dart';
import 'package:trackerapp/providers/performance_provider.dart';
import 'package:trackerapp/providers/task_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class FleetInsightCard extends StatefulWidget {
  final GetDashboardModel dashboard;
  final GetDashboardHistoryModel? history;
  final int offlineOver24hCount;

  const FleetInsightCard({
    super.key,
    required this.dashboard,
    required this.history,
    required this.offlineOver24hCount,
  });

  @override
  State<FleetInsightCard> createState() => _FleetInsightCardState();
}

class _FleetInsightCardState extends State<FleetInsightCard> {
  late final DashboardExpenseAnalyticsProvider _expenseProvider;
  final int _sessionSeed = DateTime.now().microsecondsSinceEpoch.abs();
  bool _initialized = false;
  _InsightResult? _lockedInsight;

  @override
  void initState() {
    super.initState();
    _expenseProvider = DashboardExpenseAnalyticsProvider();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      context.read<TaskProvider>().fetchTasks();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      await context.read<PerformanceProvider>().loadPerformance(
            from: today.subtract(const Duration(days: 6)),
            to: today,
          );
      await _expenseProvider.initialize();
    });
  }

  @override
  void dispose() {
    _expenseProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider<DashboardExpenseAnalyticsProvider>.value(
      value: _expenseProvider,
      child: Consumer3<TaskProvider, PerformanceProvider,
          DashboardExpenseAnalyticsProvider>(
        builder:
            (context, taskProvider, performanceProvider, expenseProvider, _) {
          final insight = _buildInsight(
            dashboard: widget.dashboard,
            history: widget.history,
            offlineOver24hCount: widget.offlineOver24hCount,
            taskProvider: taskProvider,
            performanceProvider: performanceProvider,
            expenseProvider: expenseProvider,
          );
          final shouldLock = _isInsightReadyToLock(
            taskProvider: taskProvider,
            performanceProvider: performanceProvider,
            expenseProvider: expenseProvider,
          );
          if (_lockedInsight == null && shouldLock) {
            _lockedInsight = insight;
          }
          final displayInsight = _lockedInsight ?? insight;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 1.4.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color:
                    displayInsight.color.withValues(alpha: isDark ? .22 : .14),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        theme.cardColor,
                        displayInsight.color.withValues(alpha: .10),
                      ]
                    : [
                        theme.cardColor,
                        displayInsight.color.withValues(alpha: .07),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.48)
                      : Colors.black.withValues(alpha: 0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: displayInsight.color
                      .withValues(alpha: isDark ? .10 : .08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -18,
                  top: -24,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          displayInsight.color.withValues(alpha: .16),
                          displayInsight.color.withValues(alpha: .02),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 18.sp,
                          color: displayInsight.color,
                        ),
                        horizontalSpace(width: 2.w),
                        Expanded(
                          child: Text(
                            context.l10n.fleetInsightTitle,
                            style: AppStyles.semiboldTextStyle(context)
                                .copyWith(fontSize: 15.2.sp),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.2.w, vertical: .4.h),
                          decoration: BoxDecoration(
                            color: displayInsight.color.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: displayInsight.color
                                    .withValues(alpha: .18)),
                          ),
                          child: Text(
                            displayInsight.statusLabel,
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w800,
                              color: displayInsight.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(height: 1.05.h),
                    Text(
                      displayInsight.headline,
                      style: AppStyles.semiboldTextStyle(context).copyWith(
                        fontSize: 14.1.sp,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: .92),
                      ),
                    ),
                    verticalSpace(height: .7.h),
                    Text(
                      displayInsight.message,
                      style: AppStyles.regularTextStyle(context).copyWith(
                        fontSize: 12.6.sp,
                        height: 1.35,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: .8),
                      ),
                    ),
                    if (displayInsight.highlights.isNotEmpty) ...[
                      verticalSpace(height: 1.0.h),
                      Wrap(
                        spacing: 1.6.w,
                        runSpacing: .8.h,
                        children: displayInsight.highlights
                            .map(
                              (item) => Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.0.w, vertical: .35.h),
                                decoration: BoxDecoration(
                                  color: displayInsight.color
                                      .withValues(alpha: isDark ? .12 : .08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: displayInsight.color
                                        .withValues(alpha: isDark ? .22 : .14),
                                  ),
                                ),
                                child: Text(
                                  item,
                                  style: AppStyles.regularTextStyle(context)
                                      .copyWith(
                                    fontSize: 11.1.sp,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: isDark ? .92 : .84),
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _InsightResult _buildInsight({
    required GetDashboardModel dashboard,
    required GetDashboardHistoryModel? history,
    required int offlineOver24hCount,
    required TaskProvider taskProvider,
    required PerformanceProvider performanceProvider,
    required DashboardExpenseAnalyticsProvider expenseProvider,
  }) {
    final l10n = context.l10n;
    final status = dashboard.statusCounts;
    final alerts = dashboard.alertsSummary;
    final totalVehicles = max(status.total, 1);
    final offlineNow = status.offline + status.expired + status.neverConnected;
    final offlineRatio = offlineNow / totalVehicles;
    final overSpeedRatio =
        alerts.total == 0 ? 0 : alerts.overSpeed / alerts.total;
    final dueMaintenance = dashboard.maintenance.where((item) {
      final dueByDay = (item.daysLeft ?? 1) <= 0;
      final expired = item.expired == 1;
      final statusDue = item.status.toLowerCase().contains('due') ||
          item.status.toLowerCase().contains('expired');
      return dueByDay || expired || statusDue;
    }).length;

    int taskBacklog = 0;
    int longOpenTasks = 0;
    final now = DateTime.now();
    for (final task in taskProvider.tasks) {
      final statusName = task.statusName.toLowerCase();
      final isOpen = !(statusName.contains('complete') ||
          statusName.contains('done') ||
          statusName.contains('closed'));
      if (!isOpen) continue;
      taskBacklog += 1;
      if (task.createdAt != null &&
          now.difference(task.createdAt!) >= const Duration(days: 2)) {
        longOpenTasks += 1;
      }
    }

    double avgPerformance = 0;
    if (performanceProvider.vehicleKpis.isNotEmpty) {
      final sum = performanceProvider.vehicleKpis
          .fold<double>(0, (acc, item) => acc + item.score);
      avgPerformance = sum / performanceProvider.vehicleKpis.length;
    }

    final expenseChange = expenseProvider.monthChangePercent;
    final expenseTotal = expenseProvider.thisMonthTotal;

    final issueScores = <String, double>{
      'availability': offlineRatio * 100 + (offlineOver24hCount * 2.5),
      'safety': overSpeedRatio * 100 + (alerts.overSpeed * 0.8),
      'maintenance': dueMaintenance * 8.0,
      'tasks': taskBacklog * 2.0 + longOpenTasks * 3.5,
      'performance': avgPerformance <= 0 ? 0 : (100 - avgPerformance) * 1.1,
      'expense': expenseChange > 0 ? expenseChange * 0.9 : 0,
    };

    double healthScore = 100;
    for (final value in issueScores.values) {
      healthScore -= value * 0.15;
    }
    healthScore = healthScore.clamp(0, 100);

    Color statusColor;
    String statusLabel;
    if (healthScore >= 72) {
      statusColor = const Color(0xFF16A34A);
      statusLabel = l10n.fleetStatusStable;
    } else if (healthScore >= 45) {
      statusColor = const Color(0xFFD97706);
      statusLabel = l10n.fleetStatusNeedsAttention;
    } else {
      statusColor = const Color(0xFFDC2626);
      statusLabel = l10n.fleetStatusCritical;
    }

    final seed = _stableSeed(
      totalVehicles: totalVehicles,
      onlineVehicles: status.online,
      alertsTotal: alerts.total,
      overspeedAlerts: alerts.overSpeed,
      dueMaintenance: dueMaintenance,
      taskBacklog: taskBacklog,
      avgPerformance: avgPerformance,
      expenseTotal: expenseTotal,
      historyDistance: history?.summary.totalDistanceKm ?? 0,
      sessionSeed: _sessionSeed,
    );

    final topDistance = history?.summary.topDistance.isNotEmpty == true
        ? history!.summary.topDistance.first
        : null;
    final topSpeed = history?.summary.topSpeeds.isNotEmpty == true
        ? history!.summary.topSpeeds.first
        : null;
    final worstVehicleByOverspeed =
        List.of(performanceProvider.vehicleKpis, growable: false)
          ..sort(
            (a, b) => b.overSpeedAlertCount.compareTo(a.overSpeedAlertCount),
          );

    final candidateInsights = <_InsightCandidate>[
      _InsightCandidate(
        score: issueScores['availability'] ?? 0,
        headlines: [l10n.fleetInsightAvailabilityTitle],
        details: [
          l10n.fleetInsightAvailabilityDetail(
            '$offlineNow',
            '$totalVehicles',
            '$offlineOver24hCount',
          ),
        ],
      ),
      _InsightCandidate(
        score: issueScores['safety'] ?? 0,
        headlines: [l10n.fleetInsightSafetyTitle],
        details: [
          if (worstVehicleByOverspeed.isNotEmpty &&
              worstVehicleByOverspeed.first.overSpeedAlertCount > 0)
            l10n.fleetInsightSafetyVehicleDetail(
              worstVehicleByOverspeed.first.deviceName,
              '${worstVehicleByOverspeed.first.overSpeedAlertCount}',
            )
          else
            l10n.fleetInsightSafetyOverallDetail(
              '${alerts.overSpeed}',
              '${alerts.total}',
            ),
        ],
      ),
      _InsightCandidate(
        score: issueScores['maintenance'] ?? 0,
        headlines: [l10n.fleetInsightMaintenanceTitle],
        details: [
          l10n.fleetInsightMaintenanceDetail('$dueMaintenance'),
        ],
      ),
      _InsightCandidate(
        score: issueScores['tasks'] ?? 0,
        headlines: [l10n.fleetInsightTasksTitle],
        details: [
          l10n.fleetInsightTasksDetail('$taskBacklog', '$longOpenTasks'),
        ],
      ),
      _InsightCandidate(
        score: issueScores['performance'] ?? 0,
        headlines: [l10n.fleetInsightPerformanceTitle],
        details: [
          avgPerformance > 0
              ? l10n.fleetInsightPerformanceDetail(
                  avgPerformance.toStringAsFixed(1),
                )
              : l10n.fleetInsightPerformanceLoading,
        ],
      ),
      _InsightCandidate(
        score: issueScores['expense'] ?? 0,
        headlines: [l10n.fleetInsightExpenseTitle],
        details: [
          l10n.fleetInsightExpenseDetail(
            expenseTotal.toStringAsFixed(0),
            expenseChange.toStringAsFixed(1),
          ),
        ],
      ),
      _InsightCandidate(
        score: (history?.summary.totalDistanceKm ?? 0) > 0 ? 22 : 0,
        headlines: [l10n.fleetInsightDistanceTitle],
        details: [
          if (topDistance != null)
            l10n.fleetInsightDistanceLeaderDetail(
              topDistance.deviceName,
              topDistance.distanceKm.toStringAsFixed(1),
            )
          else
            l10n.fleetInsightDistanceTotalDetail(
              (history?.summary.totalDistanceKm ?? 0).toStringAsFixed(0),
            ),
          if (topSpeed != null)
            l10n.fleetInsightDistanceSpeedDetail(
              topSpeed.deviceName,
              '${topSpeed.topSpeedKph}',
              (history?.summary.totalDistanceKm ?? 0).toStringAsFixed(0),
            )
          else
            l10n.fleetInsightDistanceAvgDetail(
              (history?.summary.totalDistanceKm ?? 0).toStringAsFixed(0),
              (history?.summary.averageDistanceKm ?? 0).toStringAsFixed(1),
            ),
        ],
      ),
    ];

    candidateInsights.sort((a, b) => b.score.compareTo(a.score));
    final activeCandidates =
        candidateInsights.where((candidate) => candidate.score > 0).toList();
    final topPool =
        (activeCandidates.isEmpty ? candidateInsights : activeCandidates)
            .take(4)
            .toList();
    final selected = topPool[seed % topPool.length];
    final wordingIndex = (seed ~/ 3) % selected.headlines.length;
    final detailIndex = (seed ~/ 5) % selected.details.length;
    final intro = selected.headlines[wordingIndex];
    final issueMessage = selected.details[detailIndex];

    final severityIntros = healthScore >= 72
        ? [
            l10n.fleetInsightIntroPositive1,
            l10n.fleetInsightIntroPositive2,
            l10n.fleetInsightIntroPositive3,
          ]
        : healthScore >= 45
            ? [
                l10n.fleetInsightIntroWarning1,
                l10n.fleetInsightIntroWarning2,
                l10n.fleetInsightIntroWarning3,
              ]
            : [
                l10n.fleetInsightIntroCritical1,
                l10n.fleetInsightIntroCritical2,
                l10n.fleetInsightIntroCritical3,
              ];
    final severityIntro = severityIntros[seed % severityIntros.length];

    final movementSummary = history == null
        ? l10n.fleetInsightMovementLoading
        : l10n.fleetInsightMovementSummary(
            history.summary.totalDistanceKm.toStringAsFixed(0),
            history.summary.averageDistanceKm.toStringAsFixed(1),
          );

    final highlights = <String>[
      l10n.fleetInsightHealthChip(healthScore.toStringAsFixed(0)),
      l10n.fleetInsightOnlineChip('${status.online}'),
      l10n.fleetInsightOfflineChip('$offlineNow'),
      l10n.fleetInsightOverspeedChip('${alerts.overSpeed}'),
      l10n.fleetInsightMaintenanceChip('$dueMaintenance'),
      if (taskProvider.tasks.isNotEmpty)
        l10n.fleetInsightOpenTasksChip('$taskBacklog'),
      if (avgPerformance > 0)
        l10n.fleetInsightPerformanceChip(avgPerformance.toStringAsFixed(0)),
      if (!expenseProvider.isLoading &&
          expenseProvider.error == null &&
          expenseProvider.transactionCount >= 0)
        l10n.fleetInsightExpenseChip(expenseChange.toStringAsFixed(1)),
    ];

    return _InsightResult(
      color: statusColor,
      statusLabel: statusLabel,
      headline: intro,
      message: '$severityIntro $issueMessage $movementSummary',
      highlights: highlights,
    );
  }

  int _stableSeed({
    required int totalVehicles,
    required int onlineVehicles,
    required int alertsTotal,
    required int overspeedAlerts,
    required int dueMaintenance,
    required int taskBacklog,
    required double avgPerformance,
    required double expenseTotal,
    required double historyDistance,
    required int sessionSeed,
  }) {
    final dataKey = [
      totalVehicles,
      onlineVehicles,
      alertsTotal,
      overspeedAlerts,
      dueMaintenance,
      taskBacklog,
      avgPerformance.round(),
      expenseTotal.round(),
      historyDistance.round(),
    ].join('|');
    return '$sessionSeed|$dataKey'.hashCode.abs();
  }

  bool _isInsightReadyToLock({
    required TaskProvider taskProvider,
    required PerformanceProvider performanceProvider,
    required DashboardExpenseAnalyticsProvider expenseProvider,
  }) {
    final tasksReady = !taskProvider.isLoading;
    final performanceReady = !performanceProvider.isLoading;
    final expenseReady = !expenseProvider.isLoading;
    return tasksReady && performanceReady && expenseReady;
  }
}

class _InsightCandidate {
  final double score;
  final List<String> headlines;
  final List<String> details;

  const _InsightCandidate({
    required this.score,
    required this.headlines,
    required this.details,
  });
}

class _InsightResult {
  final Color color;
  final String statusLabel;
  final String headline;
  final String message;
  final List<String> highlights;

  const _InsightResult({
    required this.color,
    required this.statusLabel,
    required this.headline,
    required this.message,
    required this.highlights,
  });
}
