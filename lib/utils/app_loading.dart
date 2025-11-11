import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:trackerapp/app/theme/app_colors.dart';

class GlobalLoader extends StatelessWidget {
  const GlobalLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child:  Center(
        child: SpinKitCircle(
          color: AppColors.primaryColor,
          size: 60,
        ),
      ),
    );
  }
}
