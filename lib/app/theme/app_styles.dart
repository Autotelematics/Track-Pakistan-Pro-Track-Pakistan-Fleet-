import 'package:flutter/material.dart';
import 'package:getwidget/types/gf_typography_type.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'app_colors.dart';

class AppStyles{
  static TextStyle boldTextStyle(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
    fontFamily: 'Almarena',
    fontSize: 19.sp,
    fontWeight: FontWeight.w900,
  );

  static TextStyle regularTextStyle(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    fontFamily: 'Almarena',
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle lightTextStyle(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
    fontFamily: 'Almarena',
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
  );

  /// 🔹 Dashboard / Vehicle List Styles
  static TextStyle statusTitle(BuildContext context) => TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle vehicleTitle(BuildContext context) =>
      AppStyles.lightTextStyle(context).copyWith(fontSize: 15.sp);

  static TextStyle infoLabel(BuildContext context) => AppStyles.regularTextStyle(context).copyWith(
    color: Theme.of(context).colorScheme.onSurface,
    fontSize: 15.sp,
  );

  static TextStyle infoValue(BuildContext context) => AppStyles.regularTextStyle(context).copyWith(
    color: Theme.of(context).colorScheme.onSurface,
    fontSize: 13.sp,
  );

  static TextStyle statusDuration(BuildContext context) => AppStyles.lightTextStyle(context).copyWith(
    fontSize: 12.sp,
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
  );

  static TextStyle status(String s, BuildContext context) =>
      AppStyles.regularTextStyle(context).copyWith(
        color: AppColors.statusColor(s), // Fixed status colors
        fontSize: 14.sp,
      );

  static TextStyle statusChip(BuildContext context) => AppStyles.lightTextStyle(context).copyWith(
    fontSize: 13.sp,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle address(BuildContext context) =>
      AppStyles.lightTextStyle(context).copyWith(fontSize: 13.sp);

  static TextStyle action(Color color, BuildContext context) =>
      AppStyles.lightTextStyle(context).copyWith(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle groupItem(BuildContext context) => AppStyles.regularTextStyle(context).copyWith(
    color: Theme.of(context).colorScheme.onSurface,
  );

  static const GFTypographyType deviceOnMapSligePanelHeading =
      GFTypographyType.typo5;
  static BorderRadius popupmenuborder = BorderRadius.circular(30);
  static RoundedRectangleBorder cardBorderShape =
  RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));
  static TextStyle appTitleTextStyle = const TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.bold,
  );
  static TextStyle settingPageButtonTextStyle = const TextStyle(
      fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold);
  static TextStyle settingTextstyle =
  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
  static const BoxDecoration appScreenBackgroundImage = BoxDecoration(
    image: DecorationImage(
        image: AssetImage("assets/images/login-page-background-3.jpg"),
        fit: BoxFit.fill),
  );
  static const String errorMessage =
      'trying to load data.Please check internet connection';
  static const String logoPath = 'assets/images/splashsceen.png';
}
