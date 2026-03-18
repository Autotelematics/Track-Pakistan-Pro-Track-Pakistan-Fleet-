import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/auth_provider.dart';
import 'package:trackerapp/utils/app_loading.dart';
import 'package:trackerapp/utils/app_validators.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/white_labeling/contacts.dart';
import 'package:trackerapp/widgets/custom_button.dart';
import 'package:trackerapp/widgets/custom_text_field.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _authProvider.loginProvider(
        context: context,
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  Future<void> _launchExternal(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? theme.colorScheme.primary : ConstantColor.primaryColor;
    final onSurface = theme.colorScheme.onSurface;

    return Consumer<AuthProvider>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    "assets/images/bg_login.png",
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: -10.h,
                    left: -18.w,
                    child: _GlowOrb(
                      size: 52.w,
                      color: primaryColor.withValues(alpha: isDark ? .28 : .2),
                    ),
                  ),
                  Positioned(
                    top: 20.h,
                    right: -20.w,
                    child: _GlowOrb(
                      size: 58.w,
                      color: Colors.blue.withValues(alpha: isDark ? .16 : .11),
                    ),
                  ),
                  Positioned(
                    bottom: -14.h,
                    right: -16.w,
                    child: _GlowOrb(
                      size: 62.w,
                      color:
                          AppColors.green.withValues(alpha: isDark ? .2 : .12),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: isDark ? 0.42 : 0.26),
                          theme.scaffoldBackgroundColor
                              .withValues(alpha: isDark ? 0.84 : 0.9),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 3.h),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 92.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 2.h),
                              _BrandHero(
                                isDark: isDark,
                                primaryColor: primaryColor,
                                onSurface: onSurface,
                              ),
                              SizedBox(height: 4.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(22.px),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(22.px),
                                      color: theme.cardColor.withValues(
                                          alpha: isDark ? 0.68 : .9),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white
                                                .withValues(alpha: .15)
                                            : Colors.black
                                                .withValues(alpha: .08),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                              alpha: isDark ? .32 : .1),
                                          blurRadius: 28,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            "Welcome Back",
                                            style:
                                                AppStyles.boldTextStyle(context)
                                                    .copyWith(
                                              color: onSurface,
                                              fontSize: 21.sp,
                                            ),
                                          ),
                                          SizedBox(height: 0.8.h),
                                          Text(
                                            "Sign in to continue fleet monitoring",
                                            style: AppStyles.regularTextStyle(
                                                    context)
                                                .copyWith(
                                              color: onSurface.withValues(
                                                  alpha: 0.72),
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          SizedBox(height: 3.2.h),
                                          CustomTextField(
                                            controller: _emailController,
                                            labelText: "Email",
                                            prefixIcon: Icons.email_outlined,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            validator: Validators.validateEmail,
                                            fillColor: isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.06)
                                                : Colors.white,
                                            textColor: onSurface,
                                            labelColor: onSurface.withValues(
                                                alpha: 0.62),
                                            borderColor: isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.2)
                                                : AppColors.grey
                                                    .withValues(alpha: 0.6),
                                            focusedBorderColor: primaryColor,
                                          ),
                                          SizedBox(height: 1.8.h),
                                          CustomTextField(
                                            controller: _passwordController,
                                            labelText: "Password",
                                            prefixIcon: Icons.lock_outline,
                                            obscureText: provider.isObSecure,
                                            suffixIcon: provider.isObSecure
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            onSuffixTap:
                                                provider.toggleObSecure,
                                            validator:
                                                Validators.validatePassword,
                                            fillColor: isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.06)
                                                : Colors.white,
                                            textColor: onSurface,
                                            labelColor: onSurface.withValues(
                                                alpha: 0.62),
                                            borderColor: isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.2)
                                                : AppColors.grey
                                                    .withValues(alpha: 0.6),
                                            focusedBorderColor: primaryColor,
                                          ),
                                          SizedBox(height: 3.h),
                                          CustomButton(
                                            text: "Sign In",
                                            textColor: AppColors.black,
                                            backgroundColor: primaryColor,
                                            borderRadius: 14,
                                            height: 5.8.h,
                                            fontSize: 16.sp,
                                            onPressed: () =>
                                                _onLoginPressed(context),
                                          ),
                                          SizedBox(height: 2.3.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _SocialButton(
                                                tooltip: "Facebook",
                                                onTap: () => _launchExternal(
                                                    CompanyInfo.facebook),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: Image.asset(
                                                    "assets/images/facebook.png",
                                                    width: 10.2.w,
                                                    height: 10.2.w,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 4.w),
                                              _SocialButton(
                                                tooltip: "Instagram",
                                                onTap: () => _launchExternal(
                                                    CompanyInfo.instagram),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: Image.asset(
                                                    "assets/images/instagram.jpg",
                                                    width: 6.2.w,
                                                    height: 6.2.w,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 4.w),
                                              _SocialButton(
                                                tooltip: "Website",
                                                onTap: () => _launchExternal(
                                                    CompanyInfo.website),
                                                child: SvgPicture.asset(
                                                  "assets/images/websitenewa.svg",
                                                  width: 6.2.w,
                                                  height: 6.2.w,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (provider.isLoading) AppLoadings.circleLoading(),
          ],
        );
      },
    );
  }
}

class _BrandHero extends StatelessWidget {
  const _BrandHero({
    required this.isDark,
    required this.primaryColor,
    required this.onSurface,
  });

  final bool isDark;
  final Color primaryColor;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: EdgeInsets.only(top: 6.h),
          padding: EdgeInsets.fromLTRB(5.w, 10.5.h, 5.w, 2.2.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.px),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withValues(alpha: isDark ? 0.22 : 0.14),
                Colors.white.withValues(alpha: isDark ? 0.06 : 0.3),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.26),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.1),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                "Autotel Fleet",
                textAlign: TextAlign.center,
                style: AppStyles.boldTextStyle(context).copyWith(
                  color: onSurface,
                  fontSize: 20.sp,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                "Smarter Tracking, Cleaner Operations",
                textAlign: TextAlign.center,
                style: AppStyles.regularTextStyle(context).copyWith(
                  color: onSurface.withValues(alpha: .72),
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 0.8.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.65.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.px),
                  color: primaryColor.withValues(alpha: isDark ? .24 : .18),
                ),
                child: Text(
                  "Fleet Control Center",
                  style: AppStyles.lightTextStyle(context).copyWith(
                    fontSize: 13.sp,
                    color: isDark ? primaryColor : AppColors.textBlack,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 34.w,
          height: 16.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: isDark ? .2 : .95),
                Colors.white.withValues(alpha: isDark ? .08 : .72),
              ],
            ),
            border: Border.all(
              color: primaryColor.withValues(alpha: .7),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: isDark ? .35 : .25),
                blurRadius: 24,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Image.asset(
              "assets/images/logo1.png",
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          top: 0.8.h,
          right: 23.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: .45.h),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: .92),
              borderRadius: BorderRadius.circular(14.px),
            ),
            child: Text(
              "Hello User,",
              style: AppStyles.lightTextStyle(context).copyWith(
                color: AppColors.white,
                fontSize: 11.8.sp,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.child,
    required this.onTap,
    required this.tooltip,
  });

  final Widget child;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
          width: 11.w,
          height: 11.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.cardColor.withValues(alpha: isDark ? .5 : .9),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: .22)
                  : Colors.black.withValues(alpha: .08),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
