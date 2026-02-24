import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:trackerapp/white_labeling/colors.dart';

class AppLoadings {

  //Circular Loading
  static Widget circleLoading() {
    return Center(
      child: SpinKitCircle(
        color: ConstantColor.primaryColor,
        size: 60,
      ),
    );
  }
  //Button Loading
 static Widget buttonLoading(){
    return Center(
      child:  SpinKitThreeBounce(
        color: ConstantColor.primaryColor,
        size: 30,
      ),
    );
 }
}
