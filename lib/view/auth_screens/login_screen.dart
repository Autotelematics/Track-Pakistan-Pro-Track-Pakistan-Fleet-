import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/auth_provider.dart';
import 'package:trackerapp/providers/motion_bottom_bar_provider.dart';
import 'package:trackerapp/utils/app_loading.dart';
import 'package:trackerapp/utils/app_validators.dart';
import 'package:trackerapp/utils/header_bezier.dart';
import 'package:trackerapp/white_labeling/colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
    isDark ? theme.colorScheme.primary : ConstantColor.primaryColor;
    final cardColor = theme.cardColor;

    return Consumer<AuthProvider>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              resizeToAvoidBottomInset: false,
              body: SizedBox(
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 37.h,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: ConstantColor.primaryColor,
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
                              colorBlendMode:
                              isDark ? BlendMode.srcIn : null,
                              color:
                              isDark ? ConstantColor.primaryColor : null,
                            ),
                          ),
                        ),
                      ],
                    ),

                    verticalSpace(height: 5.h),

                    // FORM
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Form(
                        key: _formKey,
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
                              validator: Validators.validateEmail,
                            ),
                            verticalSpace(height: 2.h),

                            // Password Field
                            CustomTextField(
                              controller: _passwordController,
                              labelText: "Password",
                              prefixIcon: Icons.lock_outline,
                              obscureText: provider.isObSecure,
                              suffixIcon: provider.isObSecure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              onTap: provider.toggleObSecure,
                              validator: Validators.validatePassword,
                            ),
                            verticalSpace(height: 4.h),

                            // Sign In Button
                            CustomButton(
                              text: "Sign In",
                              textColor: AppColors.white,
                              backgroundColor: isDark
                                  ? ConstantColor.primaryColor
                                  : primaryColor,
                              onPressed: () =>{
                                context
                                    .read<MotionBottomBarProvider>()
                                    .setIndex(2),
                                _onLoginPressed(context)
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
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                    fontSize: 14.sp,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    "Contact Us",
                                    style:
                                    AppStyles.regularTextStyle(context)
                                        .copyWith(color: primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (provider.isLoading)  AppLoadings.circleLoading(),
          ],
        );
      },
    );
  }
}
