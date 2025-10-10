import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/single_vehicle_analytics_provider.dart';
import 'package:trackerapp/view/new_notification_page.dart';
import 'package:trackerapp/view/new_analytics_page.dart';
import 'package:trackerapp/view/new_livetracking_page.dart' show NewLiveTrackingPage;
import 'package:trackerapp/view/new_report_type_page.dart' show ReportTypesScreen;
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_verticle_space.dart';

class SingleVehicleAnalytics extends StatefulWidget {
  const SingleVehicleAnalytics({super.key});

  @override
  State<SingleVehicleAnalytics> createState() => _SingleVehicleAnalyticsState();
}

class _SingleVehicleAnalyticsState extends State<SingleVehicleAnalytics>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => SingleVehicleAnalyticsProvider(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            Consumer<SingleVehicleAnalyticsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${provider.error}',
                          style: AppStyles.regularTextStyle(context),
                        ),
                        verticalSpace(height: 2.h),
                        ElevatedButton(
                          onPressed: () => provider.fetchData(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (provider.vehicleData != null) {
                  final data = provider.vehicleData!;
                  return Column(
                    children: [
                      // Header Section
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.purple, AppColors.blueCyanWithOpacity],
                          ),
                        ),
                        padding: EdgeInsets.only(top: 5.5.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: AppColors.white,
                                      size: 3.5.h,
                                    ),
                                  ),
                                  horizontalSpace(width: 3.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['plateNumber'],
                                        style: AppStyles.vehicleTitle(context).copyWith(
                                          color: AppColors.white,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        data['driverName'],
                                        style: AppStyles.vehicleTitle(context).copyWith(
                                          color: AppColors.white,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            verticalSpace(height: 2.h),
                            // TabBar
                            SizedBox(
                              height: 4.h,
                              child: TabBar(
                                padding: EdgeInsets.zero,
                                indicatorSize: TabBarIndicatorSize.tab,
                                tabAlignment: TabAlignment.fill,
                                labelPadding: EdgeInsets.zero,
                                isScrollable: false,
                                indicatorPadding: EdgeInsets.zero,
                                dividerHeight: 0,
                                dividerColor: Colors.transparent,
                                indicator: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    topRight: Radius.circular(5),
                                  ),
                                  border: Border(
                                    top: BorderSide(color: AppColors.white, width: 2),
                                    left: BorderSide(color: AppColors.white, width: 2),
                                    right: BorderSide(color: AppColors.white, width: 2),
                                    bottom: BorderSide(color: AppColors.white, width: 3),
                                  ),
                                ),
                                controller: _tabController,
                                labelStyle: AppStyles.statusTitle(context).copyWith(
                                  fontSize: 15.sp,
                                  color: AppColors.black,
                                ),
                                unselectedLabelStyle: AppStyles.statusTitle(context).copyWith(
                                  fontSize: 15.sp,
                                  color: AppColors.white,
                                ),
                                tabs: const [
                                  Tab(text: "Live"),
                                  Tab(text: "Analytics"),
                                  Tab(text: "Report"),
                                  Tab(text: "History"),
                                  Tab(text: "Alerts"),
                                ],
                                onTap: (index) {
                                  provider.setTabIndex(index);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // TabBarView
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            const KeepAliveWrapper(child: NewLiveTrackingPage()),
                            const KeepAliveWrapper(child: AnalyticsPage()),
                            const KeepAliveWrapper(child: ReportTypesScreen()),
                            const KeepAliveWrapper(
                              child: Center(
                                child: Text(
                                  "History",
                                ),
                                ),
                              ),

                            const KeepAliveWrapper(child: VehicleEventsScreen()),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: Text(
                      'No data available',
                      style: AppStyles.regularTextStyle(context),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget to keep TabBarView children alive
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}