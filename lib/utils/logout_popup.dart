import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/widgets/custom_button.dart';
import 'package:trackerapp/widgets/custom_text_field.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/providers/auth_provider.dart';

void showCustomPopup({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String btnText,
  required String imagePath,
  VoidCallback? onConfirm,
})
{
  final theme = Theme.of(context);
  final onSurface = theme.colorScheme.onSurface;

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  bool isObSecureOld = true;
  bool isObSecureNew = true;

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
              return Dialog(
                insetPadding: EdgeInsets.symmetric(horizontal: 8.w),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                backgroundColor: theme.scaffoldBackgroundColor,
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 18.h, child: Image.asset(imagePath)),
                      verticalSpace(height: 2.h),
                      Text(title,
                          style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w700,
                              color: onSurface)),
                      verticalSpace(height: 1.h),
                      Text(subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: onSurface.withOpacity(.6))),
                      verticalSpace(height: 2.h),
                      if (title == "Change Password") ...[
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
                        verticalSpace(height: 2.h),
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
                        verticalSpace(height: 2.h),
                      ],

                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: onSurface.withOpacity(.8))),
                            ),
                          ),
                          Expanded(
                            child: CustomButton(
                              text: authProvider.isLoading
                                  ? "Loading..."
                                  : btnText,
                              height: 4.h,
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
                                  if (oldPass.isEmpty ||
                                      newPass.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Please enter both passwords"),
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.pop(context);
                                  authProvider.changePasswordProvider(
                                    context: context,
                                    oldPassword: oldPass,
                                    newPassword: newPass,
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
    transitionsBuilder: (context, animation, secondaryAnimation, child)
    {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = animation.value;

          if (animation.status == AnimationStatus.reverse) {
            final p = 1.0 - t;
            final offset =
            Offset.lerp(Offset.zero, const Offset(1.0, 0.0), p)!;
            return Transform.translate(
              offset: Offset(offset.dx * MediaQuery.of(context).size.width, 0),
              child: child,
            );
          } else {
            final offset = Offset.lerp(const Offset(-1.0, 0.0), Offset.zero, t)!;
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
