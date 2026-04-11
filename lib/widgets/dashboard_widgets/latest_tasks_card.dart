import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/task_model.dart';
import 'package:trackerapp/providers/task_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/view/tasks/all_tasks_screen.dart';
import 'package:trackerapp/widgets/dashboard_widgets/dashboard_scale.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class LatestTasksCard extends StatefulWidget {
  const LatestTasksCard({super.key});

  @override
  State<LatestTasksCard> createState() => _LatestTasksCardState();
}

class _LatestTasksCardState extends State<LatestTasksCard> {
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
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final latest = provider.latestFiveTasks;
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: _mobileH(context, phone: 1.15, compact: 1.0),
            horizontal: _mobileW(context, phone: 3.5, compact: 3.0),
          ),
          margin: EdgeInsets.symmetric(
            horizontal: _mobileW(context, phone: 5.0, compact: 4.0),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? <Color>[
                      cardColor.withValues(alpha: .98),
                      cardColor.withValues(alpha: .92),
                    ]
                  : <Color>[
                      Colors.white,
                      const Color(0xFFF3F9FF),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  const Color(0xFF0EA5E9).withValues(alpha: isDark ? .26 : .16),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.55)
                    : const Color(0xFF0284C7).withValues(alpha: 0.12),
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
                    width: _mobileW(context, phone: 5.8, compact: 6.6),
                    height: _mobileW(context, phone: 5.8, compact: 6.6),
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
                      size: _mobileSp(context, phone: 15.0),
                    ),
                  ),
                  horizontalSpace(width: 2.w),
                  Expanded(
                    child: Text(
                      context.l10n.tasksAnalytics,
                      style: AppStyles.semiboldTextStyle(context).copyWith(
                        fontSize: _mobileSp(context, phone: 12.8),
                        fontWeight: FontWeight.w900,
                        color: onSurface.withValues(alpha: .92),
                      ),
                    ),
                  ),
                  if (provider.isLoading) ...[
                    SizedBox(
                      height: 2.2.h,
                      width: 2.2.h,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                    horizontalSpace(width: 1.w),
                  ],
                  IconButton(
                    onPressed: () =>
                        _shareTaskAnalytics(context, provider.tasks),
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
              verticalSpace(height: 1.3.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _mobileW(context, phone: 2.2, compact: 1.9),
                  vertical: _mobileH(context, phone: 1.0, compact: .9),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: onSurface.withValues(alpha: 0.10)),
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
                child: _buildBody(context, provider, latest),
              ),
              verticalSpace(height: .7.h),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllTasksScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    foregroundColor: Colors.white,
                    elevation: .8,
                    shadowColor: const Color(0xFF0284C7).withValues(alpha: .35),
                    padding: EdgeInsets.symmetric(
                      horizontal: _mobileW(context, phone: 2.8, compact: 2.5),
                      vertical: _mobileH(context, phone: .5, compact: .45),
                    ),
                    minimumSize: Size(
                      _mobileW(context, phone: 22, compact: 24),
                      _mobileH(context, phone: 4.0, compact: 3.8, min: 36),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    size: _mobileSp(context, phone: 11.5),
                  ),
                  label: Text(
                    context.l10n.seeMore,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: _mobileSp(context, phone: 12.1),
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
    BuildContext context,
    TaskProvider provider,
    List<TaskItem> latest,
  ) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final allTasks = provider.tasks;
    if (provider.errorMessage != null && latest.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.errorMessage!,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: _mobileSp(context, phone: 12.1),
              color: Colors.red.shade400,
            ),
          ),
          verticalSpace(height: .8.h),
          TextButton(
            onPressed: () => provider.fetchTasks(force: true),
            child: Text(context.l10n.retry),
          ),
        ],
      );
    }

    if (latest.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: .8.h),
        child: Text(
          context.l10n.noTasksAvailable,
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: _mobileSp(context, phone: 12.8),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _analyticsSection(context, allTasks),
        Divider(
          height: 1.6.h,
          color: onSurface.withValues(alpha: 0.12),
        ),
        _SectionHeading(
          title: context.l10n.latestTasks,
          icon: Icons.history_rounded,
        ),
        verticalSpace(height: .8.h),
        _sectionPanel(
          context,
          child: Column(
            children: List.generate(latest.length, (index) {
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
          ),
        ),
      ],
    );
  }

  Widget _analyticsSection(BuildContext context, List<TaskItem> tasks) {
    int newCount = 0;
    int inProgressCount = 0;
    int completedCount = 0;
    int failedCount = 0;
    int newOver1Hour = 0;
    int newOver4Hours = 0;
    int newOver24Hours = 0;
    int inProgressOver10Days = 0;
    final Map<String, int> vehicleWorkload = <String, int>{};
    final now = DateTime.now();

    for (final task in tasks) {
      final status = task.statusName.trim().toLowerCase();
      final createdAt = task.createdAt;
      final vehicleName = task.vehicleName.trim();
      if (vehicleName.isNotEmpty && vehicleName != '-') {
        vehicleWorkload.update(vehicleName, (value) => value + 1,
            ifAbsent: () => 1);
      }
      if (status.contains('new')) {
        newCount += 1;
        if (createdAt != null) {
          final age = now.difference(createdAt);
          if (age >= const Duration(hours: 1)) newOver1Hour += 1;
          if (age >= const Duration(hours: 4)) newOver4Hours += 1;
          if (age >= const Duration(hours: 24)) newOver24Hours += 1;
        }
      } else if (status.contains('progress')) {
        inProgressCount += 1;
        if (createdAt != null &&
            now.difference(createdAt) >= const Duration(days: 10)) {
          inProgressOver10Days += 1;
        }
      } else if (status.contains('complete')) {
        completedCount += 1;
      } else if (status.contains('failed') || task.status == 3) {
        failedCount += 1;
      }
    }

    final total = tasks.length;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;
    final isCompactPhone = MediaQuery.sizeOf(context).width <= 360;
    final newColor = const Color(0xFFEAB308);
    final progressColor = const Color(0xFF16A34A);
    final completedColor = const Color(0xFF2563EB);
    final failedColor = const Color(0xFFDC2626);
    final completionRate = total == 0 ? 0.0 : (completedCount / total);
    final failureRate = total == 0 ? 0.0 : (failedCount / total);
    final topVehicles = vehicleWorkload.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    Widget legend({
      required Color color,
      required String label,
      required int count,
    }) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _mobileW(context, phone: 2.2, compact: 2.6),
            height: _mobileW(context, phone: 2.2, compact: 2.6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          horizontalSpace(width: 1.5.w),
          Text(
            '$label: $count',
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: _mobileSp(context, phone: 12.2),
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
            gradient: LinearGradient(
              colors: <Color>[
                color.withValues(alpha: .18),
                color.withValues(alpha: .09),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: .22)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: .12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: _mobileSp(context, phone: 11.9),
                  fontWeight: FontWeight.w700,
                  color: onSurface.withValues(alpha: .72),
                ),
              ),
              verticalSpace(height: .35.h),
              Text(
                value,
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  fontSize: _mobileSp(context, phone: 14.1),
                  color: color,
                ),
              ),
              if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                verticalSpace(height: .2.h),
                Text(
                  subtitle,
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: _mobileSp(context, phone: 10.8),
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

    Widget agingTile({
      required String label,
      required String value,
      required Color color,
    }) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: .9.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                color.withValues(alpha: .16),
                color.withValues(alpha: .08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: .16)),
          ),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: _mobileSp(context, phone: 11.0),
                  fontWeight: FontWeight.w700,
                  color: onSurface.withValues(alpha: .7),
                ),
              ),
              verticalSpace(height: .25.h),
              Text(
                value,
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  fontSize: _mobileSp(context, phone: 13.2),
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: context.l10n.taskFunnel,
          icon: Icons.filter_alt_rounded,
        ),
        verticalSpace(height: .8.h),
        _sectionPanel(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                              flex: newCount,
                              child: Container(color: newColor),
                            ),
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
                  legend(
                      color: newColor,
                      label: context.l10n.taskNew,
                      count: newCount),
                  legend(
                    color: progressColor,
                    label: context.l10n.taskInProgress,
                    count: inProgressCount,
                  ),
                  legend(
                    color: completedColor,
                    label: context.l10n.taskCompleted,
                    count: completedCount,
                  ),
                  legend(
                    color: failedColor,
                    label: context.l10n.taskFailed,
                    count: failedCount,
                  ),
                ],
              ),
              verticalSpace(height: 1.2.h),
              if (isCompactPhone) ...[
                metricCard(
                  label: context.l10n.completionRate,
                  value: '${(completionRate * 100).toStringAsFixed(1)}%',
                  subtitle:
                      context.l10n.tasksCountSummary(completedCount, total),
                  color: completedColor,
                ),
                verticalSpace(height: .7.h),
                metricCard(
                  label: context.l10n.failureRate,
                  value: '${(failureRate * 100).toStringAsFixed(1)}%',
                  subtitle: context.l10n.tasksCountSummary(failedCount, total),
                  color: failedColor,
                ),
              ] else
                Row(
                  children: [
                    metricCard(
                      label: context.l10n.completionRate,
                      value: '${(completionRate * 100).toStringAsFixed(1)}%',
                      subtitle:
                          context.l10n.tasksCountSummary(completedCount, total),
                      color: completedColor,
                    ),
                    horizontalSpace(width: 2.4.w),
                    metricCard(
                      label: context.l10n.failureRate,
                      value: '${(failureRate * 100).toStringAsFixed(1)}%',
                      subtitle:
                          context.l10n.tasksCountSummary(failedCount, total),
                      color: failedColor,
                    ),
                  ],
                ),
            ],
          ),
        ),
        verticalSpace(height: 1.3.h),
        _SectionHeading(
          title: context.l10n.unstartedTaskAging,
          icon: Icons.schedule_rounded,
        ),
        verticalSpace(height: .8.h),
        _sectionPanel(
          context,
          child: Column(
            children: [
              if (isCompactPhone) ...[
                Row(
                  children: [
                    agingTile(
                      label: '> 1 hour',
                      value: '$newOver1Hour',
                      color: const Color(0xFFF59E0B),
                    ),
                    horizontalSpace(width: 2.w),
                    agingTile(
                      label: '> 4 hours',
                      value: '$newOver4Hours',
                      color: const Color(0xFFEA580C),
                    ),
                  ],
                ),
                verticalSpace(height: .6.h),
                Row(
                  children: [
                    agingTile(
                      label: '> 24 hours',
                      value: '$newOver24Hours',
                      color: const Color(0xFFDC2626),
                    ),
                    horizontalSpace(width: 2.w),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ] else
                Row(
                  children: [
                    agingTile(
                      label: '> 1 hour',
                      value: '$newOver1Hour',
                      color: const Color(0xFFF59E0B),
                    ),
                    horizontalSpace(width: 2.w),
                    agingTile(
                      label: '> 4 hours',
                      value: '$newOver4Hours',
                      color: const Color(0xFFEA580C),
                    ),
                    horizontalSpace(width: 2.w),
                    agingTile(
                      label: '> 24 hours',
                      value: '$newOver24Hours',
                      color: const Color(0xFFDC2626),
                    ),
                  ],
                ),
            ],
          ),
        ),
        verticalSpace(height: 1.3.h),
        _SectionHeading(
          title: context.l10n.inProgressAging,
          icon: Icons.timelapse_rounded,
        ),
        verticalSpace(height: .8.h),
        _sectionPanel(
          context,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF232647) : const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF6366F1)
                    .withValues(alpha: isDark ? .38 : .18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 2.6.w,
                  height: 2.6.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F46E5),
                    shape: BoxShape.circle,
                  ),
                ),
                horizontalSpace(width: 2.4.w),
                Expanded(
                  child: Text(
                    context.l10n.tasksNotCompletedWithin10Days,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: _mobileSp(context, phone: 12.0),
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white.withValues(alpha: .88)
                          : const Color(0xFF312E81),
                    ),
                  ),
                ),
                Text(
                  '$inProgressOver10Days',
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: _mobileSp(context, phone: 14.3),
                    color: isDark
                        ? Colors.white.withValues(alpha: .92)
                        : const Color(0xFF312E81),
                  ),
                ),
              ],
            ),
          ),
        ),
        verticalSpace(height: 1.3.h),
        _SectionHeading(
          title: context.l10n.vehicleWorkloadDistribution,
          icon: Icons.bar_chart_rounded,
        ),
        verticalSpace(height: .8.h),
        _sectionPanel(
          context,
          child: topVehicles.isEmpty
              ? Text(
                  context.l10n.noVehicleWorkloadData,
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: _mobileSp(context, phone: 11.2),
                    color: onSurface.withValues(alpha: .62),
                  ),
                )
              : Column(
                  children: topVehicles.take(5).map((entry) {
                    final maxValue = topVehicles.first.value == 0
                        ? 1
                        : topVehicles.first.value;
                    final widthFactor = entry.value / maxValue;
                    return Padding(
                      padding: EdgeInsets.only(bottom: .85.h),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 25.w,
                            child: Text(
                              entry.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppStyles.regularTextStyle(context).copyWith(
                                fontSize: _mobileSp(context, phone: 11.6),
                                fontWeight: FontWeight.w700,
                                color: onSurface.withValues(alpha: .76),
                              ),
                            ),
                          ),
                          horizontalSpace(width: 2.2.w),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: widthFactor.clamp(0.0, 1.0),
                                minHeight: 1.2.h,
                                backgroundColor:
                                    onSurface.withValues(alpha: .08),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF0284C7),
                                ),
                              ),
                            ),
                          ),
                          horizontalSpace(width: 2.2.w),
                          Text(
                            '${entry.value}',
                            style:
                                AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: _mobileSp(context, phone: 12.0),
                              color: const Color(0xFF075985),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(growable: false),
                ),
        ),
      ],
    );
  }

  Widget _taskRow(BuildContext context, TaskItem task) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final iconScale = dashboardIconScale(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: _mobileH(context, phone: 3.3, compact: 3.1, min: 32),
          width: _mobileH(context, phone: 3.3, compact: 3.1, min: 32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[
                Color(0xFF22D3EE),
                Color(0xFF0284C7),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: .25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.assignment_turned_in_outlined,
            color: Colors.white,
            size: _mobileSp(context, phone: (16.5 * iconScale)),
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
                  fontSize: _mobileSp(context, phone: 13.0),
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
              verticalSpace(height: .1.h),
              Text(
                '${task.vehicleName} • ${task.statusName.trim().isEmpty ? context.l10n.vehicleStatusUnknown : task.statusName.trim()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: _mobileSp(context, phone: 11.9),
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

  Future<void> _shareTaskAnalytics(
    BuildContext context,
    List<TaskItem> tasks,
  ) async {
    int newCount = 0;
    int inProgressCount = 0;
    int completedCount = 0;
    int failedCount = 0;
    final Map<String, int> vehicleWorkload = <String, int>{};

    for (final task in tasks) {
      final status = task.statusName.trim().toLowerCase();
      final vehicleName = task.vehicleName.trim();
      if (vehicleName.isNotEmpty && vehicleName != '-') {
        vehicleWorkload.update(vehicleName, (value) => value + 1,
            ifAbsent: () => 1);
      }
      if (status.contains('new')) {
        newCount += 1;
      } else if (status.contains('progress')) {
        inProgressCount += 1;
      } else if (status.contains('complete')) {
        completedCount += 1;
      } else if (status.contains('failed') || task.status == 3) {
        failedCount += 1;
      }
    }

    final topVehicles = vehicleWorkload.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = tasks.length;
    final completionRate = total == 0 ? 0.0 : (completedCount / total) * 100;
    final failureRate = total == 0 ? 0.0 : (failedCount / total) * 100;

    final buffer = StringBuffer();
    buffer.writeln('Task Analytics');
    buffer.writeln('Total Tasks: $total');
    buffer.writeln('New: $newCount');
    buffer.writeln('In Progress: $inProgressCount');
    buffer.writeln('Completed: $completedCount');
    buffer.writeln('Failed: $failedCount');
    buffer.writeln('Completion Rate: ${completionRate.toStringAsFixed(1)}%');
    buffer.writeln('Failure Rate: ${failureRate.toStringAsFixed(1)}%');
    if (topVehicles.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Top Vehicles by Task Count');
      for (final entry in topVehicles.take(5)) {
        buffer.writeln('- ${entry.key}: ${entry.value}');
      }
    }

    await SharePlus.instance.share(
      ShareParams(text: buffer.toString()),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeading({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Container(
          width: _mobileW(context, phone: 6.0, compact: 6.8),
          height: _mobileW(context, phone: 6.0, compact: 6.8),
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
            color: Colors.white,
            size: _mobileSp(context, phone: 10.8),
          ),
        ),
        horizontalSpace(width: 2.2.w),
        Expanded(
          child: Text(
            title,
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: _mobileSp(context, phone: 12.8),
              fontWeight: FontWeight.w900,
              color: onSurface.withValues(alpha: .92),
              letterSpacing: .2,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _sectionPanel(BuildContext context, {required Widget child}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: _mobileW(context, phone: 2.2, compact: 1.9),
      vertical: _mobileH(context, phone: .95, compact: .85),
    ),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? <Color>[
                Colors.white.withValues(alpha: .03),
                Colors.white.withValues(alpha: .01),
              ]
            : <Color>[
                Colors.white.withValues(alpha: .96),
                const Color(0xFFF8FBFF),
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: onSurface.withValues(alpha: .09)),
    ),
    child: child,
  );
}

double _mobileSp(
  BuildContext context, {
  required double phone,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= 360) return (phone * 1.08).sp;
  if (width <= 393) return (phone * 1.10).sp;
  if (width <= 430) return (phone * 1.06).sp;
  return (phone * 1.03).sp;
}

double _mobileW(
  BuildContext context, {
  required double phone,
  double? compact,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= 360 && compact != null) return compact.w;
  return phone.w;
}

double _mobileH(
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
