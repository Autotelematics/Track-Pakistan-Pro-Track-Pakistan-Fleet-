import 'package:flutter/material.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/motion_bottom_bar_provider.dart';
import 'package:trackerapp/view/new_dashboard.dart';
import 'package:trackerapp/view/new_vehicle_list_dashboard.dart';
import 'package:trackerapp/view/settings.dart';

import '../view/new_notification_page.dart' show VehicleEventsScreen;

class MotionBottomNavigationBar extends StatefulWidget {
  const MotionBottomNavigationBar({super.key});

  @override
  State<MotionBottomNavigationBar> createState() =>
      _MotionBottomNavigationBarState();
}

class _MotionBottomNavigationBarState extends State<MotionBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  MotionTabBarController? _motionTabBarController;
  late MotionBottomBarProvider _motionBottomBarProvider;

  @override
  void initState() {
    super.initState();
    _motionBottomBarProvider =
        Provider.of<MotionBottomBarProvider>(context, listen: false);

    _motionTabBarController =
        MotionTabBarController(initialIndex: _motionBottomBarProvider.currentIndex, length: 5, vsync: this);
  }

  @override
  void dispose() {
    _motionTabBarController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<MotionBottomBarProvider>().currentIndex;

    // ✅ Safely update after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_motionTabBarController != null &&
          _motionTabBarController!.index != currentIndex) {
        _motionTabBarController!.index = currentIndex;
      }
    });

    // ✅ If controller not yet ready, show loader instead of crashing
    if (_motionTabBarController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.purple, AppColors.blueCyanWithOpacity.withOpacity(0.1)],
          )),
        child:  MotionTabBar(
          controller: _motionTabBarController!,
          initialSelectedTab: "Dashboard",
          labelAlwaysVisible: true,
          labels: const ["Status", "Map", "Dashboard", "Alerts", "Settings"],
          icons: const [
            Icons.map_outlined,
            Icons.location_on_outlined,
            Icons.dashboard,
            Icons.notifications_none_outlined,
            Icons.settings_outlined,
          ],
          tabSize: 6.h,
          tabBarHeight: 7.h,
          textStyle: AppStyles.lightTextStyle(context).copyWith(
            color: AppColors.white,
            height: 0.9
          ),
          tabIconSize: 22.sp,
          tabIconColor: AppColors.white,
          tabIconSelectedSize: 22.sp,
          tabSelectedColor: AppColors.white,
          tabIconSelectedColor:  AppColors.blueCyan,
          tabBarColor:  AppColors.blueCyanWithOpacity,

          onTabItemSelected: (int value) {
            _motionBottomBarProvider.setIndex(value);
          },
        ),
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _motionTabBarController!,
        children: const [
          NewVehicleListDashBoard(),
          Center(child: Text("Map")),
          NewDashboard(),
          VehicleEventsScreen(),
          SettingScreen(),
        ],
      ),
    );
  }
}
