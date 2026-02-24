import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_analytics_screen.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_report_type_screen.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_notifications_screen.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_info_screen.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_history_screen.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_tracking_screen.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';

class SingleVehicleAnalytics extends StatefulWidget {
  final List<Sensor> sensors;
  final int deviceId;
  final String deviceName;

  const SingleVehicleAnalytics({
    super.key,
    required this.deviceId,
    required this.deviceName, required this.sensors,
  });

  @override
  State<SingleVehicleAnalytics> createState() => _SingleVehicleAnalyticsState();
}

class _SingleVehicleAnalyticsState extends State<SingleVehicleAnalytics>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, dynamic> vehicleData = {
    'driverName': 'John Doe',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.h),
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                 KeepAliveWrapper(child: VehicleTrackingScreen(deviceId: widget.deviceId,)),
                 KeepAliveWrapper(child: SingleVehicleAnalyticsScreen(deviceId: widget.deviceId)),
                 KeepAliveWrapper(child: SingleReportTypesScreen(deviceId: widget.deviceId, deviceTitle: widget.deviceName,)),
                 KeepAliveWrapper(
                  child: SingleVehicleHistoryScreen(deviceId: widget.deviceId, deviceTitle: widget.deviceName,),
                ),
                 KeepAliveWrapper(child: SingleVehicleAlertScreen(deviceId:  widget.deviceId,)),
                 KeepAliveWrapper(child: SingleVehicleInfoScreen(sensors: widget.sensors, deviceId:widget.deviceId ,)),
              ],
            ),
          ),

          // Header Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 19.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ConstantColor.secondaryColor,
                    ConstantColor.secondaryColor,
                    ConstantColor.secondaryColor.withOpacity(0.5),
                    ConstantColor.secondaryColor.withOpacity(0.5),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(38),
                  bottomRight: Radius.circular(38),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    offset: const Offset(0, 4),
                    blurRadius: 20,
                  ),
                ],
              ),
              padding: EdgeInsets.only(top: 7.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                        size: 3.h,
                      ),
                    ),
                    horizontalSpace(width: 6.w),
                    Text(
                      widget.deviceName.length > 20
                          ? "${widget.deviceName.substring(0, 20)}..."
                          : widget.deviceName,
                      style: AppStyles.vehicleTitle(context).copyWith(
                        color: AppColors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // TabBar (Placed over header)
          Positioned(
            top: 14.h,
            left: 3.w,
            right: 3.w,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(15.px),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    offset: const Offset(0, 4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                padding: EdgeInsets.symmetric(vertical: 0.5.h,horizontal: 1.w),
                indicatorSize: TabBarIndicatorSize.tab,
                tabAlignment: TabAlignment.fill,
                labelPadding: EdgeInsets.zero,
                isScrollable: false,
                dividerHeight: 0,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: ConstantColor.primaryColor,
                  borderRadius: BorderRadius.circular(10.px),
                  border: Border(
                    top: BorderSide(color: AppColors.white, width: 2),
                    left: BorderSide(color: AppColors.white, width: 2),
                    right: BorderSide(color: AppColors.white, width: 2),
                    bottom: BorderSide(color: AppColors.white, width: 3),
                  ),
                ),
                labelStyle: AppStyles.statusTitle(context).copyWith(
                  fontSize: 15.sp,
                  color: AppColors.white,
                ),
                unselectedLabelStyle: AppStyles.statusTitle(context).copyWith(
                  fontSize: 15.sp,
                  color: AppColors.black,
                ),
                tabs: const [
                  Tab(icon: Icon(Icons.location_on_outlined), text: "Live"),
                  Tab(icon: Icon(Icons.bar_chart), text: "Analytic"),
                  Tab(icon: Icon(Icons.description_outlined), text: "Report"),
                  Tab(icon: Icon(Icons.access_time), text: "History"),
                  Tab(icon: Icon(Icons.notifications_none), text: "Alerts"),
                  Tab(icon: Icon(Icons.info_outline_rounded), text: "Info"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
