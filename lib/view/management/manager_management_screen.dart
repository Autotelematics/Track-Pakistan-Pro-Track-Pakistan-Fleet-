import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/admin_status_model.dart';
import 'package:trackerapp/data/repositories/fcm_token_repository.dart';
import 'package:trackerapp/data/repositories/admin_status_repository.dart';
import 'package:trackerapp/utils/motion_bottom_navigation_bar.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/view/management/admin_push_notification_history_screen.dart';
import 'package:trackerapp/view/management/admin_push_notification_screen.dart';
import 'package:trackerapp/view/management/admin_user_list_screen.dart';
import 'package:trackerapp/widgets/management/manager/manager_management_header.dart';
import 'package:trackerapp/widgets/management/manager/manager_module_tile.dart';
import 'package:trackerapp/widgets/management/admin/admin_status_count_card.dart';
import 'package:trackerapp/widgets/management/admin/admin_user_status_count_card.dart';

class ManagerManagementScreen extends StatefulWidget {
  const ManagerManagementScreen({super.key});

  @override
  State<ManagerManagementScreen> createState() =>
      _ManagerManagementScreenState();
}

class _ManagerManagementScreenState extends State<ManagerManagementScreen> {
  final AdminStatusRepository _adminStatusRepository = AdminStatusRepository();
  AdminStatusModel? _adminStatus;
  bool _isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    _loadManagerStatus();
    _syncFcmTokenForManager();
  }

  Future<void> _syncFcmTokenForManager() async {
    try {
      await FcmTokenRepository().syncCurrentDeviceToken(force: true);
    } catch (_) {}
  }

  Future<void> _loadManagerStatus() async {
    final token = MySharedPreferences.getString(authTokenKey).trim();
    final model = await _adminStatusRepository.getAdminStatus(token: token);
    if (!mounted) return;
    setState(() {
      _adminStatus = model;
      _isLoadingStatus = false;
    });
  }

  void _openUserList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminUserListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userEmail = MySharedPreferences.getString(userEmailKey).trim();
    final userType = MySharedPreferences.getString(userTypeKey).trim();
    final hour = DateTime.now().hour;
    final greeting = hour >= 5 && hour < 12
        ? "Good Morning"
        : hour >= 12 && hour < 17
            ? "Good Afternoon"
            : hour >= 17 && hour < 20
                ? "Good Evening"
                : "Good Night";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  colors: [theme.scaffoldBackgroundColor, theme.cardColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : LinearGradient(
                  colors: [AppColors.white, AppColors.scaffoldBg],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              ManagerManagementHeader(
                userEmail: userEmail,
                userType: userType,
                greeting: greeting,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Manager Management",
                          style: AppStyles.boldTextStyle(context).copyWith(
                            fontSize: 18.sp,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MotionBottomNavigationBar(
                                  forceRegularUserTabs: true,
                                  showBackToAdminAction: true,
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.2.w,
                              vertical: .35.h,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.open_in_new_rounded, size: 14),
                          label: Text(
                            "Open User View",
                            style: TextStyle(fontSize: 11.2.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: .6.h),
                    Text(
                      "Centralized controls for team and operations management.",
                      style: AppStyles.regularTextStyle(context),
                    ),
                    SizedBox(height: 1.3.h),
                    if (_isLoadingStatus)
                      const Center(child: CircularProgressIndicator())
                    else if (_adminStatus != null) ...[
                      AdminStatusCountCard(status: _adminStatus!.deviceStatus),
                      SizedBox(height: 1.2.h),
                      AdminUserStatusCountCard(
                        status: _adminStatus!.usersStatus,
                      ),
                    ] else
                      Container(
                        padding: EdgeInsets.all(3.2.w),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          "Unable to load manager status.",
                          style: AppStyles.regularTextStyle(context),
                        ),
                      ),
                    SizedBox(height: 1.8.h),
                    Text(
                      "Modules",
                      style: AppStyles.semiboldTextStyle(context),
                    ),
                    SizedBox(height: 1.h),
                    GridView.count(
                      padding: EdgeInsets.zero,
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 1.2.h,
                      crossAxisSpacing: 3.w,
                      childAspectRatio: 1.28,
                      children: [
                        _ManagerFirebaseNotificationModuleCard(
                          onShowPrevious: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AdminPushNotificationHistoryScreen(),
                              ),
                            );
                          },
                          onSendNew: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AdminPushNotificationScreen(),
                              ),
                            );
                          },
                        ),
                        ManagerModuleTile(
                          title: "Users List",
                          icon: Icons.people_alt_outlined,
                          iconColor: Colors.indigo.shade500,
                          iconBackgroundColor: Colors.indigo.shade50,
                          centerButtonText: "View Users",
                          centerButtonBackgroundColor: Colors.amber.shade100,
                          centerButtonTextColor: Colors.orange.shade900,
                          centerButtonFontSizeSp: 12.sp,
                          centerButtonVerticalPaddingH: 1.5.h,
                          onCenterButtonTap: () => _openUserList(context),
                          onTap: () => _openUserList(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManagerFirebaseNotificationModuleCard extends StatelessWidget {
  final VoidCallback onShowPrevious;
  final VoidCallback onSendNew;

  const _ManagerFirebaseNotificationModuleCard({
    required this.onShowPrevious,
    required this.onSendNew,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(3.2.w, 1.6.w, 3.2.w, 2.2.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: .10),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: .4.h,
            right: .5.w,
            child: Container(
              padding: EdgeInsets.all(2.2.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                color: Colors.red.shade400,
                size: 20.sp,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 33.w,
                child: Text(
                  "Send Firebase Notification",
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 14.5.sp,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onShowPrevious,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 1.55.h),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Center(
                          child: Text(
                            "Show Previous",
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 1.7.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: onSendNew,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 1.55.h),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Center(
                          child: Text(
                            "Send New",
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
