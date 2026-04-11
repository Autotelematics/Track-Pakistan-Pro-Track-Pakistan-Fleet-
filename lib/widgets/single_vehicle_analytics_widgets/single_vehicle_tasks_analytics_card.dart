import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/task_model.dart';
import 'package:trackerapp/providers/task_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/view/tasks/all_tasks_screen.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class SingleVehicleTasksAnalyticsCard extends StatefulWidget {
  final int deviceId;
  final String vehicleName;

  const SingleVehicleTasksAnalyticsCard({
    super.key,
    required this.deviceId,
    required this.vehicleName,
  });

  @override
  State<SingleVehicleTasksAnalyticsCard> createState() =>
      _SingleVehicleTasksAnalyticsCardState();
}

class _SingleVehicleTasksAnalyticsCardState
    extends State<SingleVehicleTasksAnalyticsCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TaskProvider>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final vehicleTasks = provider.tasks
            .where((task) => task.device?.id == widget.deviceId)
            .toList(growable: false);
        final latest = List<TaskItem>.from(vehicleTasks)
          ..sort((a, b) {
            final aDate = a.createdAt;
            final bDate = b.createdAt;
            if (aDate == null && bDate == null) return b.id.compareTo(a.id);
            if (aDate == null) return 1;
            if (bDate == null) return -1;
            return bDate.compareTo(aDate);
          });

        return Container(
          padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 3.5.w),
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
                      Icons.analytics_rounded,
                      color: Colors.white,
                      size: _svtSp(context, phone: 15.0),
                    ),
                  ),
                  horizontalSpace(width: 2.w),
                  Expanded(
                    child: Text(
                      l10n.tasksAnalytics,
                      style: AppStyles.semiboldTextStyle(context).copyWith(
                        fontSize: _svtSp(context, phone: 12.8),
                        fontWeight: FontWeight.w900,
                        color: onSurface.withValues(alpha: .92),
                      ),
                    ),
                  ),
                  if (provider.isLoading)
                    SizedBox(
                      height: 2.2.h,
                      width: 2.2.h,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              verticalSpace(height: .35.h),
              // Text(
              //   widget.vehicleName,
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              //   style: AppStyles.regularTextStyle(context).copyWith(
              //     fontSize: 12.3.sp,
              //     fontWeight: FontWeight.w700,
              //     color: onSurface.withValues(alpha: .76),
              //   ),
              // ),
              verticalSpace(height: 1.2.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 1.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: onSurface.withValues(alpha: 0.08)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.02),
                            Colors.white.withValues(alpha: 0.01),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.95),
                            Colors.grey.shade50,
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _buildBody(
                  context,
                  provider: provider,
                  vehicleTasks: vehicleTasks,
                  latest: latest.take(5).toList(growable: false),
                ),
              ),
              verticalSpace(height: .7.h),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllTasksScreen(
                          initialDeviceId: widget.deviceId,
                          initialVehicleName: widget.vehicleName,
                          title: l10n.vehicleTasksTitle(widget.vehicleName),
                          lockVehicleFilter: true,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    foregroundColor: Colors.white,
                    elevation: .8,
                    shadowColor: const Color(0xFF0284C7).withValues(alpha: .35),
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.2.w,
                      vertical: .45.h,
                    ),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    size: _svtSp(context, phone: 11.2),
                  ),
                  label: Text(
                    l10n.seeMore,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: _svtSp(context, phone: 11.8),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required TaskProvider provider,
    required List<TaskItem> vehicleTasks,
    required List<TaskItem> latest,
  }) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (provider.errorMessage != null && vehicleTasks.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.errorMessage!,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: _svtSp(context, phone: 12.4),
              color: Colors.red.shade400,
            ),
          ),
          verticalSpace(height: .8.h),
          TextButton(
            onPressed: () => provider.fetchTasks(force: true),
            child: Text(l10n.retry),
          ),
        ],
      );
    }

    if (vehicleTasks.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: .8.h),
        child: Text(
          l10n.noTasksAvailable,
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: _svtSp(context, phone: 13.0),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _analyticsSection(context, vehicleTasks),
        Divider(
          height: 1.6.h,
          color: onSurface.withValues(alpha: 0.12),
        ),
        Text(
          l10n.latestTasks,
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: _svtSp(context, phone: 12.4),
            fontWeight: FontWeight.w800,
            color: onSurface.withValues(alpha: .88),
          ),
        ),
        verticalSpace(height: 1.5.h),
        ...List.generate(latest.length, (index) {
          final task = latest[index];
          return Column(
            children: [
              _taskRow(context, task),
              if (index != latest.length - 1)
                Divider(
                  height: 1.6.h,
                  color: onSurface.withValues(alpha: 0.12),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _analyticsSection(BuildContext context, List<TaskItem> tasks) {
    final l10n = context.l10n;
    int newCount = 0;
    int inProgressCount = 0;
    int completedCount = 0;
    int failedCount = 0;
    int directJobs = 0;
    int multiStopJobs = 0;
    final List<Duration> completionDurations = <Duration>[];
    final List<Duration> pickupResponseDurations = <Duration>[];
    final List<Duration> pickupDwellDurations = <Duration>[];
    final List<Duration> stopDwellDurations = <Duration>[];
    final List<Duration> deliveryDwellDurations = <Duration>[];
    final List<TaskItem> failedTasks = <TaskItem>[];

    for (final task in tasks) {
      final status = task.statusName.trim().toLowerCase();
      if (task.hasStops) {
        multiStopJobs += 1;
      } else {
        directJobs += 1;
      }
      if (status.contains('new')) {
        newCount += 1;
      } else if (status.contains('progress')) {
        inProgressCount += 1;
      } else if (status.contains('complete')) {
        completedCount += 1;
      } else if (status.contains('failed') || task.status == 3) {
        failedCount += 1;
        failedTasks.add(task);
      }

      final createdAt = task.createdAt;
      final pickupReachedAt = _parseTaskDate(task.pickup?.timeFrom);
      final pickupLeftAt = _parseTaskDate(task.pickup?.timeTo);
      final deliveryLeftAt = _parseTaskDate(task.delivery?.timeTo);
      final deliveryReachedAt = _parseTaskDate(task.delivery?.timeFrom);

      if (createdAt != null && pickupReachedAt != null) {
        final duration = pickupReachedAt.difference(createdAt);
        if (!duration.isNegative) {
          pickupResponseDurations.add(duration);
        }
      }

      if (pickupReachedAt != null && pickupLeftAt != null) {
        final duration = pickupLeftAt.difference(pickupReachedAt);
        if (!duration.isNegative) {
          pickupDwellDurations.add(duration);
        }
      }

      if (deliveryReachedAt != null && deliveryLeftAt != null) {
        final duration = deliveryLeftAt.difference(deliveryReachedAt);
        if (!duration.isNegative) {
          deliveryDwellDurations.add(duration);
        }
      }

      if (deliveryLeftAt != null) {
        final startAt = createdAt ?? pickupReachedAt;
        if (startAt != null) {
          final duration = deliveryLeftAt.difference(startAt);
          if (!duration.isNegative) {
            completionDurations.add(duration);
          }
        }
      }

      for (final waypoint in task.waypoints) {
        final reachedAt = _parseTaskDate(waypoint.reachedAt);
        final leftAt = _parseTaskDate(waypoint.leftAt);
        if (reachedAt != null && leftAt != null) {
          final duration = leftAt.difference(reachedAt);
          if (!duration.isNegative) {
            stopDwellDurations.add(duration);
          }
        }
      }
    }

    final total = tasks.length;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final newColor = const Color(0xFFEAB308);
    final progressColor = const Color(0xFF16A34A);
    final completedColor = const Color(0xFF2563EB);
    final failedColor = const Color(0xFFDC2626);
    final successRate = total == 0 ? 0.0 : completedCount / total;
    final recentFailedTasks = List<TaskItem>.from(failedTasks)
      ..sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;
        if (aDate == null && bDate == null) return b.id.compareTo(a.id);
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

    Widget legend({
      required Color color,
      required String label,
      required int count,
    }) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2.2.w,
            height: 2.2.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          horizontalSpace(width: 1.5.w),
          Text(
            '$label: $count',
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: _svtSp(context, phone: 12.2),
              fontWeight: FontWeight.w700,
              color: onSurface.withValues(alpha: .86),
            ),
          ),
        ],
      );
    }

    Widget metricCard({
      required String label,
      required String value,
      required Color color,
      String? subtitle,
    }) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 1.1.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: .20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: _svtSp(context, phone: 10.9),
                  fontWeight: FontWeight.w700,
                  color: onSurface.withValues(alpha: .72),
                ),
              ),
              verticalSpace(height: .35.h),
              Text(
                value,
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  fontSize: _svtSp(context, phone: 14.4),
                  color: color,
                ),
              ),
              if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                verticalSpace(height: .2.h),
                Text(
                  subtitle,
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: _svtSp(context, phone: 10.0),
                    fontWeight: FontWeight.w600,
                    color: onSurface.withValues(alpha: .58),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.taskFunnel,
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: _svtSp(context, phone: 12.4),
            fontWeight: FontWeight.w800,
            color: onSurface.withValues(alpha: .88),
          ),
        ),
        verticalSpace(height: .75.h),
        Container(
          height: 1.6.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: onSurface.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(999),
          ),
          clipBehavior: Clip.antiAlias,
          child: total == 0
              ? const SizedBox.shrink()
              : Row(
                  children: [
                    if (newCount > 0)
                      Expanded(
                          flex: newCount, child: Container(color: newColor)),
                    if (inProgressCount > 0)
                      Expanded(
                        flex: inProgressCount,
                        child: Container(color: progressColor),
                      ),
                    if (completedCount > 0)
                      Expanded(
                        flex: completedCount,
                        child: Container(color: completedColor),
                      ),
                    if (failedCount > 0)
                      Expanded(
                        flex: failedCount,
                        child: Container(color: failedColor),
                      ),
                  ],
                ),
        ),
        verticalSpace(height: .7.h),
        Wrap(
          spacing: 3.w,
          runSpacing: .5.h,
          children: [
            legend(color: newColor, label: l10n.taskNew, count: newCount),
            legend(
              color: progressColor,
              label: l10n.taskInProgress,
              count: inProgressCount,
            ),
            legend(
              color: completedColor,
              label: l10n.taskCompleted,
              count: completedCount,
            ),
            legend(
              color: failedColor,
              label: l10n.taskFailed,
              count: failedCount,
            ),
          ],
        ),
        verticalSpace(height: 1.2.h),
        Row(
          children: [
            metricCard(
              label: l10n.successRate,
              value: '${(successRate * 100).toStringAsFixed(1)}%',
              subtitle: l10n.tasksCountSummary(completedCount, total),
              color: completedColor,
            ),
            horizontalSpace(width: 2.4.w),
            metricCard(
              label: l10n.avgCompletion,
              value: _formatAverageDuration(completionDurations),
              subtitle: l10n.createdToDeliveryLeft,
              color: const Color(0xFF7C3AED),
            ),
          ],
        ),
        verticalSpace(height: 1.h),
        Row(
          children: [
            metricCard(
              label: l10n.pickupResponse,
              value: _formatAverageDuration(pickupResponseDurations),
              subtitle: l10n.createdToPickupReached,
              color: const Color(0xFF0891B2),
            ),
            horizontalSpace(width: 2.4.w),
            metricCard(
              label: l10n.pickupDwell,
              value: _formatAverageDuration(pickupDwellDurations),
              subtitle: l10n.pickupLeftMinusReached,
              color: const Color(0xFFF59E0B),
            ),
          ],
        ),
        verticalSpace(height: 1.h),
        Row(
          children: [
            metricCard(
              label: l10n.stopDwell,
              value: _formatAverageDuration(stopDwellDurations),
              subtitle: l10n.averageAcrossAllStops,
              color: const Color(0xFFEA580C),
            ),
            horizontalSpace(width: 2.4.w),
            metricCard(
              label: l10n.deliveryDwell,
              value: _formatAverageDuration(deliveryDwellDurations),
              subtitle: l10n.deliveryLeftMinusReached,
              color: const Color(0xFF2563EB),
            ),
          ],
        ),
        verticalSpace(height: 1.2.h),
        Text(
          l10n.stopComplexityTrend,
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: _svtSp(context, phone: 12.2),
            fontWeight: FontWeight.w800,
            color: onSurface.withValues(alpha: .84),
          ),
        ),
        verticalSpace(height: .7.h),
        Row(
          children: [
            metricCard(
              label: l10n.directJobs,
              value: '$directJobs',
              subtitle: l10n.noStops,
              color: const Color(0xFF0F766E),
            ),
            horizontalSpace(width: 2.4.w),
            metricCard(
              label: l10n.multiStopJobs,
              value: '$multiStopJobs',
              subtitle: l10n.oneOrMoreStops,
              color: const Color(0xFF9333EA),
            ),
          ],
        ),
        verticalSpace(height: 1.2.h),
        Text(
          l10n.recentFailedTasks,
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: _svtSp(context, phone: 12.2),
            fontWeight: FontWeight.w800,
            color: onSurface.withValues(alpha: .84),
          ),
        ),
        verticalSpace(height: .7.h),
        if (recentFailedTasks.isEmpty)
          Text(
            l10n.noRecentFailedTasksForVehicle,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: _svtSp(context, phone: 11.5),
              color: onSurface.withValues(alpha: .62),
            ),
          )
        else
          ...recentFailedTasks.take(5).map(
                (task) => Padding(
                  padding: EdgeInsets.only(bottom: .8.h),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.8.w, vertical: .9.h),
                    decoration: BoxDecoration(
                      color: failedColor.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: failedColor.withValues(alpha: .16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 2.2.w,
                          height: 2.2.w,
                          decoration: BoxDecoration(
                            color: failedColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        horizontalSpace(width: 2.2.w),
                        Expanded(
                          child: Text(
                            task.title.trim().isEmpty
                                ? l10n.taskNumber(task.id)
                                : task.title.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: _svtSp(context, phone: 11.6),
                              fontWeight: FontWeight.w700,
                              color: onSurface.withValues(alpha: .82),
                            ),
                          ),
                        ),
                        horizontalSpace(width: 1.6.w),
                        Text(
                          _formatTaskDate(task.createdAt),
                          style: AppStyles.regularTextStyle(context).copyWith(
                            fontSize: _svtSp(context, phone: 10.4),
                            fontWeight: FontWeight.w600,
                            color: onSurface.withValues(alpha: .58),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _taskRow(BuildContext context, TaskItem task) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 3.3.h,
          width: 3.3.h,
          decoration: BoxDecoration(
            color: const Color(0xFF0284C7).withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.assignment_turned_in_outlined,
            color: const Color(0xFF0284C7),
            size: _svtSp(context, phone: 17.0),
          ),
        ),
        horizontalSpace(width: 2.2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title.trim().isEmpty ? '-' : task.title.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: _svtSp(context, phone: 13.4),
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
              verticalSpace(height: .1.h),
              Text(
                task.statusName.trim().isEmpty
                    ? l10n.vehicleStatusUnknown
                    : _localizedTaskStatus(context, task.statusName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: _svtSp(context, phone: 11.6),
                  color: onSurface.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _localizedTaskStatus(BuildContext context, String? statusName) {
  final l10n = context.l10n;
  final rawStatus = statusName?.trim() ?? '';
  if (rawStatus.isEmpty) return l10n.vehicleStatusUnknown;

  switch (rawStatus.toLowerCase()) {
    case 'new':
      return l10n.taskNew;
    case 'in progress':
    case 'in_progress':
      return l10n.taskInProgress;
    case 'completed':
    case 'complete':
      return l10n.taskCompleted;
    case 'failed':
      return l10n.taskFailed;
    default:
      return rawStatus;
  }
}

DateTime? _parseTaskDate(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return null;
  return DateTime.tryParse(raw) ??
      DateTime.tryParse(raw.replaceFirst(' ', 'T'));
}

String _formatAverageDuration(List<Duration> durations) {
  if (durations.isEmpty) return '-';
  final totalMs = durations.fold<int>(
    0,
    (sum, item) => sum + item.inMilliseconds,
  );
  final avg = Duration(milliseconds: (totalMs / durations.length).round());
  return _formatDuration(avg);
}

String _formatDuration(Duration duration) {
  if (duration.inMinutes < 60) {
    return '${duration.inMinutes}m';
  }
  if (duration.inHours < 24) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
  }
  final days = duration.inDays;
  final hours = duration.inHours.remainder(24);
  return hours == 0 ? '${days}d' : '${days}d ${hours}h';
}

String _formatTaskDate(DateTime? value) {
  if (value == null) return '-';
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

double _svtSp(
  BuildContext context, {
  required double phone,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= 360) return (phone * 1.08).sp;
  if (width <= 393) return (phone * 1.10).sp;
  if (width <= 430) return (phone * 1.06).sp;
  return (phone * 1.03).sp;
}
