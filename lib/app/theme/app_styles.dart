import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'app_colors.dart';

class AppStyles {
  /// Text Styles
  static TextStyle boldTextStyle(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
    fontFamily: 'Almarena',
    fontSize: 19.sp,
    fontWeight: FontWeight.w900,
  );
  static TextStyle semiboldTextStyle(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
    fontFamily: 'Almarena',
    fontSize: 16.sp,
    fontWeight: FontWeight.w800,
  );

  static TextStyle regularTextStyle(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    fontFamily: 'Almarena',
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle lightTextStyle(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
    fontFamily: 'Almarena',
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
  );

  /// Dashboard / Vehicle List Styles
  static TextStyle statusTitle(BuildContext context) =>  TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle vehicleTitle(BuildContext context) =>
      lightTextStyle(context).copyWith(fontSize: 15.sp);

  static TextStyle infoLabel(BuildContext context) =>
      regularTextStyle(context).copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15.sp,
      );

  static TextStyle infoValue(BuildContext context) =>
      regularTextStyle(context).copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 13.sp,
      );

  static TextStyle statusDuration(BuildContext context) =>
      lightTextStyle(context).copyWith(
        fontSize: 13.sp,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      );

  static TextStyle status(String s, BuildContext context) =>
      regularTextStyle(context).copyWith(
        color: AppColors.statusColor(s),
        fontSize: 14.sp,
      );

  static TextStyle statusChip(BuildContext context) =>
      lightTextStyle(context).copyWith(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  static TextStyle address(BuildContext context) =>
      lightTextStyle(context).copyWith(fontSize: 13.sp);

  static TextStyle action(Color color, BuildContext context) =>
      lightTextStyle(context).copyWith(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle groupItem(BuildContext context) =>
      regularTextStyle(context).copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      );


  static TextStyle appTitleTextStyle = const TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.bold,
    fontFamily: "Almarena"
  );

  static get context => null;

  static buttonTextStyle(BuildContext context) {}

}
