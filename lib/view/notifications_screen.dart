import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_alerts_list_model.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart'
    // ignore: library_prefixes
    as DeviceModel;
import 'package:trackerapp/providers/alerts_provider.dart';
import 'package:trackerapp/providers/vehicle_list_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/utils/top_curve_bezier.dart';
import 'package:trackerapp/view/alert_location_screen.dart';
import 'package:trackerapp/widgets/custom_text_field.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/search_textfield.dart';

import '../providers/get_device_group_provider.dart';

class NewNotificationScreen extends StatefulWidget {
  const NewNotificationScreen({super.key});

  @override
  State<NewNotificationScreen> createState() => _NewNotificationScreenState();
}

class _NewNotificationScreenState extends State<NewNotificationScreen>
    with WidgetsBindingObserver {
  static const String _allAlertTypesValue = 'All';

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int? _selectedDeviceId;
  String? _selectedAlertType = _allAlertTypesValue;
  DateTime? _fromFilterDate;
  DateTime? _toFilterDate;
  String? _selectedDatePreset;
  late final GetDevicesListProvider _provider;
  AlertsProvider? _alertsProviderForListener;
  bool _isApplyingPendingAlertType = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _provider = Provider.of<GetDevicesListProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.init(context);
      final groupProvider =
          Provider.of<GetDeviceGroupProvider>(context, listen: false);
      groupProvider.fetchDeviceGroups(isRefresh: true, context: context);
    });
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final alertsProvider =
          Provider.of<AlertsProvider>(context, listen: false);
      final pending = alertsProvider.pendingAlertTypeLabel?.trim();
      if (pending != null && pending.isNotEmpty) {
        _consumePendingAlertTypeFilter();
      } else if (alertsProvider.model == null) {
        alertsProvider.fetchAlerts(isRefresh: true, context: context);
      }
    });

    _alertsProviderForListener =
        Provider.of<AlertsProvider>(context, listen: false);
    _alertsProviderForListener!.addListener(_onAlertsProviderChanged);

    // Listen to search text changes
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final alertsProvider = Provider.of<AlertsProvider>(context, listen: false);
    alertsProvider.setSearchQuery(_searchController.text);
  }

  void _onAlertsProviderChanged() {
    _consumePendingAlertTypeFilter();
  }

  void _consumePendingAlertTypeFilter() {
    if (!mounted || _isApplyingPendingAlertType) return;
    final alertsProvider = Provider.of<AlertsProvider>(context, listen: false);
    final pending = alertsProvider.pendingAlertTypeLabel?.trim();
    if (pending == null || pending.isEmpty) return;

    _isApplyingPendingAlertType = true;
    _searchController.clear();
    alertsProvider.setSearchQuery('');
    setState(() {
      _selectedDeviceId = null;
      _selectedAlertType = pending;
    });
    alertsProvider.setDeviceFilter(null);
    alertsProvider.setAlertTypeFilter(pending);

    final alreadyFetchingSameFilter = alertsProvider.isLoading &&
        (alertsProvider.alertTypeFilter ?? '').trim().toLowerCase() ==
            pending.toLowerCase();
    alertsProvider.clearPendingAlertTypeLabel();
    if (!alreadyFetchingSameFilter) {
      alertsProvider.fetchAlerts(isRefresh: true, context: context);
    }
    _isApplyingPendingAlertType = false;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final provider = Provider.of<AlertsProvider>(context, listen: false);
      if (provider.hasMore && !provider.isLoadMore && !provider.isLoading) {
        provider.fetchAlerts(context: context);
      }
    }
  }

  Future<void> _onRefresh() async {
    await Provider.of<AlertsProvider>(context, listen: false)
        .fetchAlerts(isRefresh: true, context: context);
  }

  void _applyFilters() {
    final alertsProvider = Provider.of<AlertsProvider>(context, listen: false);
    alertsProvider.setDeviceFilter(_selectedDeviceId);
    alertsProvider.setAlertTypeFilter(
        _selectedAlertType == _allAlertTypesValue ? null : _selectedAlertType);
    alertsProvider.setDateRangeFilter(from: _fromFilterDate, to: _toFilterDate);
    alertsProvider.fetchAlerts(isRefresh: true, context: context);
  }

  Future<void> _pickFromDateFilter() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromFilterDate ?? today,
      firstDate: DateTime(2020),
      lastDate: _toFilterDate == null
          ? today
          : (_toFilterDate!.isBefore(today) ? _toFilterDate! : today),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _selectedDatePreset = null;
      _fromFilterDate = DateTime(picked.year, picked.month, picked.day);
      _toFilterDate ??= _fromFilterDate;
    });
    _applyFilters();
  }

  Future<void> _pickToDateFilter() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _toFilterDate ?? _fromFilterDate ?? today,
      firstDate: _fromFilterDate ?? DateTime(2020),
      lastDate: today,
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _selectedDatePreset = null;
      _toFilterDate = DateTime(picked.year, picked.month, picked.day);
      _fromFilterDate ??= _toFilterDate;
    });
    _applyFilters();
  }

  void _applyDatePreset(String preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime from;
    DateTime to;
    switch (preset) {
      case notificationPresetToday:
        from = today;
        to = today;
        break;
      case notificationPresetYesterday:
        final y = today.subtract(const Duration(days: 1));
        from = y;
        to = y;
        break;
      case notificationPresetLast7Days:
        from = today.subtract(const Duration(days: 6));
        to = today;
        break;
      case notificationPresetLast30Days:
        from = today.subtract(const Duration(days: 29));
        to = today;
        break;
      default:
        return;
    }
    setState(() {
      _selectedDatePreset = preset;
      _fromFilterDate = from;
      _toFilterDate = to;
    });
    _applyFilters();
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 10,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.only(bottom: 1.5.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading:
                const CircleAvatar(radius: 20, backgroundColor: Colors.white),
            title: Container(height: 16, color: Colors.white),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 220, color: Colors.white),
                verticalSpace(height: 0.5.h),
                Container(height: 12, width: 120, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _alertsProviderForListener?.removeListener(_onAlertsProviderChanged);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        Provider.of<AlertsProvider>(context, listen: false)
            .fetchAlerts(isRefresh: true, context: context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final isCompactLandscape =
        mediaQuery.orientation == Orientation.landscape ||
            mediaQuery.size.height < 720;
    final cardColor = theme.cardColor;
    final onSurface = theme.colorScheme.onSurface;
    final topContentSpacing =
        MediaQuery.paddingOf(context).top + (isCompactLandscape ? 4 : 8);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(colors: [theme.cardColor, theme.cardColor])
              : AppColors.mainGradient,
        ),
        child: SizedBox(
          height: 100.h,
          width: 100.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: topContentSpacing),
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Consumer2<AlertsProvider, GetDevicesListProvider>(
                      builder:
                          (context, alertsProvider, devicesProvider, child) {
                        final alertTypes = alertsProvider.alertTypeList;
                        final alertCounts = alertsProvider.alertTypeCounts;

                        final List<DeviceModel.Item> devices =
                            devicesProvider.model?.items ?? [];
                        final allVehiclesLabel = l10n.allVehicles;

                        final vehicleItems = [
                          allVehiclesLabel,
                          ...devices.map(
                            (d) => d.name ?? '${l10n.vehicleLabel} ${d.id}',
                          )
                        ];
                        String? selectedVehicleName;
                        if (_selectedDeviceId == null) {
                          selectedVehicleName = allVehiclesLabel;
                        } else {
                          try {
                            final device = devices.firstWhere(
                              (d) => d.id == _selectedDeviceId,
                            );
                            selectedVehicleName = device.name ??
                                '${l10n.vehicleLabel} ${device.id}';
                          } catch (e) {
                            selectedVehicleName = allVehiclesLabel;
                          }
                        }

                        // Safe alert type selection
                        String? selectedAlertType = alertTypes
                                .contains(_selectedAlertType)
                            ? _selectedAlertType
                            : (alertTypes.isNotEmpty ? alertTypes.first : null);

                        return SearchAndFilterBar(
                          compactMode: isCompactLandscape,
                          alertTypes: alertTypes,
                          vehicles: vehicleItems,
                          alertCounts: alertCounts,
                          selectedVehicle: selectedVehicleName,
                          selectedAlertType: selectedAlertType,
                          selectedPreset: _selectedDatePreset,
                          onPresetSelected: _applyDatePreset,
                          fromDateLabel: _fromFilterDate == null
                              ? l10n.fromDate
                              : DateFormat('dd/MM/yyyy')
                                  .format(_fromFilterDate!),
                          toDateLabel: _toFilterDate == null
                              ? l10n.toDate
                              : DateFormat('dd/MM/yyyy').format(_toFilterDate!),
                          onFromDateTap: _pickFromDateFilter,
                          onToDateTap: _pickToDateFilter,
                          searchController: _searchController,
                          onVehicleChanged: (val) {
                            setState(() {
                              if (val == allVehiclesLabel || val == null) {
                                _selectedDeviceId = null;
                              } else {
                                try {
                                  final device = devices.firstWhere(
                                    (d) =>
                                        (d.name ??
                                            '${l10n.vehicleLabel} ${d.id}') ==
                                        val,
                                  );
                                  _selectedDeviceId = device.id;
                                } catch (e) {
                                  _selectedDeviceId = null;
                                }
                              }
                            });
                            _applyFilters();
                          },
                          onAlertTypeChanged: (val) {
                            setState(() {
                              _selectedAlertType = val;
                            });
                            _applyFilters();
                          },
                          onSearchPressed: _applyFilters,
                          onFilterReset: () {
                            final alertsProvider = Provider.of<AlertsProvider>(
                              context,
                              listen: false,
                            );
                            setState(() {
                              _selectedDeviceId = null;
                              _selectedAlertType = _allAlertTypesValue;
                              _selectedDatePreset = null;
                              _fromFilterDate = null;
                              _toFilterDate = null;
                            });
                            alertsProvider.resetFiltersOnly(context);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              verticalSpace(height: isCompactLandscape ? 1.h : 2.h),

              // Main Curved Area
              Expanded(
                child: ClipPath(
                  clipper: TopCurveClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? LinearGradient(
                              colors: [
                                theme.scaffoldBackgroundColor,
                                theme.scaffoldBackgroundColor
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : LinearGradient(
                              colors: [Colors.white, Colors.grey.shade100],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      children: [
                        verticalSpace(height: isCompactLandscape ? 1.h : 2.h),

                        // Title + Delete Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.notificationsTitle,
                              style: AppStyles.boldTextStyle(context).copyWith(
                                color: onSurface,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Consumer<AlertsProvider>(
                              builder: (context, provider, child) {
                                if (provider.selectedAlertIds.isNotEmpty) {
                                  return IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text(l10n.deleteAlerts),
                                          content: Text(
                                            l10n.deleteAlertsConfirmation(
                                              provider.selectedAlertIds.length,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: Text(l10n.cancel)),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: Text(
                                                l10n.delete,
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        final success = await provider
                                            .deleteSelectedAlerts();
                                        if (context.mounted && success) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                l10n.alertsDeletedSuccessfully,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ],
                        ),

                        verticalSpace(height: isCompactLandscape ? 1.h : 2.h),

                        SizedBox(
                          height: 5.7.h,
                          child: CustomTextField(
                            controller: _searchController,
                            labelText: l10n.searchNotification,
                            borderRadius: 12.px,
                            contentPaddingV: 1.15.h,
                            fillColor: cardColor,
                            showShadow: true,
                            suffixIcon: Icons.search_outlined,
                            onSuffixTap: _applyFilters,
                            onSubmitted: (_) => _applyFilters(),
                          ),
                        ),

                        verticalSpace(height: 1.1.h),

                        // Alerts List
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: Consumer<AlertsProvider>(
                              builder: (context, provider, child) {
                                if (provider.isLoading &&
                                    provider.model == null) {
                                  return _buildShimmerList();
                                }

                                if (provider.errorMessage != null &&
                                    provider.model == null) {
                                  return Center(
                                      child: Text(provider.errorMessage!));
                                }
                                final items = provider.filteredItems;

                                if (items.isEmpty) {
                                  return Center(
                                      child: Text(
                                    _searchController.text.isNotEmpty
                                        ? l10n.noAlertsMatchSearch
                                        : l10n.noAlertsFound,
                                  ));
                                }

                                return ListView.builder(
                                  controller: _scrollController,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: items.length +
                                      (provider.isLoadMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == items.length) {
                                      return Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: isDark
                                                  ? Colors.tealAccent
                                                  : Colors.teal,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    final Item alert = items[index];
                                    final bool isSelected = provider
                                        .selectedAlertIds
                                        .contains(alert.id);

                                    return GestureDetector(
                                      onLongPress: () =>
                                          provider.toggleSelection(alert.id),
                                      onTap: () {
                                        if (provider
                                            .selectedAlertIds.isNotEmpty) {
                                          provider.toggleSelection(alert.id);
                                        } else {
                                          final hasValidLocation =
                                              alert.latitude != 0.0 ||
                                                  alert.longitude != 0.0;
                                          if (!hasValidLocation) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  l10n.locationUnavailableForAlert,
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  AlertLocationScreen(
                                                alert: alert,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        margin: EdgeInsets.only(bottom: 0.7.h),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          border: isSelected
                                              ? Border.all(
                                                  color: Colors.redAccent,
                                                  width: 1.6,
                                                )
                                              : null,
                                          boxShadow: [
                                            BoxShadow(
                                              color: isDark
                                                  ? Colors.black
                                                      .withValues(alpha: 0.36)
                                                  : Colors.black
                                                      .withValues(alpha: 0.07),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 3.8.w,
                                              vertical: .4.h),
                                          leading: CircleAvatar(
                                            radius: 21,
                                            backgroundColor: isDark
                                                ? Colors.redAccent
                                                    .withValues(alpha: 0.18)
                                                : Colors.redAccent
                                                    .withValues(alpha: 0.12),
                                            child: Icon(
                                              isSelected
                                                  ? Icons.check_circle
                                                  : Icons
                                                      .notifications_active_outlined,
                                              color: isSelected
                                                  ? Colors.green
                                                  : Colors.redAccent,
                                              size: 19.sp,
                                            ),
                                          ),
                                          title: Text(
                                            alert.deviceName,
                                            style: AppStyles.regularTextStyle(
                                                    context)
                                                .copyWith(
                                              color: onSurface,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                alert.message,
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.redAccent
                                                          .withValues(
                                                              alpha: .88)
                                                      : Colors.redAccent
                                                          .withValues(
                                                              alpha: .9),
                                                  fontSize: 14.4.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              verticalSpace(height: 0.35.h),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time_rounded,
                                                    size: 14.sp,
                                                    color: onSurface.withValues(
                                                        alpha: 0.52),
                                                  ),
                                                  SizedBox(width: 1.w),
                                                  Expanded(
                                                    child: Text(
                                                      alert.time != null
                                                          ? DateFormat('dd-MM-yyyy hh:mm:ss a').format(alert.time!.toLocal())
                                                          : l10n.noTime,
                                                      style: AppStyles
                                                              .lightTextStyle(
                                                                  context)
                                                          .copyWith(
                                                        color: onSurface
                                                            .withValues(
                                                                alpha: 0.62),
                                                        fontSize: 13.sp,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: Container(
                                            height: 3.2.h,
                                            width: 3.2.h,
                                            decoration: BoxDecoration(
                                              color: onSurface.withValues(
                                                  alpha: isDark ? 0.12 : 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: onSurface.withValues(
                                                  alpha: 0.66),
                                              size: 13.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
