import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/providers/auth_provider.dart';
import 'package:trackerapp/widgets/custom_button.dart';
import 'package:trackerapp/widgets/custom_text_field.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

void showCustomPopup({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String btnText,
  required String imagePath,
  VoidCallback? onConfirm,
}) {
  final theme = Theme.of(context);
  final onSurface = theme.colorScheme.onSurface;
  final isDark = theme.brightness == Brightness.dark;

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isObSecureOld = true;
  bool isObSecureNew = true;
  bool isObSecureConfirm = true;

  const transitionDuration = Duration(milliseconds: 400);
  const reverseDuration = Duration(milliseconds: 400);

  Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    barrierLabel: '',
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseDuration,
    pageBuilder: (_, __, ___) {
      return Align(
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: StatefulBuilder(
            builder: (context, setState) {
              final authProvider = context.watch<AuthProvider>();
              final isChangePassword = title == "Change Password";
              final isLogoutPopup = title.toLowerCase() == "logout";
              final compactPopup = isChangePassword || isLogoutPopup;
              return Dialog(
                insetPadding: EdgeInsets.symmetric(
                    horizontal:
                        isChangePassword ? 12.w : (isLogoutPopup ? 13.w : 9.w)),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(compactPopup ? 16 : 18)),
                backgroundColor: theme.scaffoldBackgroundColor,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isChangePassword
                        ? 4.2.w
                        : (isLogoutPopup ? 4.2.w : 5.w),
                    vertical: isChangePassword
                        ? 1.8.h
                        : (isLogoutPopup ? 1.8.h : 3.h),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isChangePassword)
                        SizedBox(
                          width: double.infinity,
                          height: 4.8.h,
                          child: Stack(
                            children: [
                              Positioned(
                                top: -.6.h,
                                right: -1.w,
                                child: Icon(
                                  Icons.lock_outline_rounded,
                                  color: AppColors.green
                                      .withValues(alpha: isDark ? 0.22 : 0.16),
                                  size: 6.2.h,
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 16.1.sp,
                                    fontWeight: FontWeight.w700,
                                    color: onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (isLogoutPopup)
                        Container(
                          width: 11.w,
                          height: 11.w,
                          decoration: BoxDecoration(
                            color: AppColors.red
                                .withValues(alpha: isDark ? .24 : .14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.logout_rounded,
                            color: AppColors.red,
                            size: 17.sp,
                          ),
                        )
                      else
                        SizedBox(height: 18.h, child: Image.asset(imagePath)),
                      verticalSpace(
                          height: isChangePassword
                              ? .9.h
                              : (isLogoutPopup ? .9.h : 2.h)),
                      if (!isChangePassword)
                        Text(title,
                            style: TextStyle(
                                fontSize: isChangePassword
                                    ? 16.1.sp
                                    : (isLogoutPopup ? 16.1.sp : 19.sp),
                                fontWeight: FontWeight.w700,
                                color: onSurface)),
                      verticalSpace(height: .4.h),
                      Text(subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: isChangePassword
                                  ? 12.8.sp
                                  : (isLogoutPopup ? 12.8.sp : 16.sp),
                              color: onSurface.withValues(alpha: .62))),
                      verticalSpace(
                          height: isChangePassword
                              ? 1.1.h
                              : (isLogoutPopup ? 1.1.h : 2.h)),
                      if (isChangePassword) ...[
                        CustomTextField(
                          controller: oldPasswordController,
                          labelText: "Old Password",
                          obscureText: isObSecureOld,
                          suffixIcon: isObSecureOld
                              ? Icons.visibility
                              : Icons.visibility_off,
                          onSuffixTap: () {
                            setState(() {
                              isObSecureOld = !isObSecureOld;
                            });
                          },
                        ),
                        verticalSpace(height: .9.h),
                        CustomTextField(
                          controller: newPasswordController,
                          labelText: "New Password",
                          obscureText: isObSecureNew,
                          suffixIcon: isObSecureNew
                              ? Icons.visibility
                              : Icons.visibility_off,
                          onSuffixTap: () {
                            setState(() {
                              isObSecureNew = !isObSecureNew;
                            });
                          },
                        ),
                        verticalSpace(height: .9.h),
                        CustomTextField(
                          controller: confirmPasswordController,
                          labelText: "Retype New Password",
                          obscureText: isObSecureConfirm,
                          suffixIcon: isObSecureConfirm
                              ? Icons.visibility
                              : Icons.visibility_off,
                          onSuffixTap: () {
                            setState(() {
                              isObSecureConfirm = !isObSecureConfirm;
                            });
                          },
                        ),
                        verticalSpace(height: 1.1.h),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel",
                                  style: TextStyle(
                                      fontSize: compactPopup ? 13.sp : 16.sp,
                                      color: onSurface.withValues(alpha: .82))),
                            ),
                          ),
                          Expanded(
                            child: CustomButton(
                              text: authProvider.isLoading
                                  ? "Loading..."
                                  : btnText,
                              height: compactPopup ? 3.9.h : 4.h,
                              backgroundColor: title == "Change Password"
                                  ? AppColors.green
                                  : AppColors.red,
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () {
                                      if (title == "Change Password") {
                                        final oldPass =
                                            oldPasswordController.text.trim();
                                        final newPass =
                                            newPasswordController.text.trim();
                                        final confirmPass =
                                            confirmPasswordController.text
                                                .trim();
                                        if (oldPass.isEmpty ||
                                            newPass.isEmpty ||
                                            confirmPass.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Please fill all password fields"),
                                            ),
                                          );
                                          return;
                                        }
                                        if (newPass != confirmPass) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "New password and retype password do not match"),
                                            ),
                                          );
                                          return;
                                        }
                                        Navigator.pop(context);
                                        authProvider.changePasswordProvider(
                                          context: context,
                                          oldPassword: oldPass,
                                          newPassword: newPass,
                                          confirmPassword: confirmPass,
                                        );
                                      } else {
                                        Navigator.pop(context);
                                        if (onConfirm != null) onConfirm();
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = animation.value;

          if (animation.status == AnimationStatus.reverse) {
            final p = 1.0 - t;
            final offset = Offset.lerp(Offset.zero, const Offset(1.0, 0.0), p)!;
            return Transform.translate(
              offset: Offset(offset.dx * MediaQuery.of(context).size.width, 0),
              child: child,
            );
          } else {
            final offset =
                Offset.lerp(const Offset(-1.0, 0.0), Offset.zero, t)!;
            return Transform.translate(
              offset: Offset(offset.dx * MediaQuery.of(context).size.width, 0),
              child: child,
            );
          }
        },
      );
    },
  ));
}
