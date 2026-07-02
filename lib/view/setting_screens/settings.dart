import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/data/repositories/fcm_token_repository.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/utils/local_notification_service.dart';
import 'package:trackerapp/utils/logout_popup.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/view/auth_screens/login_screen.dart';
import 'package:trackerapp/view/setting_screens/manager_chat_screen.dart';
import 'package:trackerapp/widgets/settings_widgets/settings_header.dart';
import 'package:trackerapp/widgets/settings_widgets/settings_menu_tile.dart';

class ModernSettingsScreen extends StatelessWidget {
  const ModernSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(colors: [theme.cardColor, theme.cardColor])
              : AppColors.mainGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(6.w, 1.4.h, 6.w, .4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManagerChatScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF16A34A),
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.2.w,
                          vertical: 0.8.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: const BorderSide(
                            color: Color(0xFF86EFAC),
                          ),
                        ),
                      ),
                      icon: Icon(
                        Icons.chat_bubble_rounded,
                        size: 16.sp,
                      ),
                      label: Text(
                        l10n.liveChat,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        showCustomPopup(
                          context: context,
                          title: l10n.logout,
                          subtitle: l10n.logoutConfirmation,
                          btnText: l10n.logout,
                          imagePath: "assets/images/logout.png",
                          onConfirm: () async {
                            await LocalNotificationService.instance
                                .cancelAllReminderNotifications();
                            try {
                              await FcmTokenRepository()
                                  .deleteLatestTokenForCurrentUser();
                            } catch (e) {
                              debugPrint(
                                  "FCM token delete on logout failed: $e");
                            }
                            await MySharedPreferences.logout();
                            if (!context.mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.4.w, vertical: .8.h),
                        decoration: BoxDecoration(
                          color: AppColors.red
                              .withValues(alpha: isDark ? .50 : .60),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.white
                                .withValues(alpha: isDark ? .42 : .28),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded,
                                color: AppColors.white, size: 17.sp),
                            SizedBox(width: 1.6.w),
                            Text(
                              l10n.logout,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SettingsHeader(),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 1.2.h),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(34),
                      topRight: Radius.circular(34),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? .3 : .08),
                        blurRadius: 18,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(6.w, 2.8.h, 6.w, 0),
                    child: const SettingsMenuList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
