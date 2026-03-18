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
  String _selectedVehicle = 'All Vehicles';

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
    final showAddTaskAction =
        widget.initialDeviceId != null && widget.lockVehicleFilter;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'All Tasks'),
        actions: [
          if (showAddTaskAction)
            Padding(
              padding: EdgeInsets.only(right: 3.w),
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.4.w, vertical: .7.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: const BorderSide(
                      color: Color(0xFF86EFAC),
                    ),
                  ),
                ),
                icon: const Icon(Icons.add_task_rounded),
                label: Text(
                  'Add Task',
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 13.sp,
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
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 1.2.h),
                    ElevatedButton(
                      onPressed: () => provider.fetchTasks(force: true),
                      child: const Text('Retry'),
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
          final vehicleFilterItems = <String>['All Vehicles', ...vehicleNames];
          if (!vehicleFilterItems.contains(_selectedVehicle)) {
            _selectedVehicle = 'All Vehicles';
          }

          final filtered = tasks.where((task) {
            final vehicle = task.vehicleName.trim();
            final title = task.title.trim();
            final q = _searchText.trim().toLowerCase();
            final byDevice = widget.initialDeviceId == null ||
                task.device?.id == widget.initialDeviceId;
            if (!byDevice) return false;
            final byVehicle = _selectedVehicle == 'All Vehicles' ||
                vehicle.toLowerCase() == _selectedVehicle.toLowerCase();
            if (!byVehicle) return false;
            if (q.isEmpty) return true;
            return title.toLowerCase().contains(q) ||
                vehicle.toLowerCase().contains(q);
          }).toList(growable: false);

          if (tasks.isEmpty) {
            return Center(
              child: Text(
                'No tasks found',
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 13.6.sp,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchTasks(force: true),
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 2.h),
              itemCount: filtered.length + 2,
              separatorBuilder: (_, __) => SizedBox(height: 1.h),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: .9.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: .10),
        ),
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
              hintText: 'Search by title or vehicle',
              prefixIcon: const Icon(Icons.search_rounded),
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
                          horizontal: 3.w,
                          vertical: 1.45.h,
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
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        initialValue: _selectedVehicle,
                        isExpanded: true,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Vehicle',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: vehicleFilterItems
                            .map(
                              (name) => DropdownMenuItem<String>(
                                value: name,
                                child: Text(name),
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
                padding:
                    EdgeInsets.symmetric(horizontal: 2.2.w, vertical: .7.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$resultCount',
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.sp,
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
                ? 'Showing $loadedCount of $totalCount tasks'
                : 'Showing $loadedCount tasks',
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 11.6.sp,
              fontWeight: FontWeight.w700,
              color: onSurface.withValues(alpha: .66),
            ),
          ),
          if (provider.hasMoreTasks) ...[
            SizedBox(height: .8.h),
            OutlinedButton(
              onPressed: provider.loadMoreTasks,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.2.w,
                  vertical: .85.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                'Load More',
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  fontSize: 12.sp,
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
    final theme = Theme.of(context);
    final statusText =
        task.statusName.trim().isEmpty ? 'Unknown' : task.statusName.trim();
    final routePlaybackWindow = _resolveRoutePlaybackWindow(task);
    final statusTint = _statusTintColor(statusText);
    final bgColor = Color.alphaBlend(
      statusTint.withValues(
          alpha: theme.brightness == Brightness.dark ? .16 : .10),
      theme.cardColor,
    );
    final steps = _buildTimelineSteps(task);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.4.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusTint.withValues(alpha: .28),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.30)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(2.8.w, .95.h, 2.8.w, .9.h),
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
                          fontSize: 14.6.sp,
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
                        color: const Color(0xFF0284C7).withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFF0284C7).withValues(alpha: .32),
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: AppStyles.regularTextStyle(context).copyWith(
                          fontSize: 13.2.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0B4A6F),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: .75.h),
                _TaskField(
                  label: 'Vehicle',
                  value: task.vehicleName,
                  emphasize: true,
                ),
                SizedBox(height: .45.h),
                _TaskField(
                  label: 'Status',
                  value: statusText,
                  emphasize: true,
                ),
                SizedBox(height: .45.h),
                _TaskField(
                  label: 'Has Stops',
                  value: task.hasStops ? 'Yes' : 'No',
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
                      SizedBox(
                        height: 3.3.h,
                        child: OutlinedButton.icon(
                          onPressed: () => _handleAssign(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.2.w,
                              vertical: .1.h,
                            ),
                            side: BorderSide(color: Colors.green.shade300),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: Icon(
                            Icons.assignment_return_rounded,
                            size: 14,
                            color: Colors.green.shade600,
                          ),
                          label: Text(
                            'Assign',
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 3.3.h,
                        child: OutlinedButton.icon(
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
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.9.w,
                              vertical: .1.h,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 14),
                          label: Text(
                            'Edit',
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (routePlaybackWindow != null)
                        SizedBox(
                          height: 3.3.h,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _openRoutePlayback(context, routePlaybackWindow),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.6.w,
                                vertical: .1.h,
                              ),
                              side: const BorderSide(
                                color: Color(0xFF2563EB),
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(
                              Icons.route_rounded,
                              size: 14,
                              color: Color(0xFF2563EB),
                            ),
                            label: Text(
                              'Route Playback',
                              style: AppStyles.regularTextStyle(context)
                                  .copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 3.3.h,
                        child: OutlinedButton.icon(
                          onPressed: () => _handleDelete(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.5.w,
                              vertical: .1.h,
                            ),
                            side: BorderSide(color: Colors.red.shade300),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 14,
                            color: Colors.red.shade500,
                          ),
                          label: Text(
                            'Delete',
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade500,
                            ),
                          ),
                        ),
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
                      'Delete Task',
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
                  'Are you sure you want to delete this task?',
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
                        'Cancel',
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
                      text: 'Delete',
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
                      'Assign Task',
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
                'Are you sure, you want to re create this task for the "$vehicleName"?',
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
                      text: 'Cancel',
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
                      text: 'OK',
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
                          'Assign Task',
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
                    'Select a vehicle to re create this task.',
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
                      labelText: 'Vehicle',
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
                          text: 'Cancel',
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
                          text: 'OK',
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

class _RoutePlaybackWindow {
  final DateTime from;
  final DateTime to;

  const _RoutePlaybackWindow({
    required this.from,
    required this.to,
  });
}

List<_TimelineStep> _buildTimelineSteps(TaskItem task) {
  final List<_TimelineStep> steps = <_TimelineStep>[
    _TimelineStep(
      label: 'Pickup',
      value: task.pickup?.address ?? '-',
      isChecked: _hasValue(task.pickup?.address),
    ),
    _TimelineStep(
      label: 'Reached at',
      value: task.pickup?.timeFrom ?? '-',
      isChecked: _hasValue(task.pickup?.timeFrom),
    ),
    _TimelineStep(
      label: 'Left at',
      value: task.pickup?.timeTo ?? '-',
      isChecked: _hasValue(task.pickup?.timeTo),
    ),
  ];

  for (int index = 0; index < task.waypoints.length; index++) {
    final waypoint = task.waypoints[index];
    steps.add(
      _TimelineStep(
        label: 'Stop ${index + 1}',
        value: waypoint.address,
        isChecked: _hasValue(waypoint.address),
      ),
    );
    steps.add(
      _TimelineStep(
        label: 'Reached at',
        value: waypoint.reachedAt,
        isChecked: _hasValue(waypoint.reachedAt),
      ),
    );
    steps.add(
      _TimelineStep(
        label: 'Left at',
        value: waypoint.leftAt,
        isChecked: _hasValue(waypoint.leftAt),
      ),
    );
  }

  steps.add(
    _TimelineStep(
      label: 'Delivery',
      value: task.delivery?.address ?? '-',
      isChecked: _hasValue(task.delivery?.address),
    ),
  );
  steps.add(
    _TimelineStep(
      label: 'Reached at',
      value: task.delivery?.timeFrom ?? '-',
      isChecked: _hasValue(task.delivery?.timeFrom),
    ),
  );
  steps.add(
    _TimelineStep(
      label: 'Left at',
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 8.w,
          child: Column(
            children: [
              Container(
                width: 5.w,
                height: 5.w,
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
                        size: 3.4.w,
                        color: activeColor,
                      )
                    : null,
              ),
              if (showConnector)
                SizedBox(
                  height: 2.4.h,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List<Widget>.generate(
          5,
          (_) => Container(
            width: .9.w,
            height: .9.w,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 25.w,
          child: Text(
            label,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: emphasize ? 13.8.sp : 13.4.sp,
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
              fontSize: emphasize ? 13.8.sp : 13.4.sp,
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
