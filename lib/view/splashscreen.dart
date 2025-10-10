import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trackerapp/app/theme/app_styles.dart';

import '../utils/motion_bottom_navigation_bar.dart';
class SplachScreen extends StatefulWidget {
  const SplachScreen({super.key});

  @override
  State<SplachScreen> createState() => _SplachScreenState();
}

class _SplachScreenState extends State<SplachScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), (() async {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MotionBottomNavigationBar()));
    }));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: Image(image: AssetImage(AppStyles.logoPath)),
        ),
      ),
    );
  }
}
