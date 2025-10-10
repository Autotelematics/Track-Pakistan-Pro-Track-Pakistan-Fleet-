import 'package:flutter/material.dart';
class AppColors{
  static Color yellow=Color(0xFFFFEB00);
  static Color yellowWithOpacity=Color(0xFFff9800).withOpacity(0.4);

  static Color green=Color(0xff06D001);
  static Color greenWithOpacity=Color(0xFF24c45f).withOpacity(0.4);

  static Color red=Color(0xFFE83F25);
  static Color redWithOpacity=Color(0xFFef5350).withOpacity(0.4);

  static Color blueCyan=Color(0xFF0065F8);
  static Color blueCyanWithOpacity=Color(0xFF0066FF).withOpacity(0.6);

  static Color grey=Color(0xffD1D3D4);
  static Color borderColor=Color(0xffc5c5c5);
  static Color lightGrey=Color(0xfff3f3f3);
  static Color black=Color(0xff000000);
  static Color textBlack=Color(0xff1c1c1c);
  static Color purple=Color(0xFF3B0D84);
  static Color purpleWithOpacity=Color(0xFF3B0D84).withOpacity(0.4);


  static Color textColor=Color(0xff0e384f);
  static Color white=Color(0xffffffff);
  static Color scaffoldBg=Color(0xfff9fafb);
  static const Color buttonColor = Colors.green;
  static Color statusColor(String status) {
    switch (status) {
      case "Running":
        return AppColors.green;
      case "Stopped":
        return AppColors.red;
      case "Idle":
        return AppColors.yellow;
      case "Offline":
        return AppColors.blueCyan;
      default:
        return AppColors.purple;
    }
  }

}