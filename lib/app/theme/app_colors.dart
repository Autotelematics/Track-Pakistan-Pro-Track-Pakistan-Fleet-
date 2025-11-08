import 'package:flutter/material.dart';
class AppColors{
  static Color yellow=Color(0xFFffc708);
  static Color primaryColor=Color(0xFFffc708);
  static Color green=Color(0xff06D001);
  static Color red=Color(0xFFE83F25);
  static Color blueCyan=Color(0xFF0065F8);
  static Color blueCyanWithOpacity=Color(0xFF0066FF).withOpacity(0.6);
  static Color grey=Color(0xffD1D3D4);
  static Color black=Color(0xff000000);
  static Color textBlack=Color(0xff1c1c1c);
  static Color purple=Color(0xFF3B0D84);


  static Color white=Color(0xffffffff);
  static Color scaffoldBg=Color(0xfff9fafb);
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
  // ---------- DARK THEME ----------
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF252525);
  static const Color darkOnSurface = Color(0xFFE0E0E0);


}