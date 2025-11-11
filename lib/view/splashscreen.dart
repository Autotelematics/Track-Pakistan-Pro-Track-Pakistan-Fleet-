import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trackerapp/utils/motion_bottom_navigation_bar.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/view/login_screen.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), (() async {
      var isLogin = MySharedPreferences.getBool(isLoggedInKey);
      if (isLogin) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MotionBottomNavigationBar()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: Image(image: AssetImage("assets/images/splashsceen.png")),
        ),
      ),
    );
  }
}
