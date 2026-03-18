import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/repositories/fcm_token_repository.dart';
import 'package:trackerapp/utils/local_notification_service.dart';
import 'package:trackerapp/utils/logout_popup.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/view/auth_screens/login_screen.dart';

class ManagerManagementHeader extends StatelessWidget {
  final String userEmail;
  final String userType;
  final String greeting;

  const ManagerManagementHeader({
    super.key,
    required this.userEmail,
    required this.userType,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(5.w, 6.h, 5.w, 2.2.h),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : null,
        gradient: isDark ? null : AppColors.mainGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 6.2.h,
            height: 6.2.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.65),
                width: 1.2,
              ),
            ),
            child: Icon(
              Icons.manage_accounts_outlined,
              size: 3.4.h,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userEmail.isEmpty ? "Manager User" : userEmail,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    color: Colors.white,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: .3.h),
                Text(
                  "$greeting  •  ${userType.isEmpty ? "manager" : userType}",
                  style: AppStyles.regularTextStyle(context).copyWith(
                    color: Colors.white.withValues(alpha: .92),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              showCustomPopup(
                context: context,
                title: "Logout",
                subtitle: "Are you sure you want to logout?",
                btnText: "Logout",
                imagePath: "assets/images/logout.png",
                onConfirm: () async {
                  await LocalNotificationService.instance
                      .cancelAllReminderNotifications();
                  try {
                    await FcmTokenRepository()
                        .deleteLatestTokenForCurrentUser();
                  } catch (e) {
                    debugPrint("FCM token delete on logout failed: $e");
                  }
                  await MySharedPreferences.logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.4.w, vertical: .8.h),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: isDark ? .50 : .60),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? .42 : .28),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: Colors.white, size: 17.sp),
                  SizedBox(width: 1.4.w),
                  Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
