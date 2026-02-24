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
import 'package:trackerapp/widgets/vehicle_list_widgets/top_speed_card.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _provider = Provider.of<DashboardProvider>(context, listen: false);
      await Future.wait([
        _provider.getDashboardProvider(),
        _provider.getDashboardHistoryProvider(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading ||
              provider.dashboardData == null ||
              provider.dashboardModel == null ||
              provider.dashboardHistoryModel == null) {
            return const _DashboardShimmer();
          }
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
                      onPressed: () async {
                        await Future.wait([
                          provider.getDashboardProvider(),
                          provider.getDashboardHistoryProvider(),
                        ]);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Success State
          final data1 = provider.dashboardModel!;
          final historyData = provider.dashboardHistoryModel!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderWidget(
                currentTime: provider.getTimePeriod(),
                data1: data1,
              ),
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
                      DistanceTravelledCard(historyData: historyData),
                      verticalSpace(height: 2.h),
                      TopSpeedCard(historyData: historyData),
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
class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer({super.key});

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
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Greeting
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
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
                  // Fuel Price Card Placeholder
                  Container(
                    height: 15.h,
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
