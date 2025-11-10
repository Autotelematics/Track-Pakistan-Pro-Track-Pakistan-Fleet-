import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
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
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
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
