import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart';
import 'package:trackerapp/data/models/task_model.dart';
import 'package:trackerapp/providers/get_devices_status_provider.dart';
import 'package:trackerapp/providers/task_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_history_screen.dart';
import 'package:trackerapp/view/tasks/task_form_screen.dart';
import 'package:trackerapp/widgets/custom_button.dart';

class AllTasksScreen extends StatefulWidget {
  final int? initialDeviceId;
  final String? initialVehicleName;
  final String? title;
  final bool lockVehicleFilter;

  const AllTasksScreen({
    super.key,
    this.initialDeviceId,
    this.initialVehicleName,
    this.title,
    this.lockVehicleFilter = false,
  });

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchText = '';
  late String _selectedVehicle;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.initialVehicleName?.trim().isNotEmpty == true
        ? widget.initialVehicleName!.trim()
        : '';
    final initialVehicle = widget.initialVehicleName?.trim() ?? '';
    if (initialVehicle.isNotEmpty) {
      _selectedVehicle = initialVehicle;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TaskProvider>().fetchTasks(force: true);
      final vehicleProvider = context.read<VehicleMapProvider>();
      if (vehicleProvider.deviceListModel == null) {
        vehicleProvider.fetchVehicleList(context: context);
      }
    });
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TaskProvider>().loadMoreTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titleSize = _adaptiveSp(
      context,
      phone: 16.2,
      tablet: 13.0,
      desktop: 10.4,
    );
    final showAddTaskAction =
        widget.initialDeviceId != null && widget.lockVehicleFilter;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ?? l10n.allTasks,
          style: AppStyles.semiboldTextStyle(context).copyWith(
            fontSize: titleSize,
          ),
        ),
        actions: [
          if (showAddTaskAction)
            Padding(
              padding: EdgeInsets.only(
                  right: _adaptiveW(context, phone: 3, tablet: 2)),
              child: TextButton.icon(
                onPressed: () async {
                  final created = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskFormScreen(
                        fixedDeviceId: widget.initialDeviceId,
                        fixedVehicleName: widget.initialVehicleName,
                      ),
                    ),
                  );
                  if (created == true && context.mounted) {
                    context.read<TaskProvider>().fetchTasks(force: true);
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF166534),
                  backgroundColor: const Color(0xFFDCFCE7),
                  minimumSize: Size(
                    _adaptiveW(context, phone: 24, tablet: 17),
                    _adaptiveH(context, phone: 4.6, tablet: 4.1, min: 40),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: _adaptiveW(context, phone: 3.2, tablet: 2.3),
                    vertical: _adaptiveH(context, phone: .55, tablet: .5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: const BorderSide(
                      color: Color(0xFF86EFAC),
                    ),
                  ),
                ),
                icon: const Icon(Icons.add_task_rounded),
                label: Text(
                  l10n.addTask,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: _adaptiveSp(context, phone: 12.4, tablet: 9.9),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.tasks.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 7.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppStyles.regularTextStyle(context).copyWith(
                        fontSize:
                            _adaptiveSp(context, phone: 12.4, tablet: 10.0),
                      ),
                    ),
                    SizedBox(height: 1.2.h),
                    ElevatedButton(
                      onPressed: () => provider.fetchTasks(force: true),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          final List<TaskItem> tasks = List<TaskItem>.from(provider.tasks)
            ..sort((a, b) {
              final aDate = a.createdAt;
              final bDate = b.createdAt;
              if (aDate == null && bDate == null) return b.id.compareTo(a.id);
              if (aDate == null) return 1;
              if (bDate == null) return -1;
              return bDate.compareTo(aDate);
            });

          final vehicleNames = tasks
              .map((item) => item.vehicleName.trim())
              .where((name) => name.isNotEmpty && name != '-')
              .toSet()
              .toList()
            ..sort();
          final vehicleFilterItems = <String>[
            l10n.allVehicles,
            ...vehicleNames
          ];
          if (!vehicleFilterItems.contains(_selectedVehicle)) {
            _selectedVehicle = l10n.allVehicles;
          }

          final filtered = tasks.where((task) {
            final vehicle = task.vehicleName.trim();
            final title = task.title.trim();
            final q = _searchText.trim().toLowerCase();
            final byDevice = widget.initialDeviceId == null ||
                task.device?.id == widget.initialDeviceId;
            if (!byDevice) return false;
            final byVehicle = _selectedVehicle == l10n.allVehicles ||
                vehicle.toLowerCase() == _selectedVehicle.toLowerCase();
            if (!byVehicle) return false;
            if (q.isEmpty) return true;
            return title.toLowerCase().contains(q) ||
                vehicle.toLowerCase().contains(q);
          }).toList(growable: false);

          if (tasks.isEmpty) {
            return Center(
              child: Text(
                l10n.noTasksFound,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: _adaptiveSp(context, phone: 13.0, tablet: 10.4),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchTasks(force: true),
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                _adaptiveW(context, phone: 4, tablet: 2.8, desktop: 2.2),
                _adaptiveH(context, phone: 1.2, tablet: 1.0),
                _adaptiveW(context, phone: 4, tablet: 2.8, desktop: 2.2),
                _adaptiveH(context, phone: 2.0, tablet: 1.6),
              ),
              itemCount: filtered.length + 2,
              separatorBuilder: (_, __) => SizedBox(
                height: _adaptiveH(context, phone: 1.0, tablet: 0.75),
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildFilters(
                    context,
                    vehicleFilterItems: vehicleFilterItems,
                    resultCount: filtered.length,
                  );
                }
                if (index == filtered.length + 1) {
                  return _buildPaginationFooter(context, provider);
                }
                return _TaskCard(
                  task: filtered[index - 1],
                  fixedDeviceId: widget.initialDeviceId,
                  fixedVehicleName: widget.initialVehicleName,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(
    BuildContext context, {
    required List<String> vehicleFilterItems,
    required int resultCount,
  }) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filterLabelSize = _adaptiveSp(context, phone: 12.1, tablet: 9.8);
    final filterValueSize = _adaptiveSp(context, phone: 12.3, tablet: 9.9);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _adaptiveW(context, phone: 2.8, tablet: 2.1),
        vertical: _adaptiveH(context, phone: .9, tablet: .75),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? <Color>[
                  theme.cardColor.withValues(alpha: .98),
                  theme.cardColor.withValues(alpha: .92),
                ]
              : <Color>[
                  Colors.white,
                  const Color(0xFFF2F8FF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF0EA5E9).withValues(alpha: isDark ? .28 : .18),
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF0284C7).withValues(alpha: isDark ? .16 : .10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: InputDecoration(
              isDense: true,
              hintText: l10n.searchTasksByTitleOrVehicle,
              prefixIcon: const Icon(Icons.search_rounded),
              hintStyle: AppStyles.regularTextStyle(context).copyWith(
                fontSize: filterValueSize,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: _adaptiveW(context, phone: 2.4, tablet: 2.0),
                vertical: _adaptiveH(context, phone: 1.25, tablet: 1.0),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: .04)
                  : Colors.white.withValues(alpha: .92),
            ),
          ),
          SizedBox(height: .9.h),
          Row(
            children: [
              Expanded(
                child: widget.lockVehicleFilter
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              _adaptiveW(context, phone: 3.0, tablet: 2.1),
                          vertical:
                              _adaptiveH(context, phone: 1.35, tablet: 1.0),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: .12),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isDark
                              ? Colors.white.withValues(alpha: .04)
                              : Colors.white.withValues(alpha: .92),
                        ),
                        child: Text(
                          _selectedVehicle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.regularTextStyle(context).copyWith(
                            fontSize: filterValueSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        initialValue: _selectedVehicle,
                        isExpanded: true,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: l10n.vehicle,
                          labelStyle:
                              AppStyles.regularTextStyle(context).copyWith(
                            fontSize: filterLabelSize,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal:
                                _adaptiveW(context, phone: 2.4, tablet: 2.0),
                            vertical:
                                _adaptiveH(context, phone: 1.25, tablet: 1.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: vehicleFilterItems
                            .map(
                              (name) => DropdownMenuItem<String>(
                                value: name,
                                child: Text(
                                  name,
                                  style: AppStyles.regularTextStyle(context)
                                      .copyWith(
                                    fontSize: filterValueSize,
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedVehicle = value;
                          });
                        },
                      ),
              ),
              SizedBox(width: 2.4.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _adaptiveW(context, phone: 2.5, tablet: 1.9),
                  vertical: _adaptiveH(context, phone: .75, tablet: .62),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$resultCount',
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: _adaptiveSp(context, phone: 12.0, tablet: 9.6),
                    color: const Color(0xFF0369A1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter(BuildContext context, TaskProvider provider) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final loadedCount = provider.tasks.length;
    final totalCount = provider.totalTasks;

    if (provider.isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 1.4.h),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: .8.h),
      child: Column(
        children: [
          Text(
            totalCount > 0
                ? l10n.showingTasksCountOfTotal(loadedCount, totalCount)
                : l10n.showingTasksCount(loadedCount),
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: _adaptiveSp(context, phone: 11.6, tablet: 9.3),
              fontWeight: FontWeight.w700,
              color: onSurface.withValues(alpha: .66),
            ),
          ),
          if (provider.hasMoreTasks) ...[
            SizedBox(height: .8.h),
            OutlinedButton(
              onPressed: provider.loadMoreTasks,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(
                  _adaptiveW(context, phone: 28, tablet: 20),
                  _adaptiveH(context, phone: 4.5, tablet: 4.0, min: 40),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: _adaptiveW(context, phone: 5.2, tablet: 4.0),
                  vertical: _adaptiveH(context, phone: .8, tablet: .7),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                l10n.loadMore,
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  fontSize: _adaptiveSp(context, phone: 12.0, tablet: 9.6),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskItem task;
  final int? fixedDeviceId;
  final String? fixedVehicleName;

  const _TaskCard({
    required this.task,
    this.fixedDeviceId,
    this.fixedVehicleName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final titleSize = _adaptiveSp(context, phone: 14.2, tablet: 10.8);
    final statusBadgeSize = _adaptiveSp(context, phone: 12.2, tablet: 9.6);
    final actionButtonHeight =
        _adaptiveH(context, phone: 4.2, tablet: 3.7, min: 38);
    final actionLabelSize = _adaptiveSp(context, phone: 12.2, tablet: 9.5);
    final actionIconSize = _adaptiveSp(context, phone: 13.2, tablet: 10.2);
    final statusText = _localizedTaskStatus(context, task.statusName);
    final routePlaybackWindow = _resolveRoutePlaybackWindow(task);
    final statusTint = _statusTintColor(statusText);
    final steps = _buildTimelineSteps(context, task);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _adaptiveW(context, phone: 3.4, tablet: 2.6, desktop: 2.2),
        vertical: _adaptiveH(context, phone: 1.15, tablet: .95),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color.alphaBlend(
              statusTint.withValues(
                  alpha: theme.brightness == Brightness.dark ? .22 : .12),
              theme.cardColor,
            ),
            Color.alphaBlend(
              statusTint.withValues(
                  alpha: theme.brightness == Brightness.dark ? .10 : .05),
              theme.cardColor,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusTint.withValues(alpha: .38),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.34)
                : statusTint.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
              _adaptiveW(context, phone: 2.8, tablet: 2.1),
              _adaptiveH(context, phone: .95, tablet: .75),
              _adaptiveW(context, phone: 2.8, tablet: 2.1),
              _adaptiveH(context, phone: .9, tablet: .7),
            ),
            decoration: BoxDecoration(
              color: statusTint.withValues(
                alpha: theme.brightness == Brightness.dark ? .26 : .18,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusTint.withValues(alpha: .34)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title.trim().isEmpty ? '-' : task.title.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.semiboldTextStyle(context).copyWith(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.4.w,
                        vertical: .35.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: <Color>[
                            Color(0xFF0EA5E9),
                            Color(0xFF2563EB),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF2563EB).withValues(alpha: .25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        statusText,
                        style: AppStyles.regularTextStyle(context).copyWith(
                          fontSize: statusBadgeSize,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: .75.h),
                _TaskField(
                  label: l10n.vehicle,
                  value: task.vehicleName,
                  emphasize: true,
                ),
                SizedBox(height: .45.h),
                _TaskField(
                  label: l10n.status,
                  value: statusText,
                  emphasize: true,
                ),
                SizedBox(height: .45.h),
                _TaskField(
                  label: l10n.hasStops,
                  value: task.hasStops ? l10n.yes : l10n.no,
                  emphasize: true,
                ),
                SizedBox(height: .6.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 2.3.w,
                    runSpacing: .6.h,
                    children: [
                      _TaskActionButton(
                        height: actionButtonHeight,
                        minWidth: _adaptiveW(context, phone: 22, tablet: 16.5),
                        icon: Icons.assignment_return_rounded,
                        label: l10n.assign,
                        iconSize: actionIconSize,
                        labelSize: actionLabelSize,
                        onPressed: () => _handleAssign(context),
                        backgroundColor: const Color(0xFFDCFCE7),
                        foregroundColor: const Color(0xFF166534),
                        borderColor: const Color(0xFF86EFAC),
                        shadowColor: const Color(0xFF16A34A),
                      ),
                      _TaskActionButton(
                        height: actionButtonHeight,
                        minWidth: _adaptiveW(context, phone: 20, tablet: 15.8),
                        icon: Icons.edit_outlined,
                        label: l10n.edit,
                        iconSize: actionIconSize,
                        labelSize: actionLabelSize,
                        onPressed: () async {
                          await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskFormScreen(
                                initialTask: task,
                              ),
                            ),
                          );
                        },
                        backgroundColor: const Color(0xFFE0F2FE),
                        foregroundColor: const Color(0xFF075985),
                        borderColor: const Color(0xFF7DD3FC),
                        shadowColor: const Color(0xFF0EA5E9),
                      ),
                      if (routePlaybackWindow != null)
                        _TaskActionButton(
                          height: actionButtonHeight,
                          minWidth: _adaptiveW(context, phone: 32, tablet: 24),
                          icon: Icons.route_rounded,
                          label: l10n.routePlayback,
                          iconSize: actionIconSize,
                          labelSize: actionLabelSize,
                          onPressed: () =>
                              _openRoutePlayback(context, routePlaybackWindow),
                          backgroundColor: const Color(0xFFDBEAFE),
                          foregroundColor: const Color(0xFF1D4ED8),
                          borderColor: const Color(0xFF93C5FD),
                          shadowColor: const Color(0xFF2563EB),
                        ),
                      _TaskActionButton(
                        height: actionButtonHeight,
                        minWidth: _adaptiveW(context, phone: 22, tablet: 17),
                        icon: Icons.delete_outline_rounded,
                        label: l10n.delete,
                        iconSize: actionIconSize,
                        labelSize: actionLabelSize,
                        onPressed: () => _handleDelete(context),
                        backgroundColor: const Color(0xFFFEE2E2),
                        foregroundColor: const Color(0xFFB91C1C),
                        borderColor: const Color(0xFFFCA5A5),
                        shadowColor: const Color(0xFFDC2626),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: .9.h),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            return _TimelineRow(
              label: step.label,
              value: step.value,
              isChecked: step.isChecked,
              showConnector: index != steps.length - 1,
              connectorActive:
                  index != steps.length - 1 && steps[index + 1].isChecked,
            );
          }),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.2.h),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? .34 : .10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(1.0.h),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red.shade500,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 2.4.w),
                  Expanded(
                    child: Text(
                      l10n.deleteTask,
                      style: AppStyles.semiboldTextStyle(ctx).copyWith(
                        fontSize: 14.2.sp,
                        color: onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.1.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.deleteTaskConfirmation,
                  style: AppStyles.regularTextStyle(ctx).copyWith(
                    fontSize: 12.8.sp,
                    color: onSurface.withValues(alpha: .82),
                  ),
                ),
              ),
              SizedBox(height: 1.25.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        l10n.cancel,
                        style: AppStyles.regularTextStyle(ctx).copyWith(
                          fontSize: 13.sp,
                          color: onSurface.withValues(alpha: .84),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  SizedBox(
                    width: 28.w,
                    child: CustomButton(
                      text: l10n.delete,
                      height: 3.9.h,
                      backgroundColor: AppColors.red,
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final result = await context.read<TaskProvider>().deleteTask(id: task.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleAssign(BuildContext context) async {
    final deviceId = fixedDeviceId;
    final vehicleName = (fixedVehicleName ?? '').trim();

    if (deviceId != null && deviceId > 0) {
      final confirmed = await _showFixedAssignDialog(
        context,
        vehicleName: vehicleName.isEmpty ? task.vehicleName : vehicleName,
      );
      if (confirmed != true || !context.mounted) return;
      final result = await context.read<TaskProvider>().assignTask(
            taskId: task.id,
            deviceId: deviceId,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selectedDevice = await _showAssignVehicleDialog(context);
    if (selectedDevice == null || !context.mounted) return;
    final result = await context.read<TaskProvider>().assignTask(
          taskId: task.id,
          deviceId: selectedDevice.id ?? 0,
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openRoutePlayback(
    BuildContext context,
    _RoutePlaybackWindow playbackWindow,
  ) async {
    final deviceId = task.device?.id ?? 0;
    if (deviceId <= 0) return;

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => SingleVehicleHistoryScreen(
          deviceId: deviceId,
          deviceTitle: task.vehicleName,
          initialFromDateTime: playbackWindow.from,
          initialToDateTime: playbackWindow.to,
        ),
      ),
    );
  }

  Future<bool?> _showFixedAssignDialog(
    BuildContext context, {
    required String vehicleName,
  }) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.3.h),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? .34 : .10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(1.0.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.assignment_return_rounded,
                      color: Colors.green.shade600,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 2.4.w),
                  Expanded(
                    child: Text(
                      l10n.assignTask,
                      style: AppStyles.semiboldTextStyle(ctx).copyWith(
                        fontSize: 14.2.sp,
                        color: onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.6.h),
              Text(
                l10n.recreateTaskForVehicle(vehicleName),
                style: AppStyles.regularTextStyle(ctx).copyWith(
                  fontSize: 12.9.sp,
                  color: onSurface.withValues(alpha: .82),
                ),
              ),
              SizedBox(height: 2.0.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: l10n.cancel,
                      onPressed: () => Navigator.pop(ctx, false),
                      backgroundColor: const Color(0xFFFEE2E2),
                      textColor: const Color(0xFFB91C1C),
                      borderRadius: 14,
                      height: 5.2.h,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: CustomButton(
                      text: l10n.ok,
                      onPressed: () => Navigator.pop(ctx, true),
                      backgroundColor: const Color(0xFFDCFCE7),
                      textColor: const Color(0xFF166534),
                      borderRadius: 14,
                      height: 5.2.h,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Item?> _showAssignVehicleDialog(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final statusItems =
        context.read<VehicleMapProvider>().deviceListModel?.items ??
            const <Item>[];
    final uniqueDevices = <int, Item>{};
    for (final device in statusItems) {
      final id = device.id;
      if (id == null || id <= 0) continue;
      uniqueDevices[id] = device;
    }
    final deviceList = uniqueDevices.values.toList(growable: false)
      ..sort((a, b) =>
          (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));

    return showDialog<Item>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        Item? selectedDevice = deviceList.isNotEmpty ? deviceList.first : null;
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.3.h),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? .34 : .10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(1.0.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.assignment_return_rounded,
                          color: Colors.green.shade600,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 2.4.w),
                      Expanded(
                        child: Text(
                          l10n.assignTask,
                          style: AppStyles.semiboldTextStyle(ctx).copyWith(
                            fontSize: 14.2.sp,
                            color: onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.6.h),
                  Text(
                    l10n.selectVehicleToRecreateTask,
                    style: AppStyles.regularTextStyle(ctx).copyWith(
                      fontSize: 12.9.sp,
                      color: onSurface.withValues(alpha: .82),
                    ),
                  ),
                  SizedBox(height: 1.6.h),
                  DropdownButtonFormField<int>(
                    initialValue: selectedDevice?.id,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.vehicle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: .04)
                          : Colors.white.withValues(alpha: .92),
                    ),
                    items: deviceList
                        .map(
                          (device) => DropdownMenuItem<int>(
                            value: device.id,
                            child: Text((device.name ?? '').trim()),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      setState(() {
                        selectedDevice = deviceList
                            .where((device) => device.id == value)
                            .firstOrNull;
                      });
                    },
                  ),
                  SizedBox(height: 2.0.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: l10n.cancel,
                          onPressed: () => Navigator.pop(ctx),
                          backgroundColor: const Color(0xFFFEE2E2),
                          textColor: const Color(0xFFB91C1C),
                          borderRadius: 14,
                          height: 5.2.h,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: CustomButton(
                          text: l10n.ok,
                          onPressed: selectedDevice == null
                              ? null
                              : () => Navigator.pop(ctx, selectedDevice),
                          backgroundColor: const Color(0xFFDCFCE7),
                          textColor: const Color(0xFF166534),
                          borderRadius: 14,
                          height: 5.2.h,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TaskActionButton extends StatelessWidget {
  final double height;
  final double minWidth;
  final IconData icon;
  final String label;
  final double iconSize;
  final double labelSize;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final Color shadowColor;

  const _TaskActionButton({
    required this.height,
    required this.minWidth,
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.labelSize,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(minWidth, height),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0.8,
          shadowColor: shadowColor.withValues(alpha: .35),
          padding: EdgeInsets.symmetric(
            horizontal: _adaptiveW(context, phone: 4.0, tablet: 3.0),
            vertical: _adaptiveH(context, phone: .30, tablet: .20),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
            side: BorderSide(color: borderColor),
          ),
        ),
        icon: Icon(icon, size: iconSize),
        label: Text(
          label,
          style: AppStyles.semiboldTextStyle(context).copyWith(
            fontSize: labelSize,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}

class _RoutePlaybackWindow {
  final DateTime from;
  final DateTime to;

  const _RoutePlaybackWindow({
    required this.from,
    required this.to,
  });
}

List<_TimelineStep> _buildTimelineSteps(BuildContext context, TaskItem task) {
  final l10n = context.l10n;
  final List<_TimelineStep> steps = <_TimelineStep>[
    _TimelineStep(
      label: l10n.pickup,
      value: task.pickup?.address ?? '-',
      isChecked: _hasValue(task.pickup?.address),
    ),
    _TimelineStep(
      label: l10n.reachedAt,
      value: task.pickup?.timeFrom ?? '-',
      isChecked: _hasValue(task.pickup?.timeFrom),
    ),
    _TimelineStep(
      label: l10n.leftAt,
      value: task.pickup?.timeTo ?? '-',
      isChecked: _hasValue(task.pickup?.timeTo),
    ),
  ];

  for (int index = 0; index < task.waypoints.length; index++) {
    final waypoint = task.waypoints[index];
    steps.add(
      _TimelineStep(
        label: l10n.taskStop(index + 1),
        value: waypoint.address,
        isChecked: _hasValue(waypoint.address),
      ),
    );
    steps.add(
      _TimelineStep(
        label: l10n.reachedAt,
        value: waypoint.reachedAt,
        isChecked: _hasValue(waypoint.reachedAt),
      ),
    );
    steps.add(
      _TimelineStep(
        label: l10n.leftAt,
        value: waypoint.leftAt,
        isChecked: _hasValue(waypoint.leftAt),
      ),
    );
  }

  steps.add(
    _TimelineStep(
      label: l10n.delivery,
      value: task.delivery?.address ?? '-',
      isChecked: _hasValue(task.delivery?.address),
    ),
  );
  steps.add(
    _TimelineStep(
      label: l10n.reachedAt,
      value: task.delivery?.timeFrom ?? '-',
      isChecked: _hasValue(task.delivery?.timeFrom),
    ),
  );
  steps.add(
    _TimelineStep(
      label: l10n.leftAt,
      value: task.delivery?.timeTo ?? '-',
      isChecked: _hasValue(task.delivery?.timeTo),
    ),
  );

  // Progress should stop at first incomplete milestone.
  bool canContinue = true;
  final List<_TimelineStep> normalized = <_TimelineStep>[];
  for (final step in steps) {
    final checked = canContinue && step.isChecked;
    if (!checked) canContinue = false;
    normalized.add(
      _TimelineStep(
        label: step.label,
        value: step.value,
        isChecked: checked,
      ),
    );
  }
  return normalized;
}

bool _hasValue(String? value) {
  if (value == null) return false;
  final text = value.trim();
  if (text.isEmpty) return false;
  return text.toLowerCase() != 'null';
}

final DateFormat _taskPlaybackApiDateTimeFormat =
    DateFormat('yyyy-MM-dd HH:mm:ss');

_RoutePlaybackWindow? _resolveRoutePlaybackWindow(TaskItem task) {
  final int deviceId = task.device?.id ?? 0;
  if (deviceId <= 0) return null;

  final DateTime? pickupReached = _tryParseTaskDateTime(
        task.pickup?.reachedAt,
      ) ??
      _tryParseTaskDateTime(task.pickup?.timeFrom);
  if (pickupReached == null) return null;

  final List<DateTime?> endCandidates = <DateTime?>[
    _tryParseTaskDateTime(task.pickup?.leftAt),
    for (final waypoint in task.waypoints) ...<DateTime?>[
      _tryParseTaskDateTime(waypoint.reachedAt),
      _tryParseTaskDateTime(waypoint.leftAt),
    ],
    _tryParseTaskDateTime(task.delivery?.reachedAt),
    _tryParseTaskDateTime(task.delivery?.leftAt),
  ];

  for (final candidate in endCandidates) {
    if (candidate != null && candidate.isAfter(pickupReached)) {
      return _RoutePlaybackWindow(from: pickupReached, to: candidate);
    }
  }

  final DateTime now = DateTime.now();
  return _RoutePlaybackWindow(
    from: pickupReached,
    to: now.isAfter(pickupReached) ? now : pickupReached,
  );
}

DateTime? _tryParseTaskDateTime(String? value) {
  if (!_hasValue(value)) return null;
  final String text = value!.trim();
  final DateTime? direct = DateTime.tryParse(text);
  if (direct != null) return direct;
  final DateTime? spaced = DateTime.tryParse(text.replaceFirst(' ', 'T'));
  if (spaced != null) return spaced;
  try {
    return _taskPlaybackApiDateTimeFormat.parseStrict(text);
  } catch (_) {
    return null;
  }
}

Color _statusTintColor(String statusName) {
  final status = statusName.trim().toLowerCase();
  if (status == 'new') return const Color(0xFFEAB308); // yellow
  if (status == 'in progress' || status == 'in_progress') {
    return const Color(0xFF16A34A); // green
  }
  if (status == 'completed' || status == 'complete') {
    return const Color(0xFF2563EB); // blue
  }
  return const Color(0xFF64748B); // fallback
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

class _TimelineStep {
  final String label;
  final String value;
  final bool isChecked;

  const _TimelineStep({
    required this.label,
    required this.value,
    required this.isChecked,
  });
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isChecked;
  final bool showConnector;
  final bool connectorActive;

  const _TimelineRow({
    required this.label,
    required this.value,
    required this.isChecked,
    required this.showConnector,
    required this.connectorActive,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final activeColor = const Color(0xFF0284C7);
    final inactiveColor = onSurface.withValues(alpha: .22);
    final markerSize =
        _adaptiveW(context, phone: 5.0, tablet: 3.2, desktop: 2.4);
    final iconSize = _adaptiveW(context, phone: 3.3, tablet: 2.2, desktop: 1.7);
    final connectorHeight =
        _adaptiveH(context, phone: 2.3, tablet: 1.9, desktop: 1.5);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _adaptiveW(context, phone: 8.0, tablet: 5.4, desktop: 4.0),
          child: Column(
            children: [
              Container(
                width: markerSize,
                height: markerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isChecked
                      ? activeColor.withValues(alpha: .16)
                      : Colors.transparent,
                  border: Border.all(
                    color: isChecked ? activeColor : inactiveColor,
                    width: 1.5,
                  ),
                ),
                child: isChecked
                    ? Icon(
                        Icons.check_rounded,
                        size: iconSize,
                        color: activeColor,
                      )
                    : null,
              ),
              if (showConnector)
                SizedBox(
                  height: connectorHeight,
                  child: _VerticalDotConnector(
                    color: connectorActive ? activeColor : inactiveColor,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: .4.h),
            child: _TaskField(label: label, value: value),
          ),
        ),
      ],
    );
  }
}

class _VerticalDotConnector extends StatelessWidget {
  final Color color;

  const _VerticalDotConnector({required this.color});

  @override
  Widget build(BuildContext context) {
    final dotSize = _adaptiveW(context, phone: .9, tablet: .55, desktop: .42);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List<Widget>.generate(
          5,
          (_) => Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskField extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _TaskField({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelWidth = _adaptiveW(context, phone: 25, tablet: 19, desktop: 15);
    final emphasizeSize = _adaptiveSp(context, phone: 13.1, tablet: 10.0);
    final regularSize = _adaptiveSp(context, phone: 12.6, tablet: 9.7);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: emphasize ? emphasizeSize : regularSize,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
              color: emphasize
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: .60),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.trim().isEmpty ? '-' : value.trim(),
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: emphasize ? emphasizeSize : regularSize,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
              color: emphasize
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: .68),
            ),
          ),
        ),
      ],
    );
  }
}

double _adaptiveSp(
  BuildContext context, {
  required double phone,
  required double tablet,
  double? desktop,
}) {
  final width = MediaQuery.sizeOf(context).width;
  // Prioritize mobile readability first: scale text up across phone widths.
  if (width < 600) {
    final double mobileFactor;
    if (width <= 360) {
      mobileFactor = 1.06; // compact phones
    } else if (width <= 430) {
      mobileFactor = 1.13; // most phones
    } else {
      mobileFactor = 1.17; // large phones
    }
    return (phone * mobileFactor).sp;
  }
  if (width >= 1100) {
    final base = desktop ?? tablet;
    return (base * 1.08).sp;
  }
  return (tablet * 1.06).sp;
}

double _adaptiveW(
  BuildContext context, {
  required double phone,
  required double tablet,
  double? desktop,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= 1100 && desktop != null) return desktop.w;
  return (width >= 600 ? tablet : phone).w;
}

double _adaptiveH(
  BuildContext context, {
  required double phone,
  required double tablet,
  double? desktop,
  double min = 0,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final value = (width >= 1100 && desktop != null
          ? desktop
          : (width >= 600 ? tablet : phone))
      .h;
  if (min <= 0) return value;
  return math.max(min, value);
}
