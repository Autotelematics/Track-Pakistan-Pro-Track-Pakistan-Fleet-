// lib/screens/login_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/auth_provider.dart';
import 'package:trackerapp/utils/header_bezier.dart';
import 'package:trackerapp/utils/motion_bottom_navigation_bar.dart';
import 'package:trackerapp/widgets/custom_button.dart';
import 'package:trackerapp/widgets/custom_text_field.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? theme.colorScheme.primary : AppColors.primaryColor;
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          children: [
            // HEADER WITH GLOW
            Stack(
              children: [
                // Glow Shadow
                Container(
                  height: 37.h,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor,
                        blurRadius: isDark ? 12 : 0,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                // Curved Header
                ClipPath(
                  clipper: HeaderClipper(),
                  child: Container(
                    height: 37.h,
                    width: double.infinity,
                    color: cardColor,
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/images/logo.png",
                      colorBlendMode: isDark ? BlendMode.srcIn : null,
                      color: isDark ? AppColors.primaryColor : null,
                    ),
                  ),
                ),
              ],
            ),

            verticalSpace(height: 5.h),

            // FORM
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                children: [
                  Text(
                    "Welcome Back !",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  verticalSpace(height: 6.h),

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    labelText: "Email",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  verticalSpace(height: 2.h),

                  // Password Field
                  Consumer<AuthProvider>(
                    builder: (context, provider, _) => CustomTextField(
                      controller: _passwordController,
                      labelText: "Password",
                      prefixIcon: Icons.lock_outline,
                      obscureText: provider.isObSecure,
                      suffixIcon: provider.isObSecure ? Icons.visibility_off : Icons.visibility,
                      onTap: provider.toggleObSecure,
                    ),
                  ),
                  verticalSpace(height: 4.h),

                  // Sign In Button
                  Consumer<AuthProvider>(
                    builder: (context, provider, _) {
                      return CustomButton(
                        text: provider.isLoading ? "Please wait..." : "Sign In",
                        textColor: AppColors.white,
                        backgroundColor: isDark ? AppColors.primaryColor : primaryColor,
                        onPressed: provider.isLoading
                            ? null
                            : () {
                          provider.loginProvider(
                            context: context,
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                        },
                      );
                    },
                  ),

                  verticalSpace(height: 3.h),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account? ",
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14.sp,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {

                        },
                        child: Text(
                          "Contact Us",
                          style: AppStyles.regularTextStyle(context).copyWith(color: primaryColor)
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}