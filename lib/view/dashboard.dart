import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/dashboard_provider.dart';
import 'package:trackerapp/widgets/dashboard_widgets/alert_grid.dart';
import 'package:trackerapp/widgets/dashboard_widgets/distance_travelled_card.dart';
import 'package:trackerapp/widgets/dashboard_widgets/fuel_price_card.dart';
import 'package:trackerapp/widgets/dashboard_widgets/header_widget.dart';
import 'package:trackerapp/widgets/dashboard_widgets/maintenance_card.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
class NewDashboard extends StatefulWidget {
  const NewDashboard({super.key});

  @override
  State<NewDashboard> createState() => _NewDashboardState();
}

class _NewDashboardState extends State<NewDashboard> {
  late final DashboardProvider _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = Provider.of<DashboardProvider>(context, listen: false);
      _provider.getDashboardProvider();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const DashboardShimmer();
          }

          // Error State
          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 40.sp,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    verticalSpace(height: 2.h),
                    Text(
                      'Error: ${provider.error}',
                      textAlign: TextAlign.center,
                      style: AppStyles.regularTextStyle(context).copyWith(
                        fontSize: 16.sp,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    verticalSpace(height: 2.h),
                    ElevatedButton(
                      onPressed: provider.getDashboardProvider,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Empty State
          if (provider.dashboardData == null || provider.dashboardModel == null) {
            return EmptyStateWidget(
              onRetry: provider.getDashboardProvider,
            );
          }

          // Success State
          final data = provider.dashboardData!;
          final data1 = provider.dashboardModel!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              HeaderWidget(
                data: data,
                currentTime: provider.getTimePeriod(),
                data1: data1,
              ),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      AlertGrid(data: data1),
                      verticalSpace(height: 2.h),
                      MaintenanceCard(data: data1),
                      verticalSpace(height: 2.h),
                      FuelPriceCard(data: data1),
                      verticalSpace(height: 2.h),
                      DistanceTravelledCard(data: data),
                      verticalSpace(height: 2.h),

                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Shimmer Widget
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpace(height: 6.h),
          // Header Placeholder
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profile Avatar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  height: 5.h,
                  width: 5.h,
                ),

                // Settings + Notification
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                       shape: BoxShape.circle,
                      ),
                      height: 2.6.h,
                      width: 2.6.h,
                    ),
                    horizontalSpace(width: 5.w),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      height: 2.6.h,
                      width: 2.6.h,
                    ),                  ],
                ),

              ],
            ),
          ),

          // Greeting
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w,vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            height: 2.6.h,
            width: 25.w,
          ),
          Container(
            height: 20.h,
            margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Alert Grid Placeholder
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: GridView.count(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.8,
                      children: List.generate(
                        6,
                            (index) => Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  verticalSpace(height: 2.h),
                  // Maintenance Card Placeholder
                  Container(
                    height: 15.h,
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  verticalSpace(height: 2.h),
                  // Distance Travelled Card Placeholder
                  Container(
                    height: 20.h,
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  verticalSpace(height: 2.h),
                  // Fleet Alerts Card Placeholder
                  Container(
                    height: 25.h,
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  verticalSpace(height: 5.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Empty State Widget
class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const EmptyStateWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 40.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            verticalSpace(height: 2.h),
            Text(
              'No data available. Please try again.',
              textAlign: TextAlign.center,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            verticalSpace(height: 2.h),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}