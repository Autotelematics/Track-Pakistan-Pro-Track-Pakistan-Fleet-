import 'package:flutter/material.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:provider/provider.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_ui_tokens.dart';
import 'package:trackerapp/data/repositories/fcm_token_repository.dart';
import 'package:trackerapp/providers/motion_bottom_bar_provider.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/view/dashboard.dart';
import 'package:trackerapp/view/management/admin_management_screen.dart';
import 'package:trackerapp/view/management/manager_management_screen.dart';
import 'package:trackerapp/view/map_for_all_vehicles_screen.dart';
import 'package:trackerapp/view/notifications_screen.dart';
import 'package:trackerapp/view/setting_screens/settings.dart';
import 'package:trackerapp/view/vehicle_list_dashboard.dart';
import 'package:trackerapp/white_labeling/colors.dart';

class MotionBottomNavigationBar extends StatefulWidget {
  final bool? forceRegularUserTabs;
  final bool? showBackToAdminAction;

  const MotionBottomNavigationBar({
    super.key,
    this.forceRegularUserTabs,
    this.showBackToAdminAction,
  });

  @override
  State<MotionBottomNavigationBar> createState() =>
      _MotionBottomNavigationBarState();
}

class _MotionBottomNavigationBarState extends State<MotionBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late MotionTabBarController _tabController;
  late MotionBottomBarProvider _bottomBarProvider;
  late List<_NavTabItem> _tabs;

  bool get _forceRegularUserTabs => widget.forceRegularUserTabs ?? false;
  bool get _showBackToAdminAction => widget.showBackToAdminAction ?? false;

  Future<void> _handleBackToAdmin() async {
    final isImpersonating =
        MySharedPreferences.getBool(isImpersonatingAsUserKey);
    if (isImpersonating) {
      final adminToken =
          MySharedPreferences.getString(adminOriginalAuthTokenKey);
      final adminUserId = MySharedPreferences.getInt(adminOriginalUserIdKey);
      final adminEmail =
          MySharedPreferences.getString(adminOriginalUserEmailKey);
      final adminType = MySharedPreferences.getString(adminOriginalUserTypeKey);

      if (adminToken.trim().isNotEmpty) {
        await MySharedPreferences.setString(authTokenKey, adminToken);
      }
      if (adminUserId > 0) {
        await MySharedPreferences.setInt(userIdKey, adminUserId);
      }
      if (adminEmail.trim().isNotEmpty) {
        await MySharedPreferences.setString(userEmailKey, adminEmail);
      }
      if (adminType.trim().isNotEmpty) {
        await MySharedPreferences.setString(userTypeKey, adminType);
      } else {
        await MySharedPreferences.setString(userTypeKey, "admin");
      }

      await MySharedPreferences.setBool(isImpersonatingAsUserKey, false);
      await MySharedPreferences.removeKey(adminOriginalAuthTokenKey);
      await MySharedPreferences.removeKey(adminOriginalUserIdKey);
      await MySharedPreferences.removeKey(adminOriginalUserEmailKey);
      await MySharedPreferences.removeKey(adminOriginalUserTypeKey);
      try {
        await FcmTokenRepository().syncCurrentDeviceToken(force: true);
      } catch (_) {}
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  List<_NavTabItem> _tabsForUserType(String userType) {
    switch (userType) {
      case "admin":
        return const [
          _NavTabItem(
            label: "Management",
            icon: Icons.admin_panel_settings_outlined,
            screen: AdminManagementScreen(),
          ),
        ];
      case "manager":
        return const [
          _NavTabItem(
            label: "Management",
            icon: Icons.manage_accounts_outlined,
            screen: ManagerManagementScreen(),
          ),
        ];
      default:
        return const [
          _NavTabItem(
            label: "Status",
            icon: Icons.map_outlined,
            screen: NewVehicleListDashBoard(),
          ),
          _NavTabItem(
            label: "Map",
            icon: Icons.location_on_outlined,
            screen: MapForAllVehiclesScreen(),
          ),
          _NavTabItem(
            label: "Dashboard",
            icon: Icons.dashboard,
            screen: NewDashboard(),
          ),
          _NavTabItem(
            label: "Alerts",
            icon: Icons.notifications_none_outlined,
            screen: NewNotificationScreen(),
          ),
          _NavTabItem(
            label: "Settings",
            icon: Icons.settings_outlined,
            screen: ModernSettingsScreen(),
          ),
        ];
    }
  }

  int _safeTabIndex(int index, int length) {
    if (length <= 0) return 0;
    if (index < 0) return 0;
    if (index >= length) return length - 1;
    return index;
  }

  @override
  void initState() {
    super.initState();
    final userType =
        MySharedPreferences.getString(userTypeKey).trim().toLowerCase();
    _tabs = _tabsForUserType(_forceRegularUserTabs ? "user" : userType);
    final provider =
        Provider.of<MotionBottomBarProvider>(context, listen: false);
    _bottomBarProvider = provider;
    final initialIndex = _safeTabIndex(provider.currentIndex, _tabs.length);
    _tabController = MotionTabBarController(
      initialIndex: initialIndex,
      length: _tabs.length,
      vsync: this,
    );
    _bottomBarProvider.addListener(_handleProviderIndexChange);
  }

  @override
  void dispose() {
    _bottomBarProvider.removeListener(_handleProviderIndexChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleProviderIndexChange() {
    if (!mounted) return;
    final target = _safeTabIndex(_bottomBarProvider.currentIndex, _tabs.length);
    if (_tabController.index == target) {
      return;
    }
    if (_tabController.indexIsChanging) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_tabController.index != _bottomBarProvider.currentIndex) {
          _tabController.index = _bottomBarProvider.currentIndex;
        }
      });
      return;
    }
    _tabController.index = target;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MotionBottomBarProvider>();
    final selectedIndex = _safeTabIndex(provider.currentIndex, _tabs.length);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barHeight = AppUiTokens.adaptiveHeight(
      context,
      ratio: 0.068,
      min: 52,
      max: 58,
    );
    final tabSize = AppUiTokens.adaptiveHeight(
      context,
      ratio: 0.055,
      min: 42,
      max: 48,
    );
    final iconSize = AppUiTokens.adaptiveHeight(
      context,
      ratio: 0.0235,
      min: 18,
      max: 21,
    );
    final selectedIconSize = AppUiTokens.adaptiveHeight(
      context,
      ratio: 0.0245,
      min: 19,
      max: 22,
    );
    final labelSize = AppUiTokens.adaptiveHeight(
      context,
      ratio: 0.013,
      min: 10.5,
      max: 12,
    );
    final navBackground =
        isDark ? theme.cardColor : ConstantColor.secondaryColor;
    return Scaffold(
      floatingActionButton: _showBackToAdminAction
          ? FloatingActionButton.extended(
              onPressed: _handleBackToAdmin,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text(
                "Back to Admin",
                style: TextStyle(fontSize: 12),
              ),
            )
          : null,
      bottomNavigationBar: _tabs.length == 1
          ? null
          : MotionTabBar(
              controller: _tabController,
              initialSelectedTab: _tabs[selectedIndex].label,
              labelAlwaysVisible: true,
              labels: _tabs.map((tab) => tab.label).toList(growable: false),
              icons: _tabs.map((tab) => tab.icon).toList(growable: false),
              textStyle: TextStyle(
                color: AppColors.white,
                fontSize: labelSize,
                fontWeight: FontWeight.w500,
              ),
              tabIconSize: iconSize,
              tabBarHeight: barHeight,
              tabIconColor: AppColors.white,
              tabIconSelectedSize: selectedIconSize,
              tabSize: tabSize,
              tabSelectedColor: AppColors.white,
              tabIconSelectedColor: ConstantColor.primaryColor,
              tabBarColor: navBackground,
              onTabItemSelected: provider.setIndex,
            ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: _tabs.map((tab) => tab.screen).toList(growable: false),
      ),
    );
  }
}

class _NavTabItem {
  final String label;
  final IconData icon;
  final Widget screen;

  const _NavTabItem({
    required this.label,
    required this.icon,
    required this.screen,
  });
}
