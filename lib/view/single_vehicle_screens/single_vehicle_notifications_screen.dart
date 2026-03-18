import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/app/theme/responsive_scale.dart';
import 'package:trackerapp/providers/alerts_provider.dart';
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

  List<Map<String, dynamic>> _getAlertCategories(Map<String, int> counts) {
    return [
      {
        'icon': Icons.speed,
        'name': 'Over Speed',
        'unit': 'Times',
        'value': counts['Over Speed'] ?? 0,
        'bgColor': const Color(0xFFFFC107),
      },
      {
        'icon': Icons.timer_outlined,
        'name': 'Idle Duration',
        'unit': 'Times',
        'value': counts['Idle Duration'] ?? 0,
        'bgColor': const Color(0xFFFF9800),
      },
      {
        'icon': Icons.power_settings_new,
        'name': 'Ignition duration',
        'unit': 'Times',
        'value': counts['Ignition duration'] ?? 0,
        'bgColor': const Color(0xFFEF5350),
      },
      {
        'icon': Icons.directions_car,
        'name': 'Move Start',
        'unit': 'Times',
        'value': counts['Move Start'] ?? 0,
        'bgColor': const Color(0xFF4CAF50),
      },
      {
        'icon': Icons.signal_wifi_off,
        'name': 'Offline duration',
        'unit': 'Times',
        'value': counts['Offline duration'] ?? 0,
        'bgColor': const Color(0xFF009688),
      },
      {
        'icon': Icons.local_parking,
        'name': 'Over Parking',
        'unit': 'Times',
        'value': counts['Over Parking'] ?? 0,
        'bgColor': const Color(0xFF6A1B9A),
      },
    ];
  }

  Widget _buildEmptyState() {
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
            'No Alerts Found',
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: 18.sp,
              color: Colors.grey.shade600,
            ),
          ),
          verticalSpace(height: 1.h),
          Text(
            selectedCategory != null
                ? 'No alerts for selected category'
                : searchController.text.isNotEmpty
                    ? 'No alerts match your search'
                    : 'No alerts available for this vehicle',
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
              label: const Text('Show All Alerts'),
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
            'Oops! Something went wrong',
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
            label: const Text('Try Again'),
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
                  final alerts = _getAlertCategories(provider.alertTypeCounts);
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
                          labelText: "Search Notification",
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
                        labelText: "Search Notification",
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
                        "Alerts Category",
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
                                      selectedCategory == item['name'];
                                  final tileColor = item['bgColor'] as Color;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (selectedCategory == item['name']) {
                                          selectedCategory = null;
                                          provider.setAlertTypeFilter(null);
                                        } else {
                                          selectedCategory =
                                              item['name'] as String;
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
                                          'Loading alerts...',
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
                                              const SnackBar(
                                                content: Text(
                                                  'Location is not available for this alert',
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
                                            item.type,
                                            style: AppStyles.semiboldTextStyle(
                                                    context)
                                                .copyWith(fontSize: 13.5.sp),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.message,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    AppStyles.regularTextStyle(
                                                            context)
                                                        .copyWith(
                                                            fontSize: 11.9.sp),
                                              ),
                                              verticalSpace(height: 0.35.h),
                                              Text(
                                                item.time != null
                                                    ? '${item.time!.day}/${item.time!.month}/${item.time!.year} ${item.time!.hour}:${item.time!.minute.toString().padLeft(2, '0')}'
                                                    : 'N/A',
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
                  title: const Text('Delete Alerts'),
                  content: Text(
                    'Are you sure you want to delete ${provider.selectedAlertIds.length} alert(s)?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                final success = await provider.deleteSelectedAlerts();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alerts deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  provider.fetchAlerts(isRefresh: true, context: context);
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete alerts'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            backgroundColor: AppColors.red,
            icon: const Icon(Icons.delete),
            label: Text('Delete (${provider.selectedAlertIds.length})'),
          );
        },
      ),
    );
  }
}
