import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_alerts_list_model.dart';
import 'package:trackerapp/providers/alerts_provider.dart';
import 'package:trackerapp/utils/top_curve_bezier.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/search_textfield.dart';

class NewNotificationScreen extends StatefulWidget {
  const NewNotificationScreen({super.key});

  @override
  State<NewNotificationScreen> createState() => _NewNotificationScreenState();
}

class _NewNotificationScreenState extends State<NewNotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // First time fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AlertsProvider>(context, listen: false);
      if (provider.model == null) {
        provider.fetchAlerts(isRefresh: true, context: context);
      }
    });
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

  // Shimmer exactly like Autotel Lite
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
            leading: const CircleAvatar(radius: 20, backgroundColor: Colors.white),
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final onSurface = theme.colorScheme.onSurface;

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
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              verticalSpace(height: 6.h),

              // Filter Bar - Real Data from Provider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Consumer<AlertsProvider>(
                  builder: (context, provider, child) {
                    return SearchAndFilterBar(
                      alertTypes: provider.alertTypeList,
                      vehicles: ["All Vehicles"],
                      alertCounts: provider.alertTypeCounts,
                      onVehicleChanged: (val) {
                      },
                      onAlertTypeChanged: (val) {
                        provider.setAlertTypeFilter(val);
                        provider.fetchAlerts(isRefresh: true, context: context);
                      },
                      onSearchPressed: () {
                        provider.fetchAlerts(isRefresh: true, context: context);
                      },
                    );
                  },
                ),
              ),

              verticalSpace(height: 2.h),

              // Main Curved Area
              Expanded(
                child: ClipPath(
                  clipper: TopCurveClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? LinearGradient(
                        colors: [theme.scaffoldBackgroundColor, theme.scaffoldBackgroundColor],
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
                        verticalSpace(height: 3.h),

                        // Title + Delete Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Notifications",
                              style: AppStyles.boldTextStyle(context).copyWith(
                                color: onSurface,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Consumer<AlertsProvider>(
                              builder: (context, provider, child) {
                                if (provider.selectedAlertIds.isNotEmpty) {
                                  return IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text("Delete Alerts"),
                                          content: Text(
                                              "Delete ${provider.selectedAlertIds.length} alert(s)?"),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        final success = await provider.deleteSelectedAlerts();
                                        if (context.mounted && success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Alerts deleted successfully")),
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

                        verticalSpace(height: 2.h),

                        // Real Alerts List
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: Consumer<AlertsProvider>(
                              builder: (context, provider, child) {
                                // First time full loading
                                if (provider.isLoading && provider.model == null) {
                                  return _buildShimmerList();
                                }

                                // Error
                                if (provider.errorMessage != null && provider.model == null) {
                                  return Center(child: Text(provider.errorMessage!));
                                }

                                final items = provider.model?.items ?? [];

                                if (items.isEmpty) {
                                  return const Center(child: Text("No alerts found"));
                                }

                                return ListView.builder(
                                  controller: _scrollController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: items.length + (provider.isLoadMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == items.length) {
                                      return const Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    }

                                    final Item alert = items[index];
                                    final bool isSelected = provider.selectedAlertIds.contains(alert.id);

                                    return GestureDetector(
                                      onLongPress: () => provider.toggleSelection(alert.id),
                                      onTap: () {
                                        if (provider.selectedAlertIds.isNotEmpty) {
                                          provider.toggleSelection(alert.id);
                                        } else {
                                          // Navigate to detail/map
                                          // Navigator.pushNamed(context, '/event-detail', arguments: alert);
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        margin: EdgeInsets.only(bottom: 1.5.h),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(12),
                                          border: isSelected
                                              ? Border.all(color: Colors.red, width: 2)
                                              : null,
                                          boxShadow: [
                                            BoxShadow(
                                              color: isDark
                                                  ? Colors.black.withOpacity(0.4)
                                                  : Colors.black.withOpacity(0.08),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            radius: 20,
                                            backgroundColor: isDark
                                                ? Colors.redAccent.withOpacity(0.15)
                                                : Colors.redAccent.withOpacity(0.1),
                                            child: Icon(
                                              isSelected ? Icons.check_circle : Icons.notifications_active_outlined,
                                              color: isSelected ? Colors.green : Colors.redAccent,
                                            ),
                                          ),
                                          title: Text(
                                            alert.deviceName,
                                            style: AppStyles.regularTextStyle(context).copyWith(
                                              color: onSurface,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                alert.message,
                                                style: TextStyle(color: Colors.redAccent, fontSize: 15.sp),
                                              ),
                                              verticalSpace(height: 0.3.h),
                                              Text(
                                                alert.time?.toLocal().toString().split('.').first ?? "No time",
                                                style: AppStyles.lightTextStyle(context).copyWith(
                                                  color: onSurface.withOpacity(0.6),
                                                  fontSize: 13.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: Icon(
                                            Icons.arrow_forward_ios,
                                            color: onSurface.withOpacity(0.6),
                                            size: 18,
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