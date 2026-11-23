import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trackerapp/utils/local_notification_service.dart';
import 'package:trackerapp/utils/motion_bottom_navigation_bar.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/view/auth_screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), (() async {
      if (!mounted) return;
      var isLogin = MySharedPreferences.getBool(isLoggedInKey);
      if (isLogin) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MotionBottomNavigationBar(),
          ),
          (route) => false,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(
            LocalNotificationService.instance.processPendingNotificationTap(),
          );
        });
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(65.0),
          child: Image(image: AssetImage("assets/images/company_logo.png")),
        ),
      ),
    );
  }
}
