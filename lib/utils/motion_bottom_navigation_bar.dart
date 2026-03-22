import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_ui_tokens.dart';
import 'package:trackerapp/data/repositories/fcm_token_repository.dart';
import 'package:trackerapp/providers/motion_bottom_bar_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
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
  late TabController _tabController;
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

  List<_NavTabItem> _tabsForUserType(String userType, BuildContext context) {
    final l10n = context.l10n;
    switch (userType) {
      case "admin":
        return [
          _NavTabItem(
            label: l10n.managementTab,
            icon: Icons.admin_panel_settings_outlined,
            screen: const AdminManagementScreen(),
          ),
        ];
      case "manager":
        return [
          _NavTabItem(
            label: l10n.managementTab,
            icon: Icons.manage_accounts_outlined,
            screen: const ManagerManagementScreen(),
          ),
        ];
      default:
        return [
          _NavTabItem(
            label: l10n.statusTab,
            icon: Icons.map_outlined,
            screen: const NewVehicleListDashBoard(),
          ),
          _NavTabItem(
            label: l10n.mapTab,
            icon: Icons.location_on_outlined,
            screen: const MapForAllVehiclesScreen(),
          ),
          _NavTabItem(
            label: l10n.dashboardTab,
            icon: Icons.dashboard,
            screen: const NewDashboard(),
          ),
          _NavTabItem(
            label: l10n.alertsTab,
            icon: Icons.notifications_none_outlined,
            screen: const NewNotificationScreen(),
          ),
          _NavTabItem(
            label: l10n.settingsTab,
            icon: Icons.settings_outlined,
            screen: const ModernSettingsScreen(),
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
    final provider =
        Provider.of<MotionBottomBarProvider>(context, listen: false);
    _bottomBarProvider = provider;
    _tabs = const [];
    final initialIndex = _safeTabIndex(provider.currentIndex, 5);
    _tabController = TabController(
      initialIndex: initialIndex,
      length: 5,
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
        if (_tabController.index != target) {
          _tabController.index = target;
        }
      });
      return;
    }
    _tabController.index = target;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MotionBottomBarProvider>();
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final userType =
        MySharedPreferences.getString(userTypeKey).trim().toLowerCase();
    final nextTabs =
        _tabsForUserType(_forceRegularUserTabs ? "user" : userType, context);
    if (_tabs.length != nextTabs.length || !_sameTabLabels(_tabs, nextTabs)) {
      _tabs = nextTabs;
      final safeIndex = _safeTabIndex(provider.currentIndex, _tabs.length);
      if (_tabController.length != _tabs.length) {
        _tabController.dispose();
        _tabController = TabController(
          initialIndex: safeIndex,
          length: _tabs.length,
          vsync: this,
        );
      } else if (_tabController.index != safeIndex) {
        _tabController.index = safeIndex;
      }
    }
    final displayedTabs = isRtl ? _tabs.reversed.toList() : List.of(_tabs);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barHeight = AppUiTokens.adaptiveHeight(
      context,
      ratio: 0.068,
      min: 52,
      max: 58,
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
              label: Text(
                context.l10n.backToAdmin,
                style: TextStyle(fontSize: 12),
              ),
            )
          : null,
      bottomNavigationBar: _tabs.length == 1
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                decoration: BoxDecoration(
                  color: navBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? .22 : .10),
                      blurRadius: 8,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  children: displayedTabs.map((tab) {
                    final logicalIndex = _tabs.indexOf(tab);
                    final isSelected = provider.currentIndex == logicalIndex;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => provider.setIndex(logicalIndex),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            height: barHeight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  tab.icon,
                                  size:
                                      isSelected ? selectedIconSize : iconSize,
                                  color: isSelected
                                      ? ConstantColor.primaryColor
                                      : AppColors.white,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tab.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected
                                        ? ConstantColor.primaryColor
                                        : AppColors.white,
                                    fontSize: labelSize,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(growable: false),
                ),
              ),
            ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: _tabs.map((tab) => tab.screen).toList(growable: false),
      ),
    );
  }

  bool _sameTabLabels(List<_NavTabItem> current, List<_NavTabItem> next) {
    if (current.length != next.length) {
      return false;
    }
    for (var i = 0; i < current.length; i++) {
      if (current[i].label != next[i].label) {
        return false;
      }
    }
    return true;
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
