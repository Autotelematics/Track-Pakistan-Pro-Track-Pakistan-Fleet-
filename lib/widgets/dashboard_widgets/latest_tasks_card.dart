import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/task_model.dart';
import 'package:trackerapp/providers/task_provider.dart';
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
          padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 3.5.w),
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.55)
                    : Colors.black.withValues(alpha: 0.12),
                blurRadius: isDark ? 14 : 10,
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
                      'Tasks Analytics',
                      style: AppStyles.semiboldTextStyle(context)
                          .copyWith(fontSize: 15.sp),
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
              verticalSpace(height: 1.3.h),
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
                child: _buildBody(context, provider, latest),
              ),
              verticalSpace(height: .7.h),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllTasksScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.2.w, vertical: .2.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'See more',
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0284C7),
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
              fontSize: 12.4.sp,
              color: Colors.red.shade400,
            ),
          ),
          verticalSpace(height: .8.h),
          TextButton(
            onPressed: () => provider.fetchTasks(force: true),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (latest.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: .8.h),
        child: Text(
          'No tasks available',
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: 13.sp,
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
        Text(
          'Latest Tasks',
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: 12.4.sp,
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
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
              fontSize: 12.2.sp,
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
            border: Border.all(color: color.withValues(alpha: .22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 11.4.sp,
                  fontWeight: FontWeight.w700,
                  color: onSurface.withValues(alpha: .72),
                ),
              ),
              verticalSpace(height: .35.h),
              Text(
                value,
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  fontSize: 15.sp,
                  color: color,
                ),
              ),
              if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                verticalSpace(height: .2.h),
                Text(
                  subtitle,
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: 10.4.sp,
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
            color: color.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: .16)),
          ),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 10.8.sp,
                  fontWeight: FontWeight.w700,
                  color: onSurface.withValues(alpha: .7),
                ),
              ),
              verticalSpace(height: .25.h),
              Text(
                value,
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  fontSize: 14.sp,
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
        Text(
          'Task Funnel',
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: 12.6.sp,
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
            legend(color: newColor, label: 'New', count: newCount),
            legend(
              color: progressColor,
              label: 'In Progress',
              count: inProgressCount,
            ),
            legend(
              color: completedColor,
              label: 'Completed',
              count: completedCount,
            ),
            legend(
              color: failedColor,
              label: 'Failed',
              count: failedCount,
            ),
          ],
        ),
        verticalSpace(height: 1.2.h),
        Row(
          children: [
            metricCard(
              label: 'Completion Rate',
              value: '${(completionRate * 100).toStringAsFixed(1)}%',
              subtitle: '$completedCount of $total tasks',
              color: completedColor,
            ),
            horizontalSpace(width: 2.4.w),
            metricCard(
              label: 'Failure Rate',
              value: '${(failureRate * 100).toStringAsFixed(1)}%',
              subtitle: '$failedCount of $total tasks',
              color: failedColor,
            ),
          ],
        ),
        verticalSpace(height: 1.3.h),
        Text(
          'Unstarted Task Aging',
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: 12.2.sp,
            fontWeight: FontWeight.w800,
            color: onSurface.withValues(alpha: .84),
          ),
        ),
        verticalSpace(height: .7.h),
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
        verticalSpace(height: 1.3.h),
        Text(
          'In Progress Aging',
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: 12.2.sp,
            fontWeight: FontWeight.w800,
            color: onSurface.withValues(alpha: .84),
          ),
        ),
        verticalSpace(height: .7.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF6366F1).withValues(alpha: .18),
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
                  'Tasks not completed within 10 days',
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: 11.7.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF312E81),
                  ),
                ),
              ),
              Text(
                '$inProgressOver10Days',
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  fontSize: 15.2.sp,
                  color: const Color(0xFF312E81),
                ),
              ),
            ],
          ),
        ),
        verticalSpace(height: 1.3.h),
        Text(
          'Vehicle Workload Distribution',
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: 12.2.sp,
            fontWeight: FontWeight.w800,
            color: onSurface.withValues(alpha: .84),
          ),
        ),
        verticalSpace(height: .7.h),
        if (topVehicles.isEmpty)
          Text(
            'No vehicle workload data available',
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 11.6.sp,
              color: onSurface.withValues(alpha: .62),
            ),
          )
        else
          ...topVehicles.take(5).map((entry) {
            final maxValue = topVehicles.first.value == 0 ? 1 : topVehicles.first.value;
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
                      style: AppStyles.regularTextStyle(context).copyWith(
                        fontSize: 11.2.sp,
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
                        backgroundColor: onSurface.withValues(alpha: .08),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ),
                  horizontalSpace(width: 2.2.w),
                  Text(
                    '${entry.value}',
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 11.6.sp,
                      color: const Color(0xFF075985),
                    ),
                  ),
                ],
              ),
            );
          }),
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
          height: 3.3.h,
          width: 3.3.h,
          decoration: BoxDecoration(
            color: const Color(0xFF0284C7).withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.assignment_turned_in_outlined,
            color: const Color(0xFF0284C7),
            size: (17 * iconScale).sp,
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
                  fontSize: 13.8.sp,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
              verticalSpace(height: .1.h),
              Text(
                '${task.vehicleName} • ${task.statusName.trim().isEmpty ? 'Unknown' : task.statusName.trim()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 12.6.sp,
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
