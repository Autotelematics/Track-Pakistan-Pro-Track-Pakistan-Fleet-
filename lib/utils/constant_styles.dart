import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/utils/constant_colors.dart';

class ConstantTextStyles{
  static TextStyle boldTextStyle=TextStyle(
      color: ConstantColors.white,
      fontFamily: 'Almarena',
      fontSize: 19.sp,
      fontWeight: FontWeight.w900
  );

  static TextStyle regularTextStyle= TextStyle(
      color: ConstantColors.grey,
      fontFamily: 'Almarena',
      fontSize: 16.sp,
      fontWeight: FontWeight.w600
  );
  static TextStyle lightTextStyle= TextStyle(
      color: ConstantColors.textBlack,
      fontFamily: 'Almarena',
      fontSize: 14.sp,
      fontWeight: FontWeight.w700
  );
}