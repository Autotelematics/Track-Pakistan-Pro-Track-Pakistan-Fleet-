import 'package:flutter/material.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/providers/motion_bottom_bar_provider.dart';
import 'package:trackerapp/view/dashboard.dart';
import 'package:trackerapp/view/new_notification_screen.dart';
import 'package:trackerapp/view/settings.dart';
import 'package:trackerapp/view/vehicle_list_dashboard.dart';
class MotionBottomNavigationBar extends StatefulWidget {
  const MotionBottomNavigationBar({super.key});

  @override
  State<MotionBottomNavigationBar> createState() => _MotionBottomNavigationBarState();
}

class _MotionBottomNavigationBarState extends State<MotionBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  MotionTabBarController? _tabController;
  late final MotionBottomBarProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<MotionBottomBarProvider>(context, listen: false);
    _tabController = MotionTabBarController(
      initialIndex: _provider.currentIndex,
      length: 5,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentIndex = context.watch<MotionBottomBarProvider>().currentIndex;

    // Sync provider index with tab controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tabController != null && _tabController!.index != currentIndex) {
        _tabController!.index = currentIndex;
      }
    });

    if (_tabController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      bottomNavigationBar: MotionTabBar(
        controller: _tabController!,
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
        tabBarHeight: 7.5.h,
        tabIconColor: AppColors.white,
        tabIconSelectedSize: 22.sp,
        tabSize: 6.5.h,
        tabSelectedColor: AppColors.white,
        tabIconSelectedColor:AppColors.primaryColor,
        tabBarColor: isDark?theme.cardColor:AppColors.secondaryColor,
        onTabItemSelected: (index) {
          _provider.setIndex(index);
        },
      ),

      // Body - Tab Views
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController!,
        children: [
          const NewVehicleListDashBoard(),
          const Center(child: Text("Map")),
          const NewDashboard(),
          NewNotificationScreen(),
          const ModernSettingsScreen(),
        ],
      ),
    );
  }
}