import 'package:flutter/material.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/providers/motion_bottom_bar_provider.dart';
import 'package:trackerapp/view/dashboard.dart';
import 'package:trackerapp/view/map_for_all_vehicles_screen.dart';
import 'package:trackerapp/view/notifications_screen.dart';
import 'package:trackerapp/view/setting_screens/settings.dart';
import 'package:trackerapp/view/vehicle_list_dashboard.dart';
import 'package:trackerapp/white_labeling/colors.dart';
class MotionBottomNavigationBar extends StatefulWidget {
  const MotionBottomNavigationBar({super.key});

  @override
  State<MotionBottomNavigationBar> createState() =>
      _MotionBottomNavigationBarState();
}

class _MotionBottomNavigationBarState extends State<MotionBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late MotionTabBarController _tabController;

  @override
  void initState() {
    super.initState();
    final provider =
    Provider.of<MotionBottomBarProvider>(context, listen: false);
    _tabController = MotionTabBarController(
      initialIndex: provider.currentIndex,
      length: 5,
      vsync: this,
    );

    // Listen for tab index changes inside the controller
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        final provider = context.read<MotionBottomBarProvider>();
        if (provider.currentIndex != _tabController.index) {
          provider.setIndex(_tabController.index);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MotionBottomBarProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (_tabController.index != provider.currentIndex) {
      _tabController.index = provider.currentIndex;
    }

    return Scaffold(
      bottomNavigationBar: MotionTabBar(
        controller: _tabController,
        initialSelectedTab: "Dashboard",
        labelAlwaysVisible: true,
        labels: const [
          "Status",
          "Map",
          "Dashboard",
          "Alerts",
          "Settings",
        ],
        icons: const [
          Icons.map_outlined,
          Icons.location_on_outlined,
          Icons.dashboard,
          Icons.notifications_none_outlined,
          Icons.settings_outlined,
        ],
        textStyle: TextStyle(
          color: AppColors.white,
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
        tabIconSize: 21.sp,
        tabBarHeight: 6.5.h,
        tabIconColor: AppColors.white,
        tabIconSelectedSize: 22.sp,
        tabSize: 6.h,
        tabSelectedColor: AppColors.white,
        tabIconSelectedColor: ConstantColor.primaryColor,
        tabBarColor:
        isDark ? theme.cardColor : ConstantColor.secondaryColor,
        onTabItemSelected: (index) {
          provider.setIndex(index);
        },
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children:  [
          NewVehicleListDashBoard(),
          MapForAllVehiclesScreen(),
          NewDashboard(),
          NewNotificationScreen(),
          ModernSettingsScreen(),
        ],
      ),
    );
  }
}
