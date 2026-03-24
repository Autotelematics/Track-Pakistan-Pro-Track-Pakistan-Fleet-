import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/app/theme/responsive_scale.dart';
import 'package:trackerapp/providers/alerts_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/view/alert_location_screen.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/custom_text_field.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class SingleVehicleAlertScreen extends StatefulWidget {
  final int deviceId;

  const SingleVehicleAlertScreen({
    super.key,
    required this.deviceId,
  });

  @override
  State<SingleVehicleAlertScreen> createState() =>
      _SingleVehicleAlertScreenState();
}

class _SingleVehicleAlertScreenState extends State<SingleVehicleAlertScreen>
    with WidgetsBindingObserver {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? selectedCategory;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true;
        final provider = Provider.of<AlertsProvider>(context, listen: false);
        provider.setDeviceFilter(widget.deviceId);
        provider.setAlertTypeFilter(null);
        provider.fetchAlerts(isRefresh: true, context: context);
      }
    });
  }

  void _onSearchChanged() {
    final alertsProvider = Provider.of<AlertsProvider>(context, listen: false);
    alertsProvider.setSearchQuery(searchController.text);
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        final provider = Provider.of<AlertsProvider>(context, listen: false);
        provider.fetchAlerts(isRefresh: true, context: context);
      });
    }
  }

  List<Map<String, dynamic>> _getAlertCategories(
    BuildContext context,
    Map<String, int> counts,
  ) {
    final l10n = context.l10n;
    return [
      {
        'icon': Icons.speed,
        'key': 'Over Speed',
        'name': l10n.overSpeed,
        'unit': l10n.times,
        'value': counts['Over Speed'] ?? 0,
        'bgColor': const Color(0xFFFFC107),
      },
      {
        'icon': Icons.timer_outlined,
        'key': 'Idle Duration',
        'name': l10n.idleDuration,
        'unit': l10n.times,
        'value': counts['Idle Duration'] ?? 0,
        'bgColor': const Color(0xFFFF9800),
      },
      {
        'icon': Icons.power_settings_new,
        'key': 'Ignition duration',
        'name': l10n.ignitionDuration,
        'unit': l10n.times,
        'value': counts['Ignition duration'] ?? 0,
        'bgColor': const Color(0xFFEF5350),
      },
      {
        'icon': Icons.directions_car,
        'key': 'Move Start',
        'name': l10n.moveStart,
        'unit': l10n.times,
        'value': counts['Move Start'] ?? 0,
        'bgColor': const Color(0xFF4CAF50),
      },
      {
        'icon': Icons.signal_wifi_off,
        'key': 'Offline duration',
        'name': l10n.offlineDuration,
        'unit': l10n.times,
        'value': counts['Offline duration'] ?? 0,
        'bgColor': const Color(0xFF009688),
      },
      {
        'icon': Icons.local_parking,
        'key': 'Over Parking',
        'name': l10n.overParking,
        'unit': l10n.times,
        'value': counts['Over Parking'] ?? 0,
        'bgColor': const Color(0xFF6A1B9A),
      },
    ];
  }

  Widget _buildEmptyState() {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          verticalSpace(height: 2.h),
          Text(
            l10n.singleVehicleNoAlertsFound,
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: 18.sp,
              color: Colors.grey.shade600,
            ),
          ),
          verticalSpace(height: 1.h),
          Text(
            selectedCategory != null
                ? l10n.singleVehicleNoAlertsCategory
                : searchController.text.isNotEmpty
                    ? l10n.singleVehicleNoAlertsSearch
                    : l10n.singleVehicleNoAlertsVehicle,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          if (selectedCategory != null) ...[
            verticalSpace(height: 1.h),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  selectedCategory = null;
                });
                final provider =
                    Provider.of<AlertsProvider>(context, listen: false);
                provider.setAlertTypeFilter(null);
                provider.fetchAlerts(isRefresh: true, context: context);
              },
              icon: const Icon(Icons.clear_all),
              label: Text(l10n.showAllAlerts),
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstantColor.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, AlertsProvider provider) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade400,
          ),
          verticalSpace(height: 2.h),
          Text(
            l10n.oopsSomethingWrong,
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: 18.sp,
              color: Colors.grey.shade700,
            ),
          ),
          verticalSpace(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              error,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          verticalSpace(height: 3.h),
          ElevatedButton.icon(
            onPressed: () {
              provider.fetchAlerts(isRefresh: true, context: context);
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.tryAgain),
            style: ElevatedButton.styleFrom(
              backgroundColor: ConstantColor.primaryColor,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textScale = appTextScale(context, ScaleProfile.notifications);
    final iconScale = appIconScale(context, ScaleProfile.notifications);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: IconTheme(
          data: IconTheme.of(context).copyWith(size: 24 * iconScale),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 5.2.h, 4.w, 0),
              child: Consumer<AlertsProvider>(
                builder: (context, provider, _) {
                  final alerts =
                      _getAlertCategories(context, provider.alertTypeCounts);
                  final filteredItems = provider.filteredItems;

                  // Show error state
                  if (provider.errorMessage != null &&
                      !provider.isLoading &&
                      provider.currentPage == 1) {
                    return Column(
                      children: [
                        verticalSpace(height: 4.0.h),
                        CustomTextField(
                          controller: searchController,
                          labelText: l10n.searchNotification,
                          borderRadius: 15.px,
                          suffixIcon: Icons.search_outlined,
                          onSuffixTap: () {
                            // Real-time search already handles this
                          },
                          onSubmitted: (value) {
                            // Real-time search already handles this
                          },
                        ),
                        verticalSpace(height: 2.h),
                        Expanded(
                          child: _buildErrorState(
                              provider.errorMessage!, provider),
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // verticalSpace(height: 1.0.h),
                      // Text(
                      //   "Vehicle Notifications",
                      //   style: AppStyles.boldTextStyle(context).copyWith(
                      //     fontSize: 14.3.sp,
                      //     color: isDark ? AppColors.white : AppColors.textBlack,
                      //   ),
                      // ),
                      // verticalSpace(height: 0.0.h),
                      CustomTextField(
                        controller: searchController,
                        labelText: l10n.searchNotification,
                        borderRadius: 15.px,
                        suffixIcon: Icons.search_outlined,
                        onSuffixTap: () {
                          // Real-time search already handles this
                        },
                        onSubmitted: (value) {
                          // Real-time search already handles this
                        },
                      ),
                      verticalSpace(height: 1.h),
                      Text(
                        l10n.alertsCategory,
                        style: AppStyles.semiboldTextStyle(context).copyWith(
                          fontSize: 14.2.sp,
                          color: isDark ? AppColors.white : AppColors.textBlack,
                        ),
                      ),
                      verticalSpace(height: .8.h),

                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              selectedCategory = null;
                            });
                            provider.setAlertTypeFilter(null);
                            await provider.fetchAlerts(
                              isRefresh: true,
                              context: context,
                            );
                          },
                          child: ListView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            children: [
                              // Grid with 6 items
                              GridView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: alerts.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                  childAspectRatio: 1.55,
                                ),
                                itemBuilder: (context, index) {
                                  final item = alerts[index];
                                  final isSelected =
                                      selectedCategory == item['key'];
                                  final tileColor = item['bgColor'] as Color;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (selectedCategory == item['key']) {
                                          selectedCategory = null;
                                          provider.setAlertTypeFilter(null);
                                        } else {
                                          selectedCategory =
                                              item['key'] as String;
                                          provider.setAlertTypeFilter(
                                              selectedCategory);
                                        }
                                      });
                                      provider.fetchAlerts(
                                        isRefresh: true,
                                        context: context,
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 1.0.h, horizontal: 2.8.w),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? tileColor.withValues(alpha: 0.18)
                                            : cardColor,
                                        borderRadius:
                                            BorderRadius.circular(14.px),
                                        border: Border.all(
                                          color: isSelected
                                              ? tileColor.withValues(alpha: .8)
                                              : (isDark
                                                  ? Colors.white12
                                                  : Colors.black12),
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                                alpha: isDark ? .18 : .07),
                                            blurRadius: 10,
                                            spreadRadius: 0,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            right: -.8.w,
                                            bottom: -.2.h,
                                            child: Icon(
                                              item['icon'] as IconData,
                                              size: 28.sp,
                                              color: tileColor.withValues(
                                                  alpha: isDark ? .24 : .20),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                item['name'].toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    AppStyles.semiboldTextStyle(
                                                            context)
                                                        .copyWith(
                                                  fontSize: 12.2.sp,
                                                  color: isDark
                                                      ? AppColors.white
                                                      : AppColors.textBlack,
                                                ),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: '${item['value']} ',
                                                      style: AppStyles
                                                              .boldTextStyle(
                                                                  context)
                                                          .copyWith(
                                                        fontSize: 13.8.sp,
                                                        color: isDark
                                                            ? AppColors.white
                                                            : AppColors
                                                                .textBlack,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: item['unit']
                                                          .toString(),
                                                      style: AppStyles
                                                              .regularTextStyle(
                                                                  context)
                                                          .copyWith(
                                                        fontSize: 11.4.sp,
                                                        color: isDark
                                                            ? Colors.white70
                                                            : Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              verticalSpace(height: 1.0.h),

                              // Loading / Empty / List state for alerts section only
                              if (provider.isLoading &&
                                  provider.currentPage == 1)
                                SizedBox(
                                  height: 24.h,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const CircularProgressIndicator(),
                                        verticalSpace(height: 0.5.h),
                                        Text(
                                          l10n.loadingAlerts,
                                          style: AppStyles.regularTextStyle(
                                                  context)
                                              .copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else if (filteredItems.isEmpty)
                                SizedBox(
                                  height: 30.h,
                                  child: _buildEmptyState(),
                                )
                              else
                                ListView.builder(
                                  itemCount: filteredItems.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    final item = filteredItems[index];
                                    final isSelected = provider.selectedAlertIds
                                        .contains(item.id);

                                    return GestureDetector(
                                      onLongPress: () {
                                        provider.toggleSelection(item.id);
                                      },
                                      onTap: () {
                                        if (provider
                                            .selectedAlertIds.isNotEmpty) {
                                          provider.toggleSelection(item.id);
                                        } else {
                                          final hasValidLocation =
                                              item.latitude != 0.0 ||
                                                  item.longitude != 0.0;
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
                                                      alert: item),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 1.0.h),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.red
                                                  .withValues(alpha: 0.11)
                                              : cardColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.red
                                                : (isDark
                                                    ? Colors.white12
                                                    : Colors.black12),
                                            width: isSelected ? 1.5 : 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                  alpha: isDark ? .18 : .07),
                                              blurRadius: 8,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            radius: 20,
                                            backgroundColor: AppColors.red
                                                .withValues(alpha: 0.12),
                                            child: isSelected
                                                ? Icon(Icons.check_circle,
                                                    color: AppColors.red)
                                                : Icon(Icons.notifications,
                                                    color: AppColors.red),
                                          ),
                                          title: Text(
                                            item.message,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppStyles.semiboldTextStyle(
                                                    context)
                                                .copyWith(fontSize: 13.5.sp),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.type,
                                                style:
                                                    AppStyles.regularTextStyle(
                                                            context)
                                                        .copyWith(
                                                  fontSize: 11.9.sp,
                                                  color: isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                              ),
                                              verticalSpace(height: 0.35.h),
                                              Text(
                                                item.time != null
                                                    ? '${item.time!.day}/${item.time!.month}/${item.time!.year} ${item.time!.hour}:${item.time!.minute.toString().padLeft(2, '0')}'
                                                    : l10n.notAvailableShort,
                                                style: AppStyles.lightTextStyle(
                                                        context)
                                                    .copyWith(
                                                  color: isDark
                                                      ? Colors.white60
                                                      : Colors.grey[600],
                                                  fontSize: 11.6.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 14.5,
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                              // Pagination loading indicator
                              if (provider.isLoadMore)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 0.h),
                                  child: Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: ConstantColor.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Consumer<AlertsProvider>(
        builder: (context, provider, _) {
          if (provider.selectedAlertIds.isEmpty) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.deleteAlerts),
                  content: Text(
                    l10n.deleteAlertsConfirmCount(
                      provider.selectedAlertIds.length,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        l10n.delete,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                final success = await provider.deleteSelectedAlerts();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.alertsDeletedSuccessfully),
                      backgroundColor: Colors.green,
                    ),
                  );
                  provider.fetchAlerts(isRefresh: true, context: context);
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.failedDeleteAlerts),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            backgroundColor: AppColors.red,
            icon: const Icon(Icons.delete),
            label: Text('${l10n.delete} (${provider.selectedAlertIds.length})'),
          );
        },
      ),
    );
  }
}
